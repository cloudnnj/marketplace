#!/usr/bin/env bash
# Test suite for pre-tool-use-relative-paths.sh
# Run: .claude/hooks/test-relative-paths.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$SCRIPT_DIR/pre-tool-use-relative-paths.sh"
PASS=0
FAIL=0

# Use a deterministic fake project dir for tests
export CLAUDE_PROJECT_DIR="/Users/testuser/projects/myapp"

assert_pass_through() {
  local desc="$1"
  local input="$2"
  local output
  output="$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)" || true
  if [[ -z "$output" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc — expected pass-through (no output), got: $output"
    FAIL=$((FAIL + 1))
  fi
}

assert_rewritten() {
  local desc="$1"
  local input="$2"
  local expected_cmd="$3"
  local output
  output="$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)" || true
  if [[ -z "$output" ]]; then
    echo "  FAIL: $desc — expected rewrite output, got pass-through"
    FAIL=$((FAIL + 1))
    return
  fi
  local actual_cmd
  actual_cmd="$(printf '%s' "$output" | jq -r '.hookSpecificOutput.updatedInput.command // empty')"
  if [[ "$actual_cmd" == "$expected_cmd" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    echo "    expected: $expected_cmd"
    echo "    actual:   $actual_cmd"
    FAIL=$((FAIL + 1))
  fi
}

assert_has_warning() {
  local desc="$1"
  local input="$2"
  local output
  output="$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)" || true
  if [[ -z "$output" ]]; then
    echo "  FAIL: $desc — expected warning output, got pass-through"
    FAIL=$((FAIL + 1))
    return
  fi
  local ctx
  ctx="$(printf '%s' "$output" | jq -r '.hookSpecificOutput.additionalContext // empty')"
  if [[ -n "$ctx" ]] && [[ "$ctx" == *"Warning"* ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc — expected additionalContext with Warning, got: $ctx"
    FAIL=$((FAIL + 1))
  fi
}

assert_decision() {
  local desc="$1"
  local input="$2"
  local expected_decision="$3"
  local output
  output="$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)" || true
  if [[ -z "$output" ]]; then
    echo "  FAIL: $desc — expected output, got pass-through"
    FAIL=$((FAIL + 1))
    return
  fi
  local decision
  decision="$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision // empty')"
  if [[ "$decision" == "$expected_decision" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc — expected decision '$expected_decision', got: $decision"
    FAIL=$((FAIL + 1))
  fi
}

make_input() {
  local cmd="$1"
  jq -n --arg cmd "$cmd" '{"tool_input": {"command": $cmd}}'
}

echo "=== Pre-Tool-Use Relative Paths Hook Tests ==="
echo ""

# --- Pass-through tests ---
echo "--- Pass-through (no output expected) ---"

assert_pass_through "Simple command without paths" \
  "$(make_input 'npm test')"

assert_pass_through "Command with relative paths only" \
  "$(make_input 'cat src/stores/task.store.ts')"

assert_pass_through "Command with URL containing slashes" \
  "$(make_input 'curl https://api.example.com/v1/endpoint')"

assert_pass_through "Command with flags containing slashes" \
  "$(make_input 'grep --include=*.ts -r "pattern" .')"

assert_pass_through "Empty command" \
  '{"tool_input": {"command": ""}}'

assert_pass_through "Missing command field" \
  '{"tool_input": {}}'

assert_pass_through "System path /dev/null" \
  "$(make_input 'echo test > /dev/null')"

assert_pass_through "System path /usr/bin/env" \
  "$(make_input '/usr/bin/env node script.js')"

assert_pass_through "System path /tmp" \
  "$(make_input 'cp file.txt /tmp/backup.txt')"

assert_pass_through "System path /opt/homebrew" \
  "$(make_input '/opt/homebrew/bin/jq . file.json')"

echo ""

# --- Rewrite tests ---
echo "--- Rewrite project paths to relative ---"

assert_rewritten "Simple absolute project path" \
  "$(make_input "cat $CLAUDE_PROJECT_DIR/src/foo.ts")" \
  "cat src/foo.ts"

assert_rewritten "Multiple absolute project paths" \
  "$(make_input "diff $CLAUDE_PROJECT_DIR/src/a.ts $CLAUDE_PROJECT_DIR/src/b.ts")" \
  "diff src/a.ts src/b.ts"

assert_rewritten "Project root path becomes dot" \
  "$(make_input "cd $CLAUDE_PROJECT_DIR")" \
  "cd ."

assert_rewritten "Mixed: project path + system path preserved" \
  "$(make_input "cat /dev/null > $CLAUDE_PROJECT_DIR/out.txt")" \
  "cat /dev/null > out.txt"

assert_rewritten "Git add with absolute project path" \
  "$(make_input "git add $CLAUDE_PROJECT_DIR/src/stores/task.store.ts")" \
  "git add src/stores/task.store.ts"

echo ""

# --- Partial path safety tests (issue #2 from review) ---
echo "--- Partial path safety ---"

# Ensure /Users/testuser/projects/myapp-backup is NOT corrupted by partial replacement.
# The hook should warn (since it's an external absolute path) but NOT rewrite it.
assert_has_warning "Similar prefix path warns but does not corrupt" \
  "$(make_input 'ls /Users/otheruser/projects/myapp-backup/file.txt')"

# Verify the command is NOT in updatedInput (no rewrite, just warning)
OUTPUT_PARTIAL="$(printf '%s' "$(make_input 'ls /Users/testuser/projects/myapp-backup/file.txt')" | bash "$HOOK" 2>/dev/null)" || true
UPDATED_CMD="$(printf '%s' "$OUTPUT_PARTIAL" | jq -r '.hookSpecificOutput.updatedInput.command // empty' 2>/dev/null)" || true
if [[ -z "$UPDATED_CMD" ]]; then
  echo "  PASS: Similar prefix path not rewritten (no updatedInput)"
  PASS=$((PASS + 1))
else
  echo "  FAIL: Similar prefix path was incorrectly rewritten to: $UPDATED_CMD"
  FAIL=$((FAIL + 1))
fi

echo ""

# --- Permission decision tests ---
echo "--- Permission decision is always 'allow' ---"

assert_decision "Rewrite still allows execution" \
  "$(make_input "cat $CLAUDE_PROJECT_DIR/src/foo.ts")" \
  "allow"

echo ""

# --- Warning tests ---
echo "--- External absolute path warnings ---"

assert_has_warning "External user path triggers warning" \
  "$(make_input 'cat /Users/someone/secret/file.txt')"

echo ""

# --- Paths with spaces ---
echo "--- Paths with spaces in project dir ---"

# Temporarily set a project dir with spaces (like the real crewdeck path)
ORIGINAL_DIR="$CLAUDE_PROJECT_DIR"
export CLAUDE_PROJECT_DIR="/Users/testuser/Library/Application Support/crewdeck"

assert_rewritten "Project path with spaces" \
  "$(make_input "cat /Users/testuser/Library/Application Support/crewdeck/src/foo.ts")" \
  "cat src/foo.ts"

export CLAUDE_PROJECT_DIR="$ORIGINAL_DIR"

echo ""

# --- Combined rewrite + warning ---
echo "--- Combined rewrite and warning ---"

# Command with both a project path (rewrite) and an external path (warn)
COMBO_OUTPUT="$(printf '%s' "$(make_input "diff $CLAUDE_PROJECT_DIR/src/a.ts /Users/other/file.txt")" | bash "$HOOK" 2>/dev/null)" || true
COMBO_CMD="$(printf '%s' "$COMBO_OUTPUT" | jq -r '.hookSpecificOutput.updatedInput.command // empty')"
COMBO_CTX="$(printf '%s' "$COMBO_OUTPUT" | jq -r '.hookSpecificOutput.additionalContext // empty')"
if [[ "$COMBO_CMD" == "diff src/a.ts /Users/other/file.txt" ]] && [[ "$COMBO_CTX" == *"Warning"* ]]; then
  echo "  PASS: Rewrite + warning on mixed paths"
  PASS=$((PASS + 1))
else
  echo "  FAIL: Rewrite + warning on mixed paths"
  echo "    cmd: $COMBO_CMD"
  echo "    ctx: $COMBO_CTX"
  FAIL=$((FAIL + 1))
fi

echo ""

# --- Unset CLAUDE_PROJECT_DIR ---
echo "--- Missing CLAUDE_PROJECT_DIR ---"

SAVED_DIR="$CLAUDE_PROJECT_DIR"
unset CLAUDE_PROJECT_DIR
assert_pass_through "No project dir set" \
  "$(make_input 'cat /Users/someone/file.txt')"
export CLAUDE_PROJECT_DIR="$SAVED_DIR"

echo ""

# --- Valid JSON output tests ---
echo "--- Output is valid JSON ---"

OUTPUT="$(printf '%s' "$(make_input "cat $CLAUDE_PROJECT_DIR/src/foo.ts")" | bash "$HOOK" 2>/dev/null)" || true
if printf '%s' "$OUTPUT" | jq . >/dev/null 2>&1; then
  echo "  PASS: Output is valid JSON"
  PASS=$((PASS + 1))
else
  echo "  FAIL: Output is not valid JSON: $OUTPUT"
  FAIL=$((FAIL + 1))
fi

# Check hookEventName
EVENT="$(printf '%s' "$OUTPUT" | jq -r '.hookSpecificOutput.hookEventName')"
if [[ "$EVENT" == "PreToolUse" ]]; then
  echo "  PASS: hookEventName is PreToolUse"
  PASS=$((PASS + 1))
else
  echo "  FAIL: hookEventName expected 'PreToolUse', got '$EVENT'"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
