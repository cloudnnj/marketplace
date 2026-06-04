#!/usr/bin/env bash
# PostToolUse hook: Bash — checks coverage thresholds after any test run.
# If coverage/coverage-summary.json exists and any metric is below threshold,
# outputs a JSON block decision showing which metrics are failing.

set -euo pipefail

INPUT="$(cat)"

if ! command -v jq &>/dev/null; then
  exit 0
fi

COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)" || true

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Only act on test-related commands.
if ! [[ "$COMMAND" =~ vitest|npm[[:space:]]test|npm[[:space:]]run[[:space:]]test ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
COVERAGE_FILE="$PROJECT_DIR/coverage/coverage-summary.json"
THRESHOLDS_FILE="$PROJECT_DIR/.github/coverage-thresholds.json"

# Nothing to check if coverage was not generated.
if [[ ! -f "$COVERAGE_FILE" ]]; then
  exit 0
fi

# Only use coverage data if the file was modified in the last 60 seconds,
# to avoid reporting stale results from a prior test run.
if [[ -z "$(find "$COVERAGE_FILE" -mmin -1 2>/dev/null)" ]]; then
  exit 0
fi

# Read thresholds — fall back to spec defaults if file is absent.
if [[ -f "$THRESHOLDS_FILE" ]]; then
  T_STATEMENTS="$(jq -r '.statements // 95' "$THRESHOLDS_FILE")"
  T_BRANCHES="$(jq -r '.branches // 93' "$THRESHOLDS_FILE")"
  T_FUNCTIONS="$(jq -r '.functions // 90' "$THRESHOLDS_FILE")"
  T_LINES="$(jq -r '.lines // 95' "$THRESHOLDS_FILE")"
else
  # Fallback thresholds — source of truth: .github/coverage-thresholds.json and vitest.config.ts
  T_STATEMENTS=95
  T_BRANCHES=93
  T_FUNCTIONS=90
  T_LINES=95
fi

# Extract actual totals from the coverage summary.
ACTUAL_STATEMENTS="$(jq -r '.total.statements.pct // 0' "$COVERAGE_FILE")"
ACTUAL_BRANCHES="$(jq -r '.total.branches.pct // 0' "$COVERAGE_FILE")"
ACTUAL_FUNCTIONS="$(jq -r '.total.functions.pct // 0' "$COVERAGE_FILE")"
ACTUAL_LINES="$(jq -r '.total.lines.pct // 0' "$COVERAGE_FILE")"

# Compare using awk for floating-point arithmetic.
below_threshold() {
  local actual="$1" threshold="$2"
  awk -v a="$actual" -v t="$threshold" 'BEGIN { exit (a < t) ? 0 : 1 }'
}

VIOLATIONS=()

if below_threshold "$ACTUAL_STATEMENTS" "$T_STATEMENTS"; then
  DELTA=$(awk -v a="$ACTUAL_STATEMENTS" -v t="$T_STATEMENTS" 'BEGIN { printf "%.2f", a - t }')
  VIOLATIONS+=("  statements: ${ACTUAL_STATEMENTS}% (threshold ${T_STATEMENTS}%, delta ${DELTA}%)")
fi

if below_threshold "$ACTUAL_BRANCHES" "$T_BRANCHES"; then
  DELTA=$(awk -v a="$ACTUAL_BRANCHES" -v t="$T_BRANCHES" 'BEGIN { printf "%.2f", a - t }')
  VIOLATIONS+=("  branches:   ${ACTUAL_BRANCHES}% (threshold ${T_BRANCHES}%, delta ${DELTA}%)")
fi

if below_threshold "$ACTUAL_FUNCTIONS" "$T_FUNCTIONS"; then
  DELTA=$(awk -v a="$ACTUAL_FUNCTIONS" -v t="$T_FUNCTIONS" 'BEGIN { printf "%.2f", a - t }')
  VIOLATIONS+=("  functions:  ${ACTUAL_FUNCTIONS}% (threshold ${T_FUNCTIONS}%, delta ${DELTA}%)")
fi

if below_threshold "$ACTUAL_LINES" "$T_LINES"; then
  DELTA=$(awk -v a="$ACTUAL_LINES" -v t="$T_LINES" 'BEGIN { printf "%.2f", a - t }')
  VIOLATIONS+=("  lines:      ${ACTUAL_LINES}% (threshold ${T_LINES}%, delta ${DELTA}%)")
fi

if [[ ${#VIOLATIONS[@]} -eq 0 ]]; then
  exit 0
fi

VIOLATION_TEXT="$(printf '%s\n' "${VIOLATIONS[@]}")"

REASON="Coverage thresholds NOT met. The following metrics are below the required minimums:

${VIOLATION_TEXT}

You must write additional tests to bring coverage up before merging. Run:
    npm run test:coverage
to see the full report and identify uncovered lines."

jq -n --arg reason "$REASON" '{"decision":"block","reason":$reason}'
