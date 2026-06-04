# Post-Edit: Renderer Import Boundary

A PostToolUse hook registered on `Edit|Write`. The script self-filters to files under `src/**` (and excludes `mcp-servers/` standalone Node services). Blocks imports of `electron` and `node:*` modules in renderer code, enforcing the preload-bridge boundary.

## What it does

- Reads the tool-call payload from stdin (JSON, via `jq`).
- Exits silently when the edited file is not under `src/`.
- Scans the file for `from 'electron'`, `require('electron')`, or `node:*` imports.
- Emits a JSON decision block when a forbidden import is found, telling Claude to route the call through `window.api` instead.

## Requirements

- `jq`.

## Recommended settings

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit-renderer-imports.sh",
  "timeout": 10,
  "statusMessage": "Checking renderer import boundary..."
}
```

## Portability

Project-specific. Tailored to an Electron app where renderer code lives under `src/`. If your renderer is elsewhere (e.g., `renderer/`, `client/`), edit the script after install.
