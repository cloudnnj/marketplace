#!/usr/bin/env bash
# PreToolUse hook: Bash — intercepts gh CLI commands and curl/wget calls to
# api.github.com, denying execution and guiding Claude to use the equivalent
# GitHub MCP tool (mcp__github__*) instead.
# Exit 0 with no stdout when the command is not GitHub-related (pass-through).

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

# --- gh CLI detection ---

# Check if the command invokes `gh` as a command (not as a substring of another word).
# Matches: `gh ...`, `&& gh ...`, `| gh ...`, `; gh ...`, `$(gh ...`, backtick subshells, etc.
if printf '%s' "$COMMAND" | grep -qE '(^|[|;&()` ]+)gh\s'; then

  # Extract the gh subcommand. Find the first `gh <word>` occurrence.
  GH_SUB="$(printf '%s' "$COMMAND" | grep -oE '(^|[|;&()` ]+)gh\s+[a-z-]+' | head -1 | grep -oE 'gh\s+[a-z-]+' | awk '{print $2}')" || true

  if [[ -z "$GH_SUB" ]]; then
    # Bare `gh` with no subcommand — harmless help output, pass through.
    exit 0
  fi

  # Exception subcommands that have no MCP equivalents — allow through.
  case "$GH_SUB" in
    run|release|workflow|auth|extension|gist|secret|variable|codespace|alias|completion|status|config|label|cache|attestation|gpg-key|ssh-key)
      exit 0
      ;;
  esac

  # Extract the action (second word after gh subcommand) for mapping.
  GH_ACTION="$(printf '%s' "$COMMAND" | grep -oE '(^|[|;&()` ]+)gh\s+[a-z-]+\s+[a-z-]+' | head -1 | grep -oE 'gh\s+[a-z-]+\s+[a-z-]+' | awk '{print $3}')" || true

  # Build the MCP tool suggestion based on subcommand + action.
  MCP_TOOL=""
  REASON=""

  case "$GH_SUB" in
    pr)
      case "$GH_ACTION" in
        create)  MCP_TOOL="mcp__github__create_pull_request" ;;
        list)    MCP_TOOL="mcp__github__list_pull_requests" ;;
        view)    MCP_TOOL="mcp__github__pull_request_read" ;;
        merge)   MCP_TOOL="mcp__github__merge_pull_request" ;;
        comment) MCP_TOOL="mcp__github__add_issue_comment" ;;
        review)  MCP_TOOL="mcp__github__pull_request_review_write" ;;
        edit)    MCP_TOOL="mcp__github__update_pull_request" ;;
        checks)  MCP_TOOL="mcp__github__pull_request_read" ;;
        close)   MCP_TOOL="mcp__github__update_pull_request" ;;
        diff)    MCP_TOOL="mcp__github__pull_request_read" ;;
        ready)   MCP_TOOL="mcp__github__update_pull_request" ;;
        *)       MCP_TOOL="mcp__github__pull_request_read or mcp__github__list_pull_requests" ;;
      esac
      REASON="Use $MCP_TOOL instead of 'gh pr${GH_ACTION:+ $GH_ACTION}'."
      ;;
    issue)
      case "$GH_ACTION" in
        create)  MCP_TOOL="mcp__github__issue_write" ;;
        list)    MCP_TOOL="mcp__github__list_issues" ;;
        view)    MCP_TOOL="mcp__github__issue_read" ;;
        comment) MCP_TOOL="mcp__github__add_issue_comment" ;;
        edit)    MCP_TOOL="mcp__github__issue_write" ;;
        close)   MCP_TOOL="mcp__github__issue_write" ;;
        *)       MCP_TOOL="mcp__github__issue_read or mcp__github__list_issues" ;;
      esac
      REASON="Use $MCP_TOOL instead of 'gh issue${GH_ACTION:+ $GH_ACTION}'."
      ;;
    search)
      case "$GH_ACTION" in
        code)    MCP_TOOL="mcp__github__search_code" ;;
        repos)   MCP_TOOL="mcp__github__search_repositories" ;;
        issues)  MCP_TOOL="mcp__github__search_issues" ;;
        prs)     MCP_TOOL="mcp__github__search_pull_requests" ;;
        *)       MCP_TOOL="mcp__github__search_code or mcp__github__search_repositories" ;;
      esac
      REASON="Use $MCP_TOOL instead of 'gh search${GH_ACTION:+ $GH_ACTION}'."
      ;;
    repo)
      case "$GH_ACTION" in
        view)    MCP_TOOL="mcp__github__search_repositories" ;;
        create)  MCP_TOOL="mcp__github__create_repository" ;;
        clone)
          MCP_TOOL="git clone"
          REASON="Use 'git clone' directly instead of 'gh repo clone'. For browsing file contents, use mcp__github__get_file_contents."
          ;;
        fork)    MCP_TOOL="mcp__github__fork_repository" ;;
        *)       MCP_TOOL="mcp__github__search_repositories or mcp__github__get_file_contents" ;;
      esac
      # Only set default REASON if not already set by a specific action above.
      if [[ -z "$REASON" ]]; then
        REASON="Use $MCP_TOOL instead of 'gh repo${GH_ACTION:+ $GH_ACTION}'."
      fi
      ;;
    api)
      MCP_TOOL="the appropriate mcp__github__* tool for this API endpoint"
      REASON="Use $MCP_TOOL instead of 'gh api'. The gh api command is a direct REST wrapper — use the specific MCP tool for the endpoint you need."
      ;;
    *)
      MCP_TOOL="the appropriate mcp__github__* tool"
      REASON="Use $MCP_TOOL instead of 'gh $GH_SUB'. GitHub operations must use MCP tools."
      ;;
  esac

  jq -n \
    --arg reason "$REASON" \
    --arg ctx "GitHub CLI (gh) is not allowed. Use GitHub MCP tools instead. The GitHub MCP server provides equivalent functionality with better integration." \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": $reason,
        "additionalContext": $ctx
      }
    }'
  exit 0
fi

# --- curl/wget to api.github.com detection ---

# Match curl or wget with a URL targeting api.github.com (anchored at domain boundary).
if printf '%s' "$COMMAND" | grep -qE '\b(curl|wget)\b' && printf '%s' "$COMMAND" | grep -qE 'https?://api\.github\.com(/|[[:space:]]|$|")'; then
  jq -n \
    --arg reason "Use the appropriate mcp__github__* tool instead of calling the GitHub API directly via curl/wget." \
    --arg ctx "GitHub REST API calls via curl/wget are not allowed. Use GitHub MCP tools instead. Available tools include: mcp__github__list_pull_requests, mcp__github__create_pull_request, mcp__github__issue_read, mcp__github__search_code, and more." \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": $reason,
        "additionalContext": $ctx
      }
    }'
  exit 0
fi

# Not a GitHub CLI/API command — pass through silently.
exit 0
