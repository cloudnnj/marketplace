# Post-Edit: Drizzle Schema Migration Reminder

A PostToolUse hook scoped to `Edit`/`Write` on `electron/database/schema.ts`. Returns a JSON decision block reminding Claude to generate and review a Drizzle migration so the change isn't silently forgotten.

## What it does

- Reads the tool-call payload from stdin (JSON, via `jq`).
- Triggers only when the edited file path ends in `electron/database/schema.ts`.
- Emits a JSON response asking Claude to run `npm run db:generate -- --name <desc>` and verify the new entry's `when` timestamp in `_journal.json` is monotonically increasing.

## Requirements

- `jq`.

## Recommended settings

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit-schema.sh",
  "timeout": 10,
  "statusMessage": "Checking schema migration requirements..."
}
```

## Portability

Project-specific. Edit the script (or fork the hook) if your Drizzle schema lives elsewhere or you use a different migration command.
