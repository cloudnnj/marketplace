#!/usr/bin/env bash
# PostToolUse hook: Edit|Write — blocks imports of 'electron' and 'node:*'
# modules in src/** files. Renderer code must use the preload bridge (window.api),
# never Node.js or Electron APIs directly.

set -euo pipefail

INPUT="$(cat)"

if ! command -v jq &>/dev/null; then
  exit 0
fi

FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || true

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only check files under src/ (renderer process code).
# Exclude mcp-servers/ — those are standalone Node.js servers, not the Electron renderer.
if ! [[ "$FILE_PATH" == */src/* ]]; then
  exit 0
fi
if [[ "$FILE_PATH" == */mcp-servers/* ]]; then
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Scan for forbidden imports: electron or node:* modules.
# Catches: ES module imports, CommonJS require(), side-effect imports, and dynamic import().
VIOLATIONS="$(grep -nE "(from\s+['\"]electron['\"]|from\s+['\"]node:[^'\"]+['\"]|require\(\s*['\"]electron['\"]|require\(\s*['\"]node:[^'\"]+['\"]|import\s+['\"]electron['\"]|import\s+['\"]node:[^'\"]+['\"]|import\(\s*['\"]electron['\"]|import\(\s*['\"]node:[^'\"]+['\"])" "$FILE_PATH" 2>/dev/null)" || true

if [[ -z "$VIOLATIONS" ]]; then
  exit 0
fi

BASENAME="$(basename "$FILE_PATH")"

REASON="BLOCKED: Renderer import boundary violation in ${BASENAME}.

The following lines import 'electron' or 'node:*' modules, which is forbidden in src/** files:

${VIOLATIONS}

Renderer code must NEVER import electron or Node.js built-in modules directly.
Use the preload bridge instead:
  - Access IPC via window.api (e.g., window.api.tasks.list(...))
  - See electron/preload/index.ts for available APIs
  - See shared/types.ts for type definitions
  - Add new channels following the IPC checklist in .claude/rules/ipc.md

This is a core architectural rule: Component -> Store -> window.api (IPC) -> Handler -> Service"

jq -n --arg reason "$REASON" '{"decision":"block","reason":$reason}'
