#!/usr/bin/env bash
# PostToolUse hook: Edit|Write — reminds Claude to keep shared/types.ts in sync
# with the preload context bridge and IPC channel definitions.

set -euo pipefail

INPUT="$(cat)"

if ! command -v jq &>/dev/null; then
  exit 0
fi

FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || true

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

if ! [[ "$FILE_PATH" == *"shared/types.ts" ]]; then
  exit 0
fi

REASON="You just edited shared/types.ts. Verify the following before proceeding:

1. Preload sync — if you added new types used in IPC:
       Check electron/preload/index.ts and ensure they are imported and exposed on window.api.

2. window.api surface — if you added new methods or namespaces:
       Update the contextBridge.exposeInMainWorld call in electron/preload/index.ts.

3. IPC channels — if you added or renamed entries in IPCChannels:
       Register matching ipcMain.handle() calls in electron/ipc/handlers.ts.

4. Data-flow reminder:
       React Component -> Zustand Store -> window.api (IPC) -> Electron Handler -> Service -> SQLite
   New types must be consistent across ALL layers.

5. Renderer-only types belong in src/types/, not shared/types.ts.

If none of the above apply to your edit, you may continue."

jq -n --arg reason "$REASON" '{"decision":"block","reason":$reason}'
