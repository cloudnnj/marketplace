# Post-Edit: Shared Types Preload Sync Reminder

A PostToolUse hook registered on `Edit|Write`. The script self-filters: it only acts when the edited file path ends in `shared/types.ts`. Returns a JSON reminder pointing Claude at the preload bridge and IPC channel definitions so type changes stay in sync.

## What it does

- Reads the tool-call payload from stdin (JSON, via `jq`).
- Exits silently when the edited file is not `shared/types.ts`.
- Otherwise emits a JSON reminder listing the verification steps (preload sync, IPC channel update, etc.).

## Requirements

- `jq`.

## Recommended settings

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit-types.sh",
  "timeout": 10,
  "statusMessage": "Checking types-preload sync..."
}
```

## Portability

Project-specific. Tailored to an Electron + IPC + preload architecture where `shared/types.ts` is the cross-process type barrel. Edit or fork if your project structures types elsewhere.
