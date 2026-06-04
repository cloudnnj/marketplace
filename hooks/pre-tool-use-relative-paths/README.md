# Pre-Tool-Use: Relative Paths

A PreToolUse hook for `Bash` that intercepts shell commands containing absolute paths under `$CLAUDE_PROJECT_DIR` and rewrites them to relative paths.

## What it does

- Reads the tool-call payload from stdin (JSON, via `jq`).
- Scans the `command` for absolute paths starting with `$CLAUDE_PROJECT_DIR`.
- Emits a hook response that replaces matched paths with their relative forms, preventing full system paths from leaking into command history or external services.
- Silently passes through (exit 0, no stdout) when no absolute paths are found.

## Requirements

- `jq` (used to parse the tool-input JSON).
- `$CLAUDE_PROJECT_DIR` set by Claude Code (always populated during hook execution).

## Recommended settings

The marketplace install registers the hook with default settings (60s timeout). The original timing in the source project was 5s — fast and safe. After install you can lower the timeout in `.claude/settings.json`:

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-tool-use-relative-paths.sh",
  "timeout": 5,
  "statusMessage": "Enforcing relative paths..."
}
```

## Portability

Generic — no project-specific assumptions. Works on any repo that uses Claude Code.
