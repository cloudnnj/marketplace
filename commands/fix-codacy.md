---
title: "Fix Codacy Issues"
description: "Retrieve Codacy issues via Codacy MCP, fix them, and push via GitHub MCP"
category: "Code Quality"
tags: [codacy, code-quality, security, bugs, code-smells, mcp]
version: "1.0"
model: "sonnet"
examples:
  - "/fix-codacy"
  - "/fix-codacy Only fix bugs and vulnerabilities"
  - "/fix-codacy Focus on src/stores/"
---

# Fix Codacy Issues

You are an expert developer specializing in code quality and security. Your goal is to retrieve the latest Codacy analysis issues using the Codacy MCP server, fix them in the codebase, and commit/push using the GitHub MCP server.

**Before starting, read `CODACY.md` at the project root for the full set of enforceable quality and security standards.** This includes grade targets, tool configuration, rule categories, known false positives (13 documented patterns in Section 9), and lessons learned from prior runs (Section 10). Also reference `docs/audits/codacy-false-positive-analysis-2026-03-25.md` for detailed false positive evidence.

## Input

`$ARGUMENTS` - Optional focus area: a specific category (e.g., "bugs", "vulnerabilities", "code smells", "security"), a file path or directory to scope fixes, or a severity filter. If empty, fix all issues starting from highest severity.

## Environment

| Variable | Purpose |
|----------|---------|
| `CODACY_ACCOUNT_TOKEN` | Codacy API authentication |
| `GH_TOKEN` | GitHub API authentication (used by GitHub MCP server) |

## MCP Servers Used

| Server | Tools Prefix | Purpose |
|--------|-------------|---------|
| **Codacy MCP** | `mcp__codacy__*` | Retrieve issues, grade, coverage, security items from Codacy |
| **GitHub MCP** | `mcp__github__*` | Create branches, commit files, push changes, create PRs |

---

## Phase 0: Detect Current PR (MANDATORY FIRST STEP)

**Before querying Codacy, always check whether the current branch has an open PR and scope the run to that PR.** The most common invocation is on a feature branch with a PR showing Codacy failures — fix those first, not repo-wide issues.

### 0a: Get Current Branch

```bash
git rev-parse --abbrev-ref HEAD
```

If the branch is `main`, skip to Phase 1 and treat this as a repo-wide cleanup run.

### 0b: Find the PR for the Current Branch (via GitHub MCP)

Use the GitHub MCP to find the open PR whose `head` matches the current branch:

```
mcp__github__list_pull_requests
  owner: "cloudnnj"
  repo: "crewdeck"
  head: "cloudnnj:<current-branch>"
  state: "open"
```

Record the PR number and URL. If `$ARGUMENTS` explicitly passes a PR number, use that instead.

### 0b.1: Fetch PR Details (via GitHub MCP)

Once the PR number is known, use `mcp__github__pull_request_read` to fetch full details. Capture everything relevant for scoping fixes:

```
mcp__github__pull_request_read
  method: "get"
  owner: "cloudnnj"
  repo: "crewdeck"
  pullNumber: <PR-number>
```

```
mcp__github__pull_request_read
  method: "get_files"            # list of changed files (inform file-scoped Codacy queries)
  owner: "cloudnnj"
  repo: "crewdeck"
  pullNumber: <PR-number>
```

```
mcp__github__pull_request_read
  method: "get_check_runs"       # see which CI checks (incl. Codacy) are failing
  owner: "cloudnnj"
  repo: "crewdeck"
  pullNumber: <PR-number>
```

```
mcp__github__pull_request_read
  method: "get_status"           # combined commit status
  owner: "cloudnnj"
  repo: "crewdeck"
  pullNumber: <PR-number>
```

Record: PR title, description, base branch, head SHA, list of changed files, and which checks (especially Codacy-related) are failing. Use the changed-files list to narrow Codacy `codacy_get_file_issues` calls in Phase 1c — do not waste queries on files outside the PR diff.

### 0c: Scope Mode Decision

| Condition | Mode | Behavior |
|-----------|------|----------|
| PR found for current branch | **PR-scoped** | Query Codacy for issues on the PR only (`pullRequest: <number>`). Fix only those issues. |
| No PR, on feature branch | **Branch-scoped** | Query Codacy for issues introduced on this branch vs `main` |
| On `main` or no PR and no diff | **Repo-wide** | Query Codacy across the whole repository (Phase 1 default) |

**Default assumption**: if a PR exists, the user wants those specific PR findings fixed. Report this mode in the summary (Phase 5e).

---

## Phase 1: Retrieve Codacy Issues via MCP

### 1a: Project Configuration

Organization: `cloudnnj`, Repository: `crewdeck`. Use these for all Codacy MCP queries.

**In PR-scoped mode (from Phase 0c)**: Pass the `pullRequest` / `pullRequestNumber` parameter to every Codacy MCP query below so results are scoped to the PR. Use `mcp__codacy__codacy_list_pull_request_issues` (or equivalent PR-issues tool) in place of `mcp__codacy__codacy_list_repository_issues` when available.

### 1b: Get Repository Grade and Analysis Summary

Use the Codacy MCP server to check the current repository grade:

```
mcp__codacy__codacy_get_repository_with_analysis
  provider: "gh"
  remoteOrganizationName: "cloudnnj"
  repositoryName: "crewdeck"
```

Extract:
- **Grade** (A-F letter grade + numeric score, e.g., "C (59/100)")
- **Analysis summary** (issues count, complexity, duplication, coverage)

### 1c: Get Issues List

Use the Codacy MCP server to retrieve open issues:

```
mcp__codacy__codacy_list_repository_issues
  provider: "gh"
  remoteOrganizationName: "cloudnnj"
  repositoryName: "crewdeck"
```

If `$ARGUMENTS` specifies a category filter, narrow the query accordingly:
- "bugs" -> filter to Bug category issues
- "vulnerabilities" -> filter to Vulnerability/Security category issues
- "code smells" -> filter to Code Style/Complexity category issues
- "security" -> filter to Security category issues

If `$ARGUMENTS` specifies a directory/file path, use `mcp__codacy__codacy_get_file_issues` to scope to that path:

```
mcp__codacy__codacy_get_file_issues
  provider: "gh"
  remoteOrganizationName: "cloudnnj"
  repositoryName: "crewdeck"
  fileId: "<relative-file-path>"
```

For detailed information on a specific issue, use:

```
mcp__codacy__codacy_get_issue
  provider: "gh"
  remoteOrganizationName: "cloudnnj"
  repositoryName: "crewdeck"
  issueId: "<issue-id>"
```

### 1d: Get Security Risk Management Items

```
mcp__codacy__codacy_search_repository_srm_items
  provider: "gh"
  remoteOrganizationName: "cloudnnj"
  repositoryName: "crewdeck"
```

### 1e: Get Coverage and Duplication Metrics

For file-level coverage:

```
mcp__codacy__codacy_get_file_coverage
  provider: "gh"
  remoteOrganizationName: "cloudnnj"
  repositoryName: "crewdeck"
  fileId: "<relative-file-path>"
```

For code duplication (clones):

```
mcp__codacy__codacy_get_file_clones
  provider: "gh"
  remoteOrganizationName: "cloudnnj"
  repositoryName: "crewdeck"
  fileId: "<relative-file-path>"
```

### 1f: Get Rule Details (when needed)

To understand what a specific Codacy pattern expects before fixing:

```
mcp__codacy__codacy_get_pattern
  provider: "gh"
  remoteOrganizationName: "cloudnnj"
  repositoryName: "crewdeck"
  patternId: "<pattern-id>"
```

---

## Phase 2: Issue Classification & Prioritization

Organize all discovered issues into a structured summary:

```
## Codacy Issues Summary

Grade: [letter] ([score]/100)
Repository: cloudnnj/crewdeck

### Issues by Severity
- Critical: N
- Medium: N
- Minor: N

### Issues by Category
- Bugs (Reliability): N
- Vulnerabilities (Security): N
- Code Smells (Maintainability): N
- Security (SRM Items): N
- Duplications: N files affected
- Coverage Gaps: N files below threshold

### Detailed Issue List
[File, line, pattern ID, severity, category, message]
```

**Priority order for fixing:**
1. **Critical** bugs and vulnerabilities (highest impact on grade)
2. **Medium** bugs and vulnerabilities
3. **Security SRM items** (require review/fix)
4. **Critical/Medium** code smells (especially complexity violations)
5. **Duplications** above threshold
6. **Minor** issues

**Scope guard**: If `$ARGUMENTS` specifies a focus area, filter the issue list accordingly. If more than 20 issues exist, prioritize the top 15 and report remaining for follow-up.

---

## Phase 3: Fix Implementation

Fix issues **in priority order**, following the standards in `CODACY.md` and cross-checking every issue against the false positive patterns below before attempting a fix.

### 3a: False Positive Check (MANDATORY)

Before fixing ANY issue, check if it matches one of the 13 known false positive patterns from `CODACY.md` Section 9 (also documented in `docs/audits/codacy-false-positive-analysis-2026-03-25.md`):

| # | Pattern | Rule/Tool | Action |
|---|---------|-----------|--------|
| 1 | ES-X compatibility rules (`es-x_no-*`) | ESLint 8 defaults | **SKIP** -- Electron 41 supports all modern features |
| 2 | Secret detection in test fixtures | `gitleaks.*`, `generic-api-key` | **SKIP** -- test files use well-known example credentials |
| 3 | Hard-coded password on key names | `codacy.javascript.security.hard-coded-password` | **SKIP** -- triggers on storage key name constants, not passwords |
| 4 | No-stringify-keys | `Semgrep_javascript.lang.correctness.no-stringify-keys` | **SKIP** -- JSON serialization for IPC/storage, not key comparison |
| 5 | Unsafe format string in logging | `Semgrep_javascript.lang.security.audit.unsafe-formatstring` | **SKIP** -- no user-controlled format strings in desktop app |
| 6 | Wrong framework rules | FlowType, `react-in-jsx-scope`, LWC, Mocha | **SKIP** -- wrong type system/framework/test runner |
| 7 | Wrong language analyzers | PMD, dartanalyzer, pylint, revive | **SKIP** -- project is 100% TypeScript, no Java/Dart/Python/Go |
| 8 | ESLint version mismatch | Codacy ESLint 8 vs project ESLint 10 | **SKIP** -- root cause of patterns #1 and #6 |
| 9 | `dangerouslySetInnerHTML` XSS | `react-dangerouslysetinnerhtml` (Semgrep) | **SKIP** -- both usages guarded by sanitization functions |
| 10 | `child_process` usage | `child-process-or-exec`, `detect-child-process` | **SKIP** -- inherent to Electron/terminal architecture |
| 11 | `no-stringify-keys` in production | Same as #4 | **SKIP** -- JSON serialization for IPC, logging, SQLite, HTTP |
| 12 | Hardcoded URLs | URL detection patterns | **SKIP** -- public API endpoints (GitHub, Codacy, Jira) |
| 13 | Catch block error handling | Various empty/unused catch rules | **SKIP** -- `withServiceResult` middleware pattern handles errors |

**Decision tree for each issue:**
1. Does the pattern ID or rule name match any of the 13 false positive patterns above? -> **SKIP**, log as "Acknowledged false positive"
2. Is the flagged file a test file AND the rule is secret detection, stringify-keys, or URL detection? -> **SKIP**
3. Otherwise -> proceed with fix

### 3b: Bugs (Reliability)

For each genuine bug:
1. Read the flagged file and understand the context
2. Use `mcp__codacy__codacy_get_pattern` to understand what the rule expects
3. Identify the root cause (logic error, null dereference, resource leak, etc.)
4. Fix the source code following project patterns
5. Verify the fix does not introduce regressions

### 3c: Vulnerabilities (Security)

For each genuine vulnerability:
1. Read the flagged file and identify the security concern
2. Use `mcp__codacy__codacy_get_pattern` to understand the expected fix
3. Apply the secure alternative:
   - **SQL injection**: Use Drizzle ORM query builder or parameterized statements
   - **Command injection**: Use array-based arguments, no `shell: true`
   - **Insecure randomness**: Use `crypto.randomBytes()` instead of `Math.random()` for security contexts
   - **ReDoS**: Rewrite vulnerable regex patterns
4. Verify the fix maintains functionality

### 3d: Code Smells (Maintainability)

For each genuine code smell:
1. Read the flagged file and understand the issue
2. Use `mcp__codacy__codacy_get_pattern` to understand what the rule expects
3. Apply the appropriate refactoring:
   - **Cyclomatic complexity**: Extract helper functions, use early returns, simplify conditionals
   - **Cognitive complexity**: Flatten nesting, extract well-named functions, use guard clauses
   - **Unused imports**: Remove them
   - **Dead stores**: Remove unused assignments
   - **Unnecessary type assertions**: Remove redundant `as Type` casts
4. Ensure refactored code follows project conventions

### 3e: Security SRM Items

For each SRM item:
1. Read the flagged code and the Codacy rationale
2. Determine if it is a **true positive** or matches a known false positive (check the table in 3a)
3. If true positive: apply the secure alternative
4. If false positive: document why it is safe (add a brief comment if the code is non-obvious)

### 3f: Duplications

For duplicated blocks (identified via `mcp__codacy__codacy_get_file_clones`):
1. Identify the duplicated code segments
2. Extract into a shared utility function or module
3. Replace all duplicate occurrences with calls to the shared function
4. Ensure the shared function is well-named and co-located appropriately

---

## Phase 4: Verification

After applying all fixes, verify everything still works. **Maximum 3 iterations.**

```bash
# 1. TypeScript check
npx tsc --noEmit

# 2. ESLint
npm run lint

# 3. Full test suite with coverage
npm run test:coverage
```

**Decision tree after each iteration:**
- All checks pass: Proceed to Phase 5
- TypeScript errors: Fix type issues and re-iterate
- Test failures: Analyze if fix introduced regression, adjust and re-iterate
- Coverage dropped: Add tests for refactored code and re-iterate
- Iteration 3 reached with remaining failures: Stop, report what was fixed and what remains

**If a fix introduces test failures**: Revert the problematic fix, take a different approach, and re-iterate.

---

## Phase 5: Commit & Push via GitHub MCP

### 5a: Repository Info

Use the constants from Phase 1a: `OWNER=cloudnnj`, `REPO=crewdeck`.

### 5b: Branch Strategy

Use the PR scope mode from Phase 0c to decide where fixes land:

| Mode | Action |
|------|--------|
| **PR-scoped** | Push fixes directly to the existing PR branch (current branch). Do NOT create a new branch or new PR. |
| **Branch-scoped** (feature branch, no PR yet) | Push to the current branch and create a PR against `main`. |
| **Repo-wide** (on `main`) | Create a new branch `fix/codacy-issues` using `mcp__github__create_branch` and open a PR from it. |

### 5c: Commit Changes via GitHub MCP

Stage and commit all changed files. For each changed file, use the GitHub MCP to push the file content:

```
mcp__github__push_files
  owner: "<OWNER>"
  repo: "<REPO>"
  branch: "<current-branch-or-fix-branch>"
  files: [{ "path": "<file-path>", "content": "<file-content>" }, ...]
  message: "fix: resolve Codacy quality issues\n\n- [list specific fixes with pattern IDs]\n\nCo-Authored-By: Claude <noreply@anthropic.com>"
```

**Important**: Read the content of each modified file and include it in the `files` array. Group related changes into a single commit when possible. If more than 10 files are changed, split into multiple `push_files` calls to avoid API limits (e.g., batch by domain: services, stores, components).

### 5d: Pull Request Handling

- **PR-scoped mode**: Do not create a new PR. Optionally add a comment on the existing PR summarizing the fixes (via `mcp__github__add_issue_comment`).
- **Branch-scoped / Repo-wide mode**: Create a PR via `mcp__github__create_pull_request`:

```
mcp__github__create_pull_request
  owner: "<OWNER>"
  repo: "<REPO>"
  title: "fix: resolve Codacy quality issues"
  body: "## Summary\n\n- Fixed N Codacy issues (bugs, vulnerabilities, code smells)\n- All CI checks passing\n- Grade improvement expected\n\n## Issues Fixed\n\n[table of fixed issues with pattern IDs]\n\n## False Positives Acknowledged\n\n[table of skipped issues with false positive pattern #]\n\n## Verification\n\n- TypeScript: PASS\n- ESLint: PASS\n- Tests: all passing\n- Coverage: meets thresholds"
  head: "<current-branch-or-fix-branch>"
  base: "main"
```

### 5e: Summary

Output a final summary:

```
## Fix Codacy Summary

### Repository Grade
- Current: [letter] ([score]/100)
- Expected after fix: [letter] ([score]/100)

### Issues Fixed
- Bugs: N fixed (pattern IDs)
- Vulnerabilities: N fixed (pattern IDs)
- Code Smells: N fixed (pattern IDs)
- Security SRM Items: N reviewed/fixed
- Duplications: N resolved

### False Positives Acknowledged
- Pattern #1 (ES-X rules): N issues skipped
- Pattern #N (description): N issues skipped
- Total skipped: N

### Changes Made
- [file1.ts]: [description of change] (pattern ID)
- [file2.ts]: [description of change] (pattern ID)

### Verification
- TypeScript: PASS
- ESLint: PASS
- Tests: X passed, 0 failed
- Coverage: statements X%, lines X%, branches X%, functions X%

### Pull Request
- PR URL: <link to created PR>

### Remaining Issues (if any)
- [description of unresolved issues and recommended next steps]

### Codacy Dashboard
View full analysis: https://app.codacy.com/gh/cloudnnj/crewdeck/dashboard
```

### 5f: Update CODACY.md (MANDATORY)

`CODACY.md` is the living standards document that downstream commands (`/review-pr`, `/improve-pr`) read to enforce Codacy compliance. You MUST update it after every run so those commands have current data.

**Always update these sections:**

1. **Section 2.3: Current Status** -- Update grade, issue counts, coverage, SRM counts with the values retrieved in Phase 1. **Only update if values have actually changed** from what is currently documented to avoid noisy diffs on every run.

2. **Section 4: Rule Categories** -- If new pattern IDs were encountered that are not already documented, add them to the appropriate subsection (4.1 Security, 4.2 Complexity, 4.3 Code Style).

3. **Section 5: SRM** -- Update the SRM category counts and priority breakdown with current data from Phase 1d.

**Conditionally update these sections:**

4. **Section 9: Known False Positives** -- If a new false positive pattern was discovered that is not in the 13 documented patterns, add it with a new pattern number, rule/tool, confidence level, and rationale. Also update `docs/audits/codacy-false-positive-analysis-2026-03-25.md`.

5. **Section 10: Lessons Learned** -- If you encountered non-obvious issues (fixes that broke tests, MCP quirks, patterns requiring a different approach), append a lesson:

```markdown
### L[N]: [Short title] ([today's date])

**Issue:** What happened
**Root cause:** Why it happened
**Fix:** What the correct approach is
**Applies to:** Which patterns/rules this affects
```

6. **Section 6: Electron and Node.js Security** -- If a fix introduced a new safe pattern or security approach, document it in the relevant subsection so `/review-pr` knows not to flag it.

---

## Known False Positives

Before fixing an issue, check if it matches a known false positive from `CODACY.md` Section 9 and `docs/audits/codacy-false-positive-analysis-2026-03-25.md`. The full list of 13 patterns is in the Phase 3a table above.

**Quick-reject rules** (skip immediately without further analysis):
- Any `es-x_no-*` rule -> Pattern #1
- Any `gitleaks.*` rule in a test file -> Pattern #2
- `codacy.javascript.security.hard-coded-password` on a constant ending in `_KEY` or `_TOKEN` -> Pattern #3
- `no-stringify-keys` anywhere -> Pattern #4 or #11
- `unsafe-formatstring` in logging/console calls -> Pattern #5
- FlowType, `react-in-jsx-scope`, LWC, or Mocha rules -> Pattern #6
- Any issue from PMD, dartanalyzer, pylint, or revive tools -> Pattern #7
- `react-dangerouslysetinnerhtml` where a sanitize function is called -> Pattern #9
- `child-process-or-exec` or `detect-child-process` in terminal/git/agent files -> Pattern #10
- Hardcoded URL pointing to a known public API -> Pattern #12
- Empty/unused catch in a `withServiceResult`-wrapped handler -> Pattern #13

If an issue matches a known false positive, skip it and note it in the summary as "Acknowledged false positive (Pattern #N)."

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|---------|
| Codacy MCP returns no issues | Org/repo name mismatch or no recent analysis | Verify org is `cloudnnj` and repo is `crewdeck` |
| MCP tool not available | MCP server not configured | Check Claude settings for Codacy/GitHub MCP server configuration |
| GitHub MCP push fails | Branch protection or permissions | Check `GH_TOKEN` has `repo` scope |
| Grade unchanged after fixes | Codacy re-analysis not yet triggered | Wait for Codacy to re-analyze the branch |
| Fix breaks existing tests | Refactoring changed behavior | Revert and take a smaller, safer approach |
| Coverage drops after removing dead code | Removed code was previously covered | Verify coverage thresholds still met |
| Too many files to push in one commit | GitHub API file limit | Split into multiple `push_files` calls |
| Most issues are false positives | ESLint 8 mismatch or wrong-language tools | Focus only on genuine issues; report false positive count in summary |
