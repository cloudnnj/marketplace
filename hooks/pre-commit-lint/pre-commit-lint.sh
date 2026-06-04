#!/usr/bin/env bash
# PreToolUse hook: Bash — runs lint and typecheck before any git commit.
# Exit 2 with a descriptive stderr message to block the commit on failure.
# Exit 0 silently if this is not a git commit command.

set -euo pipefail

# Read the full tool-use JSON payload from stdin.
INPUT="$(cat)"

# Require jq — fail gracefully if missing.
if ! command -v jq &>/dev/null; then
  echo "pre-commit-lint: jq not found, skipping hook" >&2
  exit 0
fi

# Extract the command string from the JSON payload.
COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)" || true

# Only act on git commit invocations.
if [[ -z "$COMMAND" ]] || ! [[ "$COMMAND" =~ ^git\ commit ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

FAILURES=()

# Lint only staged .ts/.tsx files (not the entire project).
STAGED=$(git diff --cached --name-only --diff-filter=d -- '*.ts' '*.tsx' 2>/dev/null || true)

if [[ -n "$STAGED" ]]; then
  echo "pre-commit-lint: running eslint on staged files..." >&2
  if ! npx eslint $STAGED 2>&1 >&2; then
    FAILURES+=("lint")
  fi
else
  echo "pre-commit-lint: no staged .ts/.tsx files, skipping lint" >&2
fi

# TypeScript --noEmit necessarily checks the whole project (cross-file resolution).
echo "pre-commit-lint: running tsc --noEmit..." >&2
if ! npx tsc --noEmit --project "$PROJECT_DIR/tsconfig.json" 2>&1 >&2; then
  FAILURES+=("typecheck")
fi

if [[ ${#FAILURES[@]} -gt 0 ]]; then
  echo "" >&2
  echo "pre-commit-lint: BLOCKED — the following checks failed: ${FAILURES[*]}" >&2
  echo "Fix the errors above before committing." >&2
  exit 2
fi

exit 0
