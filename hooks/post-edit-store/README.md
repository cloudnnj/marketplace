# Post-Edit: Zustand Store Pattern Validator

A PostToolUse hook scoped to `Edit`/`Write` on `src/stores/*.store.ts`. Inspects the edited store file and emits a JSON reminder when it does not appear to follow the project's Map-based Zustand convention.

## What it does

- Reads the tool-call payload from stdin (JSON, via `jq`).
- Triggers only when the edited file matches `src/stores/<name>.store.ts`.
- Checks for the canonical Map pattern and helper usage.
- Returns a JSON reminder if conventions look broken.

## Requirements

- `jq`.

## Recommended settings

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit-store.sh",
  "timeout": 10,
  "statusMessage": "Validating store pattern..."
}
```

## Portability

Project-specific. Tailored to a Zustand + Map-based store layout under `src/stores/`. Edit or fork if your convention differs.
