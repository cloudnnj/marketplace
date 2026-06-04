# Pre-Commit: Lint and Typecheck

A PreToolUse hook for `Bash` that runs `npm run lint` and `npm run typecheck` before any `git commit`. Exits 2 with the failing output on stderr to block the commit, exits 0 silently when the command is not a commit.

## What it does

- Reads the tool-call payload from stdin (JSON, via `jq`).
- Triggers only when the command starts with `git commit`.
- Runs `npm run lint` and `npm run typecheck` from `$CLAUDE_PROJECT_DIR`.
- Exits 2 (block) with the failing tool's output on stderr if either fails.

## Requirements

- `jq`.
- `npm` with `lint` and `typecheck` scripts defined in `package.json`.

## IMPORTANT — timeout

**The default 60s timeout is too tight.** The source project uses 120s. Bump it after installing:

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-commit-lint.sh",
  "timeout": 120,
  "statusMessage": "Running lint and typecheck before commit..."
}
```

## Portability

Project-specific assumption: your `package.json` must expose `lint` and `typecheck` npm scripts. If yours uses different names (e.g., `eslint`, `tsc`), edit the script after install or fork the hook before publishing.
