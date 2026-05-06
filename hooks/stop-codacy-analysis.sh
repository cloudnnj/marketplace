#!/usr/bin/env bash
# Stop hook: runs Codacy CLI against files changed in this session and rewakes
# Claude with any findings so they can be fixed before the session ends.
#
# Design:
#   - Async via asyncRewake: exits 0 when clean, 2 with stderr feedback on findings.
#   - Scoped to changed files (working tree + staged + untracked) to keep
#     analysis fast; full-repo analyze can take minutes.
#   - Honors .codacy/codacy.yaml exclude_paths via codacy-cli itself.

set -euo pipefail

# Read stdin payload to extract session_id for per-session rewake cap.
STOP_INPUT="$(cat || true)"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

# Cap the number of times this hook may rewake Claude per session. After the
# cap is reached, findings are still surfaced (to stderr) but exit 0 so the
# session actually ends instead of looping into more SDK turns.
MAX_REWAKES="${CODACY_STOP_MAX_REWAKES:-1}"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  exit 0
fi

if [[ ! -x ".codacy/cli.sh" ]]; then
  exit 0
fi

TMPROOT="${TMPDIR:-/tmp}"
CHANGED_LIST="$(mktemp "${TMPROOT%/}/codacy-stop-files-XXXXXX")"
SARIF_OUT="$(mktemp "${TMPROOT%/}/codacy-stop-XXXXXX.sarif")"
trap 'rm -f "$CHANGED_LIST" "$SARIF_OUT"' EXIT

# Resolve a per-session attempt counter file. If session_id is missing or jq is
# unavailable we fall back to a single shared counter so the cap still bounds
# loops, just less precisely.
SESSION_ID="$(printf '%s' "$STOP_INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)"
SESSION_ID="${SESSION_ID:-default}"
ATTEMPTS_FILE="${TMPROOT%/}/codacy-stop-attempts-${SESSION_ID}"

# Collect changed files: unstaged, staged, and untracked. Keep only source
# files Codacy's configured tools understand (TS/JS/JSON/YAML).
{
  git diff --name-only HEAD 2>/dev/null || true
  git diff --name-only --staged 2>/dev/null || true
  git ls-files --others --exclude-standard 2>/dev/null || true
} | sort -u | grep -E '\.(ts|tsx|js|jsx|mjs|cjs|json|yaml|yml)$' | \
  grep -Ev '(^|/)(test|node_modules|dist|out|coverage|\.codacy)/' | \
  grep -Ev '\.(test|spec)\.(ts|tsx|js|jsx)$' > "$CHANGED_LIST" || true

# Drop files that no longer exist (e.g., deleted in a subsequent edit).
FILTERED=""
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  [[ -f "$f" ]] || continue
  FILTERED+="$f"$'\n'
done < "$CHANGED_LIST"

if [[ -z "$FILTERED" ]]; then
  exit 0
fi

# Cap to prevent huge codacy runs from delaying Stop-hook feedback.
MAX_FILES=25
FILE_COUNT="$(printf '%s' "$FILTERED" | grep -c . || true)"
if [[ "$FILE_COUNT" -gt "$MAX_FILES" ]]; then
  FILTERED="$(printf '%s' "$FILTERED" | head -n "$MAX_FILES")"
fi

# Build the positional-arg array in a bash 3.2-compatible way.
FILES_ARR=()
while IFS= read -r f; do
  [[ -n "$f" ]] && FILES_ARR+=("$f")
done <<< "$FILTERED"

# Run codacy; ignore exit code — we parse SARIF to decide outcome.
.codacy/cli.sh analyze "${FILES_ARR[@]}" --format sarif -o "$SARIF_OUT" \
  >/dev/null 2>&1 || true

if [[ ! -s "$SARIF_OUT" ]]; then
  exit 0
fi

# Filter findings to the changed-files set (absolute paths → repo-relative).
FILE_REGEX="$(printf '%s|' "${FILES_ARR[@]}" | sed 's/|$//' | sed 's|/|\\/|g')"

FINDINGS_JSON="$(
  jq -r --arg root "$PROJECT_DIR" --arg re "$FILE_REGEX" '
    [ .runs[]? | . as $run
      | (.tool.driver.name // "codacy") as $tool
      | .results[]?
      | . as $r
      | (.locations[0].physicalLocation.artifactLocation.uri // "") as $raw
      | ($raw | sub("^file://"; "") | sub("^" + $root + "/?"; "")) as $file
      | select($file | test($re))
      | {
          tool: $tool,
          file: $file,
          line: (.locations[0].physicalLocation.region.startLine // 0),
          level: (.level // "warning"),
          message: (.message.text // "")
        }
    ]' "$SARIF_OUT" 2>/dev/null || echo '[]'
)"

COUNT="$(printf '%s' "$FINDINGS_JSON" | jq 'length' 2>/dev/null || echo 0)"
if [[ "$COUNT" -eq 0 ]]; then
  exit 0
fi

# Cap the list sent back to Claude so the rewake message stays readable.
MAX_REPORT=20
{
  echo "Codacy found ${COUNT} issue(s) in files changed this session. Fix them before ending the session."
  echo ""
  printf '%s' "$FINDINGS_JSON" | jq -r --argjson max "$MAX_REPORT" '
    .[:$max][]
    | "  [\(.tool)] \(.file):\(.line) \(.level | ascii_upcase) \(.message)"
  '
  if [[ "$COUNT" -gt "$MAX_REPORT" ]]; then
    echo ""
    echo "...and $((COUNT - MAX_REPORT)) more. Run \`.codacy/cli.sh analyze --format sarif\` for the full report."
  fi
  echo ""
  echo "Tip: \`.codacy/cli.sh analyze <file> --fix\` auto-fixes what it can."
} >&2

# Per-session rewake cap: only exit 2 (which triggers asyncRewake) for the
# first MAX_REWAKES attempts. After that, surface findings as advisory and
# exit 0 so the session can actually end. Reset the counter by starting a new
# Claude session (each session_id gets its own file).
PRIOR_ATTEMPTS=0
if [[ -f "$ATTEMPTS_FILE" ]]; then
  PRIOR_ATTEMPTS="$(cat "$ATTEMPTS_FILE" 2>/dev/null || echo 0)"
  [[ "$PRIOR_ATTEMPTS" =~ ^[0-9]+$ ]] || PRIOR_ATTEMPTS=0
fi

if [[ "$PRIOR_ATTEMPTS" -ge "$MAX_REWAKES" ]]; then
  echo "" >&2
  echo "Codacy rewake cap reached (${PRIOR_ATTEMPTS}/${MAX_REWAKES}). Findings above are advisory; session will end." >&2
  exit 0
fi

printf '%s' "$((PRIOR_ATTEMPTS + 1))" > "$ATTEMPTS_FILE"
exit 2
