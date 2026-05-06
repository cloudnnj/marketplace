#!/usr/bin/env bash
# PostToolUse hook: Edit|Write — validates that a Zustand store file follows
# the project's required Map-based pattern.

set -euo pipefail

INPUT="$(cat)"

if ! command -v jq &>/dev/null; then
  exit 0
fi

FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || true

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only act on files matching src/stores/*.store.ts
BASENAME="$(basename "$FILE_PATH")"
DIRNAME="$(dirname "$FILE_PATH")"

if ! [[ "$BASENAME" == *.store.ts ]] || ! [[ "$DIRNAME" == */src/stores ]]; then
  exit 0
fi

# The file must exist and be readable to validate.
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

CONTENT="$(cat "$FILE_PATH")"

# Allow stores to opt out of Map-based pattern validation with a comment.
if printf '%s' "$CONTENT" | grep -q "claude-hook:skip-store-validation"; then
  exit 0
fi

VIOLATIONS=()

# 1. Must import from 'zustand'.
if ! printf '%s' "$CONTENT" | grep -q "from 'zustand'"; then
  VIOLATIONS+=("  - Missing: import { create } from 'zustand' (or similar zustand import)")
fi

# 2. Must use Map-based state keyed by parent ID.
if ! printf '%s' "$CONTENT" | grep -qE "Map<string,"; then
  VIOLATIONS+=("  - Missing: Map<string, ...> state — stores must use Map keyed by parent ID (e.g., projectId)")
fi

# 3. Must declare a loading flag.
if ! printf '%s' "$CONTENT" | grep -qE "loading:\s*boolean"; then
  VIOLATIONS+=("  - Missing: loading: boolean field in store interface")
fi

# 4. Must declare a typed error field.
if ! printf '%s' "$CONTENT" | grep -qE "error:\s*string \| null"; then
  VIOLATIONS+=("  - Missing: error: string | null field in store interface")
fi

if [[ ${#VIOLATIONS[@]} -eq 0 ]]; then
  exit 0
fi

VIOLATION_TEXT="$(printf '%s\n' "${VIOLATIONS[@]}")"

REASON="Store pattern violations found in ${BASENAME}:

${VIOLATION_TEXT}

All Zustand stores must follow the project pattern (see task.store.ts for reference):

  interface EntityState {
    entities: Map<string, Entity[]>  // keyed by parent ID
    loading: boolean
    error: string | null
    loadEntities: (parentId: string) => Promise<void>
    createEntity: (data: CreateEntity) => Promise<Entity>
  }

Fix the violations above before proceeding."

jq -n --arg reason "$REASON" '{"decision":"block","reason":$reason}'
