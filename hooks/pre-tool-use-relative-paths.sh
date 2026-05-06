#!/usr/bin/env bash
# PreToolUse hook: Bash — rewrites absolute paths within the project directory
# to relative paths, preventing full system path leakage in commands.
# Exit 0 with no stdout when no absolute paths are found (pass-through).

set -euo pipefail

INPUT="$(cat)"

# Require jq — fail gracefully if missing.
if ! command -v jq &>/dev/null; then
  exit 0
fi

# Extract the command string from the JSON payload.
COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)" || true

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Get project directory, bail if unset.
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
if [[ -z "$PROJECT_DIR" ]]; then
  exit 0
fi

# Quick check: does the command contain the project directory path?
# Only proceed if the command actually references the project dir or contains
# paths that look like absolute filesystem paths (starting with / followed by
# a typical directory name). Avoids false positives on URLs, relative paths, flags.
if ! [[ "$COMMAND" == *"$PROJECT_DIR"* ]] && ! printf '%s' "$COMMAND" | grep -qE '(^|[[:space:]"'"'"'=])/(Users|home|root|var|opt|mnt|media|srv)/'; then
  exit 0
fi

# System paths that should never be rewritten.
SYSTEM_PATH_PATTERN='^/(dev|usr|bin|sbin|tmp|private/tmp|opt/homebrew|etc|var|proc|sys|run|snap|Library/Frameworks|System|Applications|nix|home/linuxbrew)(/|$)'

# Replace project directory paths with relative equivalents using sed for
# word-boundary-safe replacement. This avoids the bash ${//} pitfall where
# PROJECT_DIR="/Users/alice" would incorrectly match "/Users/alice-backup/".
REWRITTEN="$COMMAND"
CHANGED=false

if [[ "$COMMAND" == *"$PROJECT_DIR"* ]]; then
  # Use sed with escaped PROJECT_DIR for safe replacement.
  # 1. Replace "$PROJECT_DIR/" with "" (making paths relative).
  #    The trailing "/" ensures we don't match "$PROJECT_DIR-backup/".
  # 2. Replace standalone "$PROJECT_DIR" only when followed by end-of-line,
  #    space, quote, or other non-path characters — prevents partial matches
  #    like "/Users/alice" matching inside "/Users/alice-backup".
  ESCAPED_DIR="$(printf '%s' "$PROJECT_DIR" | sed 's/[.[\/*^$]/\\&/g')"
  REWRITTEN="$(printf '%s' "$COMMAND" | sed "s|${ESCAPED_DIR}/||g")"
  # Only replace standalone project dir when followed by word boundary
  REWRITTEN="$(printf '%s' "$REWRITTEN" | sed "s|${ESCAPED_DIR}\([[:space:]\"']\)|.\1|g; s|${ESCAPED_DIR}\$|.|g")"
  if [[ "$REWRITTEN" != "$COMMAND" ]]; then
    CHANGED=true
  fi
fi

# Check for remaining non-allowlisted absolute paths (outside the project).
# Only match paths that look like real filesystem locations: require at least
# two path segments from root and start with a known top-level directory.
# This avoids false positives on URL paths (/api/v1), flags (--opt=a/b), etc.
REMAINING_ABS=""
ABS_PATH_REGEX='/(Users|home|root|opt|mnt|media|srv|data)/[a-zA-Z0-9._/-]+'
if printf '%s' "$REWRITTEN" | grep -oE "$ABS_PATH_REGEX" 2>/dev/null | grep -vE "$SYSTEM_PATH_PATTERN" | grep -vq '^$' 2>/dev/null; then
  REMAINING_ABS="$(printf '%s' "$REWRITTEN" | grep -oE "$ABS_PATH_REGEX" 2>/dev/null | grep -vE "$SYSTEM_PATH_PATTERN" | head -5)" || true
fi

# If nothing changed and no external paths detected, pass through.
if [[ "$CHANGED" == false ]] && [[ -z "$REMAINING_ABS" ]]; then
  exit 0
fi

# Build the output JSON.
if [[ "$CHANGED" == true ]] && [[ -n "$REMAINING_ABS" ]]; then
  # Both: rewrote project paths + warning about external absolute paths.
  jq -n \
    --arg cmd "$REWRITTEN" \
    --arg ctx "Rewrote project absolute paths to relative. Warning: command also contains absolute paths outside the project directory that were not rewritten." \
    --arg reason "Rewrote absolute project path(s) to relative paths" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": $reason,
        "updatedInput": { "command": $cmd },
        "additionalContext": $ctx
      }
    }'
elif [[ "$CHANGED" == true ]]; then
  # Only rewrote project paths, no external paths.
  jq -n \
    --arg cmd "$REWRITTEN" \
    --arg reason "Rewrote absolute project path(s) to relative paths" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": $reason,
        "updatedInput": { "command": $cmd }
      }
    }'
else
  # No project paths rewrote, but external absolute paths detected — warn only.
  jq -n \
    --arg ctx "Warning: command contains absolute paths outside the project directory. Consider using relative paths where possible." \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": "External absolute paths detected (allowed with warning)",
        "additionalContext": $ctx
      }
    }'
fi
