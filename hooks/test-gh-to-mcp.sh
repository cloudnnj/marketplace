#!/usr/bin/env bash
# Test suite for pre-tool-use-gh-to-mcp.sh
# Run: .claude/hooks/test-gh-to-mcp.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$SCRIPT_DIR/pre-tool-use-gh-to-mcp.sh"
PASS=0
FAIL=0

make_input() {
  local cmd="$1"
  jq -n --arg cmd "$cmd" '{"tool_input": {"command": $cmd}}'
}

assert_pass_through() {
  local desc="$1"
  local input="$2"
  local output
  output="$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)" || true
  if [[ -z "$output" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc -- expected pass-through (no output), got: $output"
    FAIL=$((FAIL + 1))
  fi
}

assert_denied() {
  local desc="$1"
  local input="$2"
  local expected_mcp="${3:-}"
  local output
  output="$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)" || true
  if [[ -z "$output" ]]; then
    echo "  FAIL: $desc -- expected deny output, got pass-through"
    FAIL=$((FAIL + 1))
    return
  fi
  local decision
  decision="$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision // empty')"
  if [[ "$decision" != "deny" ]]; then
    echo "  FAIL: $desc -- expected decision 'deny', got: $decision"
    FAIL=$((FAIL + 1))
    return
  fi
  if [[ -n "$expected_mcp" ]]; then
    local reason
    reason="$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty')"
    if [[ "$reason" == *"$expected_mcp"* ]]; then
      echo "  PASS: $desc"
      PASS=$((PASS + 1))
    else
      echo "  FAIL: $desc -- expected reason to contain '$expected_mcp', got: $reason"
      FAIL=$((FAIL + 1))
    fi
  else
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  fi
}

assert_valid_json() {
  local desc="$1"
  local input="$2"
  local output
  output="$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)" || true
  if [[ -z "$output" ]]; then
    echo "  SKIP: $desc -- pass-through (no output to validate)"
    return
  fi
  if printf '%s' "$output" | jq . >/dev/null 2>&1; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc -- output is not valid JSON: $output"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Pre-Tool-Use gh-to-MCP Hook Tests ==="
echo ""

# --- gh PR command mapping tests ---
echo "--- gh pr commands (deny with correct MCP tool) ---"

assert_denied "gh pr create" \
  "$(make_input 'gh pr create --title "Fix bug" --body "Details"')" \
  "mcp__github__create_pull_request"

assert_denied "gh pr list" \
  "$(make_input 'gh pr list --state open')" \
  "mcp__github__list_pull_requests"

assert_denied "gh pr view" \
  "$(make_input 'gh pr view 123')" \
  "mcp__github__pull_request_read"

assert_denied "gh pr merge" \
  "$(make_input 'gh pr merge 123 --squash')" \
  "mcp__github__merge_pull_request"

assert_denied "gh pr comment" \
  "$(make_input 'gh pr comment 123 --body "LGTM"')" \
  "mcp__github__add_issue_comment"

assert_denied "gh pr review" \
  "$(make_input 'gh pr review 123 --approve')" \
  "mcp__github__pull_request_review_write"

assert_denied "gh pr edit" \
  "$(make_input 'gh pr edit 123 --title "New title"')" \
  "mcp__github__update_pull_request"

assert_denied "gh pr checks" \
  "$(make_input 'gh pr checks 123')" \
  "mcp__github__pull_request_read"

assert_denied "gh pr close" \
  "$(make_input 'gh pr close 123')" \
  "mcp__github__update_pull_request"

assert_denied "gh pr diff" \
  "$(make_input 'gh pr diff 123')" \
  "mcp__github__pull_request_read"

assert_denied "gh pr ready" \
  "$(make_input 'gh pr ready 123')" \
  "mcp__github__update_pull_request"

assert_denied "gh pr checkout (wildcard fallback)" \
  "$(make_input 'gh pr checkout 123')" \
  "mcp__github__pull_request_read"

assert_denied "gh pr unknown-action (wildcard fallback)" \
  "$(make_input 'gh pr foobar')" \
  "mcp__github__pull_request_read"

echo ""

# --- gh issue command mapping tests ---
echo "--- gh issue commands (deny with correct MCP tool) ---"

assert_denied "gh issue create" \
  "$(make_input 'gh issue create --title "Bug report"')" \
  "mcp__github__issue_write"

assert_denied "gh issue list" \
  "$(make_input 'gh issue list --label bug')" \
  "mcp__github__list_issues"

assert_denied "gh issue view" \
  "$(make_input 'gh issue view 42')" \
  "mcp__github__issue_read"

assert_denied "gh issue comment" \
  "$(make_input 'gh issue comment 42 --body "Working on it"')" \
  "mcp__github__add_issue_comment"

assert_denied "gh issue edit" \
  "$(make_input 'gh issue edit 42 --add-label priority')" \
  "mcp__github__issue_write"

assert_denied "gh issue close" \
  "$(make_input 'gh issue close 42')" \
  "mcp__github__issue_write"

assert_denied "gh issue unknown-action (wildcard fallback)" \
  "$(make_input 'gh issue transfer 42 other/repo')" \
  "mcp__github__issue_read"

echo ""

# --- gh search command mapping tests ---
echo "--- gh search commands (deny with correct MCP tool) ---"

assert_denied "gh search code" \
  "$(make_input 'gh search code "function main" --repo owner/repo')" \
  "mcp__github__search_code"

assert_denied "gh search repos" \
  "$(make_input 'gh search repos "electron"')" \
  "mcp__github__search_repositories"

assert_denied "gh search issues" \
  "$(make_input 'gh search issues "memory leak"')" \
  "mcp__github__search_issues"

assert_denied "gh search prs" \
  "$(make_input 'gh search prs "fix"')" \
  "mcp__github__search_pull_requests"

assert_denied "gh search unknown-type (wildcard fallback)" \
  "$(make_input 'gh search commits "feat"')" \
  "mcp__github__search_code"

echo ""

# --- gh repo command mapping tests ---
echo "--- gh repo commands (deny with correct MCP tool) ---"

assert_denied "gh repo view" \
  "$(make_input 'gh repo view owner/repo')" \
  "mcp__github__search_repositories"

assert_denied "gh repo create" \
  "$(make_input 'gh repo create my-new-repo --public')" \
  "mcp__github__create_repository"

assert_denied "gh repo fork" \
  "$(make_input 'gh repo fork owner/repo')" \
  "mcp__github__fork_repository"

assert_denied "gh repo clone (suggests git clone)" \
  "$(make_input 'gh repo clone owner/repo')" \
  "git clone"

assert_denied "gh repo unknown-action (wildcard fallback)" \
  "$(make_input 'gh repo archive owner/repo')" \
  "mcp__github__search_repositories"

echo ""

# --- gh api command (deny) ---
echo "--- gh api command (deny) ---"

assert_denied "gh api direct REST call" \
  "$(make_input 'gh api /repos/owner/repo/pulls')" \
  "mcp__github__"

echo ""

# --- Unknown gh subcommand (deny with generic guidance) ---
echo "--- Unknown gh subcommand (deny with generic guidance) ---"

assert_denied "gh unknown-cmd denied generically" \
  "$(make_input 'gh browse')" \
  "mcp__github__"

echo ""

# --- Exception commands (pass-through) ---
echo "--- Exception commands (pass-through) ---"

assert_pass_through "gh run view" \
  "$(make_input 'gh run view 12345')"

assert_pass_through "gh run list" \
  "$(make_input 'gh run list')"

assert_pass_through "gh release create" \
  "$(make_input 'gh release create v1.0.0')"

assert_pass_through "gh release list" \
  "$(make_input 'gh release list')"

assert_pass_through "gh workflow run" \
  "$(make_input 'gh workflow run deploy.yml')"

assert_pass_through "gh workflow list" \
  "$(make_input 'gh workflow list')"

assert_pass_through "gh auth login" \
  "$(make_input 'gh auth login')"

assert_pass_through "gh auth status" \
  "$(make_input 'gh auth status')"

assert_pass_through "gh extension install" \
  "$(make_input 'gh extension install owner/ext')"

assert_pass_through "gh gist create" \
  "$(make_input 'gh gist create file.txt')"

assert_pass_through "gh secret set" \
  "$(make_input 'gh secret set MY_SECRET')"

assert_pass_through "gh variable set" \
  "$(make_input 'gh variable set MY_VAR')"

assert_pass_through "gh codespace create" \
  "$(make_input 'gh codespace create')"

assert_pass_through "gh alias set" \
  "$(make_input 'gh alias set co "pr checkout"')"

assert_pass_through "gh completion" \
  "$(make_input 'gh completion -s zsh')"

assert_pass_through "gh status" \
  "$(make_input 'gh status')"

echo ""

# --- Non-GitHub commands (pass-through) ---
echo "--- Non-GitHub commands (pass-through) ---"

assert_pass_through "npm test" \
  "$(make_input 'npm test')"

assert_pass_through "git push" \
  "$(make_input 'git push origin main')"

assert_pass_through "ls" \
  "$(make_input 'ls -la')"

assert_pass_through "Empty command" \
  '{"tool_input": {"command": ""}}'

assert_pass_through "Missing command field" \
  '{"tool_input": {}}'

assert_pass_through "Bare gh (no subcommand)" \
  "$(make_input 'gh')"

echo ""

# --- gh as substring / argument (pass-through) ---
echo "--- gh as substring (pass-through, not a command) ---"

assert_pass_through "gh in git log author" \
  "$(make_input 'git log --author=gh')"

assert_pass_through "grep for gh pattern" \
  "$(make_input 'grep -r "gh" src/')"

# Note: `echo "use gh pr create"` is a known false positive — the hook cannot
# parse shell quoting and sees `gh pr create` as a command invocation. This is
# an acceptable tradeoff since agents rarely echo gh commands as strings.
assert_denied "echo gh string (known false positive)" \
  "$(make_input 'echo "use gh pr create"')" \
  "mcp__github__create_pull_request"

echo ""

# --- Piped/chained gh commands (deny) ---
echo "--- Piped/chained gh commands (deny) ---"

assert_denied "pipe into gh pr create" \
  "$(make_input 'echo body | gh pr create --title "Fix"')" \
  "mcp__github__create_pull_request"

assert_denied "chain with && gh pr list" \
  "$(make_input 'git push && gh pr list')" \
  "mcp__github__list_pull_requests"

assert_denied "chain with ; gh issue view" \
  "$(make_input 'echo done; gh issue view 42')" \
  "mcp__github__issue_read"

assert_denied "subshell gh pr view" \
  "$(make_input '$(gh pr view 123 --json number)')" \
  "mcp__github__pull_request_read"

echo ""

# --- curl/wget to api.github.com (deny) ---
echo "--- curl/wget to api.github.com (deny) ---"

assert_denied "curl to GitHub API" \
  "$(make_input 'curl -H "Authorization: token xxx" https://api.github.com/repos/owner/repo/pulls')" \
  "mcp__github__"

assert_denied "wget to GitHub API" \
  "$(make_input 'wget https://api.github.com/repos/owner/repo/issues')" \
  "mcp__github__"

assert_denied "curl with http (not https)" \
  "$(make_input 'curl http://api.github.com/repos/owner/repo')" \
  "mcp__github__"

echo ""

# --- curl/wget to non-GitHub URLs (pass-through) ---
echo "--- curl/wget to non-GitHub URLs (pass-through) ---"

assert_pass_through "curl to example.com" \
  "$(make_input 'curl https://example.com/api')"

assert_pass_through "curl to github.com (not api.github.com)" \
  "$(make_input 'curl https://github.com/owner/repo')"

assert_pass_through "curl to typosquatted domain" \
  "$(make_input 'curl https://api.github.com.attacker.com/exploit')"

echo ""

# --- JSON output validity ---
echo "--- Output is valid JSON ---"

assert_valid_json "Deny output is valid JSON" \
  "$(make_input 'gh pr create --title "Test"')"

# Verify hookEventName
OUTPUT="$(printf '%s' "$(make_input 'gh pr create')" | bash "$HOOK" 2>/dev/null)" || true
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
