#!/bin/bash
# Post-edit hook: warns if docs file isn't in directory index
# Triggered on Edit(docs/**/*.md) and Write(docs/**/*.md)

FILE="$1"
DIR=$(dirname "$FILE")
BASENAME=$(basename "$FILE")

# Skip index files themselves
if [[ "$BASENAME" == "INDEX.md" ]] || [[ "$BASENAME" == "index.md" ]] || [[ "$BASENAME" == "README.md" ]]; then
  exit 0
fi

# Check for index file in directory
INDEX=""
for idx in "$DIR/INDEX.md" "$DIR/index.md" "$DIR/README.md"; do
  if [ -f "$idx" ]; then
    INDEX="$idx"
    break
  fi
done

# If no index file, check parent
if [ -z "$INDEX" ]; then
  PARENT=$(dirname "$DIR")
  for idx in "$PARENT/INDEX.md" "$PARENT/index.md" "$PARENT/README.md"; do
    if [ -f "$idx" ]; then
      INDEX="$idx"
      break
    fi
  done
fi

# Warn if file not referenced in index
if [ -n "$INDEX" ] && ! grep -q "$BASENAME" "$INDEX" 2>/dev/null; then
  echo "WARNING: $BASENAME is not referenced in $INDEX. Consider updating the index."
fi

exit 0
