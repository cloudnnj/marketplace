#!/usr/bin/env bash
# PostToolUse hook: Edit|Write — reminds Claude to generate a migration after
# touching electron/database/schema.ts.
# Outputs a JSON block decision to prevent the change from being silently forgotten.

set -euo pipefail

INPUT="$(cat)"

if ! command -v jq &>/dev/null; then
  # Cannot parse input — exit silently to avoid blocking work.
  exit 0
fi

FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || true

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only act when schema.ts is the edited file.
if ! [[ "$FILE_PATH" == *"electron/database/schema.ts" ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MIGRATIONS_DIR="$PROJECT_DIR/electron/database/migrations"

# If there are uncommitted .sql migration files, assume the developer already
# generated a migration for the current schema change — downgrade to informational.
PENDING_MIGRATIONS="$(git diff --name-only -- "$MIGRATIONS_DIR"/*.sql 2>/dev/null || true)"
UNTRACKED_MIGRATIONS="$(git ls-files --others --exclude-standard -- "$MIGRATIONS_DIR"/*.sql 2>/dev/null || true)"

if [[ -n "$PENDING_MIGRATIONS" || -n "$UNTRACKED_MIGRATIONS" ]]; then
  # Migration already generated — no need to block.
  exit 0
fi

REASON="You just edited electron/database/schema.ts. You MUST complete the following steps before continuing:

1. Generate a migration:
       npm run db:generate -- --name <short-description>

2. Verify _journal.json timestamp ordering:
       cat electron/database/migrations/meta/_journal.json | jq '.entries[-2:]'
   Ensure the new entry's \"when\" value is strictly greater than the previous entry.

3. If you added a NEW TABLE, update EXPECTED_TABLES in:
       electron/database/backwards-compat.ts

4. Stage and commit these files together:
       git add electron/database/schema.ts electron/database/migrations/ electron/database/backwards-compat.ts

Do NOT proceed with a commit until all steps are done."

jq -n --arg reason "$REASON" '{"decision":"block","reason":$reason}'
