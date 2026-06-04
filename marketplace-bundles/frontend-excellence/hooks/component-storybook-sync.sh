#!/usr/bin/env bash
# PostEditRenderer hook: Syncs updated React components with Storybook stories.
# When a component file changes, ensures corresponding story file is updated.

set -euo pipefail

INPUT="$(cat)"

if ! command -v jq &>/dev/null; then
  exit 0
fi

# Extract file path from tool use JSON
FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || true

# Only trigger on React component changes in src/components/
if [[ -z "$FILE" ]] || ! [[ "$FILE" =~ src/components/.*\.tsx$ ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# Extract component name from path (e.g., src/components/my-component/MyComponent.tsx -> MyComponent)
COMPONENT_NAME=$(basename "$FILE" .tsx)
COMPONENT_DIR=$(dirname "$FILE")

# Check if Storybook stories directory exists
if [[ ! -d "${PROJECT_DIR}/src/stories" ]]; then
  echo "component-storybook-sync: Storybook stories directory not found, skipping sync" >&2
  exit 0
fi

STORY_FILE="${PROJECT_DIR}/src/stories/${COMPONENT_NAME}.stories.tsx"

# If story file doesn't exist, suggest creating it
if [[ ! -f "$STORY_FILE" ]]; then
  echo "component-storybook-sync: Consider creating a story for ${COMPONENT_NAME} at ${STORY_FILE}" >&2
  exit 0
fi

# Verify story file imports the updated component (no hard sync, just advisory)
if ! grep -q "from.*${COMPONENT_NAME}" "$STORY_FILE" 2>/dev/null; then
  echo "component-storybook-sync: Story file may not import the updated component" >&2
fi

exit 0
