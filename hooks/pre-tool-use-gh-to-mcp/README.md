# Pre-Tool-Use: gh CLI to GitHub MCP

A PreToolUse hook for `Bash` that intercepts `gh` CLI invocations and `curl`/`wget` calls hitting `api.github.com`, denies them, and instructs Claude to use the equivalent `mcp__github__*` MCP tool.

## What it does

- Reads the tool-call payload from stdin (JSON, via `jq`).
- Detects `gh` invoked as a command (not as a substring of another word).
- Detects `curl`/`wget` targeting `api.github.com`.
- Returns a hook decision blocking the command and pointing Claude to the MCP equivalent.
- Silently passes through (exit 0, no stdout) when the command is unrelated.

## Requirements

- `jq`.
- A GitHub MCP server registered with Claude Code (e.g., `mcp__github__*` tools available).

## Recommended settings

The marketplace install registers the hook with default settings (60s timeout). The source project used 5s, which is sufficient:

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-tool-use-gh-to-mcp.sh",
  "timeout": 5,
  "statusMessage": "Checking for GitHub CLI/API calls..."
}
```

## Portability

Generic — works on any project that has a GitHub MCP server configured.
