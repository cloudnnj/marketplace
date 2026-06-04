# Post-Edit: Docs Index Reminder

A PostToolUse hook scoped to `Edit`/`Write` on `docs/**/*.md`. Warns Claude when the edited file isn't referenced from a directory index (`INDEX.md`, `index.md`, or `README.md`) in the same or parent directory.

## What it does

- Accepts the edited file path as `$1` (positional argument).
- Skips itself for `INDEX.md`, `index.md`, and `README.md`.
- Walks up the docs tree looking for an index file that references the edited document.
- Emits a warning to stderr if no reference is found.

## Recommended settings

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit-docs-index.sh",
  "timeout": 5,
  "statusMessage": "Checking docs index references..."
}
```

## Portability

Generic — works on any repo where docs live under `docs/` and follow an INDEX/README convention.
