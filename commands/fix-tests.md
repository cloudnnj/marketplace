---
title: "Fix Tests"
description: "Detect and fix failing tests, coverage violations, and type errors from CI or local execution"
category: "Testing"
tags: [testing, ci, coverage, fix, vitest, typescript, eslint]
version: "2.0"
model: "opus"
examples:
  - "/fix-tests"
  - "/fix-tests PR #415"
  - "/fix-tests Only fix TypeScript errors"
  - "/fix-tests Focus on coverage gaps in src/stores/"
---

# Fix Tests

You are an expert developer specializing in test diagnostics and CI pipeline fixes for this Electron + React + TypeScript project. Your goal is to detect the PR for the current branch, identify all failing checks (tests, coverage, type errors, lint), diagnose root causes, and fix them.

**Scope boundary**: This command fixes CI pipeline failures. For proactive coverage campaigns across many files, use `/increase-coverage`. For runtime bugs reported by users, use `/fix-bug`.

## Input

`$ARGUMENTS` - Optional context: a PR number, a specific test file path, a failure description, or a focus area. If empty, auto-detect the PR from the current branch.

---

## Phase 1: Deterministic Data Collection

> **IMPORTANT**: Phase 1 is purely mechanical data collection. Execute every command
> and capture the FULL output. Do NOT skip commands based on assumptions. Do NOT begin
> analysis, classification, or fixes until Phase 2. This reduces token waste from
> re-reading and backtracking.

### 1a: PR Detection (MANDATORY)

Use the **GitHub MCP tools** for all GitHub interactions. Never use the `gh` CLI or raw `curl` API calls.

If `$ARGUMENTS` contains a PR number, use it directly. Otherwise, detect the PR from the current branch:

```bash
git rev-parse --abbrev-ref HEAD
```

Then call `mcp__github__list_pull_requests` with `owner: "cloudnnj"`, `repo: "crewdeck"`, `head: "cloudnnj:<current-branch>"`, `state: "open"`.

Record the PR number, URL, and base branch (or "none" if no PR exists).

**Why this matters**: The most common invocation of `/fix-tests` is on a feature branch whose PR CI is red. The failures you need to fix are the ones reported on that specific PR's check runs — not unrelated failures on `main`. Every downstream phase must operate against the PR's head commit.

### 1a.1: Fetch PR Details (via GitHub MCP)

Once the PR number is known, fetch full PR details with `mcp__github__pull_request_read`. Do not rely on just the PR number — capture title, base, head SHA, and changed files so Phase 2 can classify failures against actual PR diff:

```
mcp__github__pull_request_read
  method: "get"
  owner: "cloudnnj"
  repo: "crewdeck"
  pullNumber: <PR-number>
```

```
mcp__github__pull_request_read
  method: "get_files"
  owner: "cloudnnj"
  repo: "crewdeck"
  pullNumber: <PR-number>
```

Record PR title, description, base branch, head SHA, and the list of changed files. The changed-files list is especially useful in Phase 3 for deciding "test was NEW vs test was EXISTING" classification.

### 1b: CI Log Retrieval

If a PR was found in step 1a:

- **Get PR check runs**: Use `mcp__github__pull_request_read` with `method: "get_check_runs"`, `owner`, `repo`, `pullNumber` to see CI status and identify failures.
- **Get PR status**: Use `mcp__github__pull_request_read` with `method: "get_status"`, `owner`, `repo`, `pullNumber` for combined commit status.

Capture all CI log output. If the latest run is still in progress, or CI logs are unavailable (permissions, API limits), record "unavailable" and continue to 1c.

### 1c: Local Execution

Run all three CI checks locally **unconditionally** (even if CI logs were retrieved). This adds ~2-5 minutes but ensures data completeness: CI logs may be truncated, stale, or from a different commit than the local working tree.

```bash
# 1. TypeScript type check
npx tsc --noEmit 2>&1

# 2. ESLint
npm run lint 2>&1

# 3. Unit tests with coverage
npm run test:coverage 2>&1
```

Capture the FULL output of each command.

### 1d: Git Diff

```bash
# Changed files summary
git diff main...HEAD --stat

# Full diff
git diff main...HEAD
```

### 1e: Coverage Thresholds

Read `.github/coverage-thresholds.json` and capture its contents.

### Collected Data Summary (populate before proceeding)

```
## PR Info
- PR Number: [number or "none"]
- PR URL: [url or "N/A"]
- CI Status: [pass/fail/in-progress/unavailable]

## CI Check Run Logs (if available)
[paste full CI logs here]

## Local TypeScript Check (`npx tsc --noEmit`)
[paste full output here]

## Local ESLint (`npm run lint`)
[paste full output here]

## Local Test + Coverage (`npm run test:coverage`)
[paste full output here]

## Git Diff Stats (`git diff main...HEAD --stat`)
[paste full output here]

## Git Diff (`git diff main...HEAD`)
[paste full diff here]

## Coverage Thresholds (`.github/coverage-thresholds.json`)
[paste JSON contents here]
```

---

## Phase 2: Failure Classification

Using the data collected in Phase 1, parse all output (CI logs and local execution) and classify each failure into one of these categories:

| Category | Source | Example |
|----------|--------|---------|
| **TypeScript Errors** | `npx tsc --noEmit` | `TS2345: Argument of type 'string' is not assignable...` |
| **ESLint Errors** | `npm run lint` | `error  Unexpected any  @typescript-eslint/no-explicit-any` |
| **Test Assertion Failures** | `npm run test:coverage` | `FAIL src/stores/task.store.test.ts` with assertion mismatches |
| **Test Runtime Errors** | `npm run test:coverage` | Import errors, mock failures, `TypeError` in test execution |
| **Coverage Threshold Violations** | `npm run test:coverage` | Coverage below thresholds from `.github/coverage-thresholds.json` |

For each failure, record:
- **File path** and **line number**
- **Error message**
- **Category** from the table above

Output a structured summary:

```
## Failure Summary

TypeScript Errors: N
ESLint Errors: N
Test Assertion Failures: N
Test Runtime Errors: N
Coverage Violations: N (compare against thresholds from Phase 1)

### Details
[List each failure with file, line, message, category]
```

**Scope guard**: If more than 15 failures are detected, prioritize the first 10-15 (TypeScript errors first, then test failures, then coverage). Report remaining failures for manual review or a follow-up invocation.

---

## Phase 3: Root Cause Analysis & Fix Implementation

Fix failures **in dependency order** -- each layer may resolve issues in the next:

### Step 1: TypeScript Errors (fix first)

TypeScript errors can cause test compilation failures. Read each failing file, understand the type error, and fix the source code.

- Check if the type error is in source code or test code
- Fix type annotations, missing imports, incorrect generics
- Re-run `npx tsc --noEmit` to verify TypeScript errors are resolved before proceeding

### Step 2: ESLint Errors

```bash
# Try auto-fix first
npm run lint -- --fix 2>&1
```

If auto-fix doesn't resolve all errors, manually fix the remaining lint issues. These are typically minor (unused imports, explicit `any` types, formatting).

### Step 3: Test Assertion Failures & Runtime Errors

For each failing test:

1. **Read the failing test file** and the **source file it tests**
2. **Determine which is correct -- the test or the source**:
   - Use the git diff captured in Phase 1 to understand what changed in this PR
   - If the test is NEW (added in this PR) and the source was also changed: the test is likely correct; fix the source
   - If the test is EXISTING and the source was changed in this PR: the source change may have broken the test; update the test to match new behavior OR fix the source if the test caught a real bug
   - If neither test nor source changed in this PR: investigate deeper -- something else may have caused the failure
3. **Apply the fix** following project testing conventions:
   - Vitest with `vi.mock()` for mocking
   - Co-located test files (`*.test.ts` / `*.test.tsx` next to source)
   - Fixtures from `test/fixtures/sample-data.ts`
   - Complete fixtures with all required fields (lesson #9 from CLAUDE.md)
   - New object references for state changes (lesson #5 from CLAUDE.md)

**For complex failures** where the root cause is not evident from the test output, delegate to @"code-debugger (agent)" with the specific failure details.

### Step 4: Coverage Threshold Violations (fix last)

Only after all tests pass, assess coverage:

1. Use the thresholds already captured from `.github/coverage-thresholds.json` in Phase 1
2. Run `npm run test:coverage` and compare actual vs required
3. Identify uncovered files/lines from the coverage output
4. Determine if coverage dropped due to:
   - **New source files without tests** -- Write new tests for the added code
   - **Removed tests or changed test logic** -- Restore or adjust test coverage
   - **Changed source code expanding uncovered branches** -- Add tests for new branches

If the coverage gap is large (requires many new test files for code not in this PR), note this and suggest running `/increase-coverage` instead.

---

## Phase 4: Verification Loop

After applying fixes, verify everything passes. **Maximum 3 iterations.**

```bash
# Iteration N of 3

# 1. TypeScript check
npx tsc --noEmit

# 2. ESLint
npm run lint

# 3. Full test suite with coverage
npm run test:coverage
```

**Decision tree after each iteration:**
- All checks pass: Proceed to Phase 5
- TypeScript errors remain: Fix and re-iterate
- Test failures remain: Analyze new failures (fix may have introduced them), fix, and re-iterate
- Coverage still below thresholds: Add targeted tests and re-iterate
- Iteration 3 reached with remaining failures: Stop, report what was fixed and what remains, suggest manual intervention

**If a fix introduces new failures**: Revert the problematic fix, take a different approach, and re-iterate.

---

## Phase 5: Completion

### Quality Check

Optionally delegate to @"quality-reviewer (agent)" for a quick review if the changeset is large (more than 5 files modified).

### Commit

Commit fixes using conventional commit format:

```bash
# For test-only fixes:
git commit -m "test: fix failing tests and restore coverage

- [list specific fixes applied]
- All CI checks now passing"

# For source code fixes caught by tests:
git commit -m "fix: resolve issues caught by test failures

- [list specific source fixes]
- [list test adjustments if any]
- Coverage thresholds maintained"
```

### Summary

Output a final summary:

```
## Fix Tests Summary

### Failures Found
- TypeScript Errors: N (fixed: N)
- ESLint Errors: N (fixed: N)
- Test Failures: N (fixed: N)
- Coverage Violations: N (resolved: N)

### Changes Made
- [file1.ts]: [description of change]
- [file2.test.ts]: [description of change]

### Verification
- TypeScript: PASS
- ESLint: PASS
- Tests: X passed, 0 failed
- Coverage: statements X%, lines X%, branches X%, functions X%

### Remaining Issues (if any)
- [description of any unresolved failures]
```

---

## Troubleshooting

### Common Patterns

| Issue | Cause | Fix |
|-------|-------|-----|
| `vi.mock()` not working | Mock path doesn't match import path | Use exact relative path from test file |
| Coverage not counting a file | File excluded in `vitest.config.ts` `coverage.exclude` | Check exclusion patterns |
| Test passes locally, fails in CI | Environment difference (macOS vs Ubuntu) | Check for platform-specific behavior in `node-pty`, `better-sqlite3`, `keytar` |
| Flaky test (intermittent failures) | Race condition or timing dependency | Add `waitFor`, remove timing assumptions, ensure test isolation |
| Mock state leaking between tests | Missing `vi.restoreAllMocks()` | Add to `beforeEach` or `afterEach` |
| `Cannot find module` in tests | Missing or incorrect path alias | Check `vitest.config.ts` resolve aliases |
| Coverage drops after adding new files | New source files have no corresponding tests | Write tests or use `/increase-coverage` for large gaps |

### CI vs Local Differences

The CI runs on `ubuntu-latest` while development is typically on macOS. Key differences:
- File system case sensitivity (Linux is case-sensitive, macOS is not by default)
- Native module behavior (`node-pty`, `better-sqlite3`, `keytar`)
- Environment variables and paths

If tests pass locally but fail in CI, flag this as a potential environment-specific issue and investigate the specific failure carefully.
