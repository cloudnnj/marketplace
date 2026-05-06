---
title: "Improve pull request"
description: "Address PR review feedback and ensure compliance with Codacy quality standards"
category: "Code Quality"
tags: [modernization, upgrade, patterns, refactor, codacy]
version: "3.5"
model: "opus"
tools: Read, Grep, Glob, Bash, Edit, Write
examples:
  - "/improve-pr"
  - "/improve-pr 415"
---

# Improve PR

You are an expert sr developer. I want you to address the feedback from the recent Pull Request Code Review.

## Autonomous Execution Contract (READ FIRST)

This command runs **fully autonomously inside the Claude Agent SDK**. There is no interactive user on the other side of this session — the only output channels are:
- File edits (commits + push)
- Comments posted to the GitHub PR via the GitHub MCP

You MUST therefore:
- **Never ask clarifying questions.** Make the most reasonable assumption from the PR review, the plan file, and `CODACY.md`, then proceed.
- **Never offer to schedule follow-up agents, cron jobs, or future runs** (no "want me to /schedule…" / "want me to /loop…" prompts). The `schedule` and `loop` skills are off-limits in this command.
- **Never pause waiting for approval** before merging, escalating, or applying a fix. If a finding is unresolvable, document it in the PR comment posted in Step 5 and exit.
- **Always reach Step 5 (Completion) and exit cleanly.** The only legitimate early-exit is the explicit one in Step 1c (no `/review-pr` comment found yet) — and even then, post the explanatory PR comment before exiting.
- **Do not append closing prose like "let me know if you'd like…" or "next steps for you to consider…"** to the final PR comment. The PR comment is a record, not a conversation.
- **Do not write follow-up TODO files, planning docs, or memory entries** unless an existing rule (e.g., `CODACY.md` Section 10 lessons-learned protocol) explicitly requires it.

If you find yourself drafting a question, a `/schedule` offer, or a "want me to…" sentence, delete it and continue execution instead.

**Before starting, read the quality standards document at the project root:**
- **`CODACY.md`** -- Codacy grade targets, active tool rules (Opengrep/Semgrep, Lizard, Trivy, Biome, ESLint), SRM categories, known false positives (Section 9), and lessons learned from prior `/fix-codacy` runs (Section 10)

### Workflow Instructions

1.  **Analysis**

    The work-list for this command **comes from the PR's review comments**, not from your own re-review. The `/review-pr` command (v5.1+) is the upstream agent that posts those comments; your job is to act on what it found, not to second-guess it.

    1a. **Resolve the PR.**
    - If `$ARGUMENTS` contains a PR number, use it directly.
    - Otherwise, find the open PR for the current branch via `mcp__github__list_pull_requests` with `owner`, `repo`, `head: "<owner>:<branch>"`, `state: "open"`.

    1b. **Fetch every review-feedback stream (FIRST and PRIMARY action).** Pull all three streams in parallel; you need all of them because `/review-pr` may use any of them depending on the GitHub MCP path it took:
    - `mcp__github__pull_request_read` with `method: "get_comments"`, `owner`, `repo`, `pullNumber` -- top-level issue comments (this is where `/review-pr`'s `add_issue_comment` lands)
    - `mcp__github__pull_request_read` with `method: "get_review_comments"`, `owner`, `repo`, `pullNumber` -- inline (file/line) review comments
    - `mcp__github__pull_request_read` with `method: "get_reviews"`, `owner`, `repo`, `pullNumber` -- review submissions (state + body)

    1c. **Pick the authoritative review.** A PR may have multiple `/review-pr` posts. Choose the **most recent** comment whose body contains a `Requirement Conformance Summary` section or severity-tagged findings (Critical / High / Medium / Low) -- that is the latest output of `/review-pr`. Older review comments are superseded; treat them as historical context only.

    If no review comment exists yet, do NOT fabricate work. Stop and post a single comment explaining that `/review-pr` has not run on this PR and exit. Do not start improving from your own analysis -- the contract is: review-pr produces the work-list, improve-pr executes it.

    1d. **Parse the review-pr comment.** Extract:
    - The **Requirement Conformance Summary** (plan path + verdict + requirement-to-code checklist). Any "Missing" entries from this checklist are the highest-priority work; they represent unmet requirements from the originating plan in `prompts/build/<NN>-<slug>.md` or `prompts/bugfix/<NN>-<slug>.md`.
    - The **severity-tagged findings**: Critical, High, Medium, Low. Capture each finding's body, the file:line reference (if present), and any rule/pattern ID it cites (Codacy patterns like `Lizard_ccn-medium`, `Biome_lint_a11y_useButtonType`).
    - Any inline review comments from 1b that target specific file:line locations -- these are equally authoritative.

    1e. **Sanity-check against the originating plan.** If the review comment names a plan path (`prompts/build/<NN>-<slug>.md` or `prompts/bugfix/<NN>-<slug>.md`), read that file with the `Read` tool. The plan is the contract; if a review finding says "requirement X is missing", confirm what X is by reading the plan, then fix it.

    1f. **Cross-reference Codacy rules.** For each finding, map it to the relevant `CODACY.md` section so you fix it in line with project standards: Opengrep/Semgrep security patterns (Section 4.1), Lizard complexity (Section 4.2), ESLint/Biome style (Section 4.3), SRM items (Section 5), Electron-specific concerns (Section 6).

    1g. **Filter false positives.** Check `CODACY.md` Section 9 (13 documented false-positive patterns). If a review finding matches one of these, do NOT fix it -- record it as `Acknowledged false positive (Pattern #N)` for the Step 5 summary and move on.

    1h. **Lessons learned.** Skim `CODACY.md` Section 10 for prior `/fix-codacy` lessons that apply to the patterns you are about to touch.

    1i. **Prioritize.** Order the resulting work-list as:
    1. Conformance gaps from the Requirement Conformance Summary ("Missing" rows) -- these block the PR.
    2. **Critical** findings.
    3. **High** findings.
    4. **Medium** / **Low** findings.

    Do **not** add work that the review did not raise. Scope creep here defeats the point of the review/improve loop. If you spot something obviously wrong while editing, the right move is to fix that one specific thing inline (small) and call it out in Step 5 -- not to expand into a rewrite.

2.  **Implementation**
    - Systematically fix the identified issues by implementing the suggestions.
    - Ensure the code compiles and follows existing project patterns.
    - **Every file change in this step triggers the [Mandatory Re-validation Loop](#mandatory-re-validation-loop-after-any-file-change) (Codacy + tests) before you move on to Step 3.** Do not batch many edits and defer validation to the end — at minimum, re-validate before commit.
    - All fixes MUST comply with `CODACY.md` standards:
      - **Codacy grade target** (Section 2): Maintain grade A (>= 90/100)
      - **Opengrep security rules** (Section 4.1): No unescaped dynamic RegExp, no unvalidated file paths, safe YAML deserialization only, no dynamic method invocation on user strings, no insecure RNG for security-sensitive code
      - **Lizard complexity** (Section 4.2): Cyclomatic complexity <= 15, cognitive complexity <= 15, function NLOC <= 200, file NLOC <= 1000, parameters <= 5
      - **ESLint / Biome style** (Section 4.3): No unused imports, no dead stores, no unnecessary type assertions, no empty functions, no `any` without justification, explicit `<button type="...">`, accessible `<svg>` (aria-hidden or `<title>`), no non-null `!` assertions where optional chaining works, template literals over string concatenation
      - **Electron security** (Section 6): IPC inputs validated via Zod schemas in `ipc-channel-schemas.ts`, parameterized DB queries via Drizzle (no SQL string interpolation), array-based process spawning (no `shell: true`), scoped `contextBridge` exposure (no raw `ipcRenderer`), file paths from user input validated against path traversal, RegExp input escaped via `escapeRegex()`
      - **Known false positives** (Section 9): Do NOT "fix" patterns that are documented false positives -- consult the quick-reject rules
    - **Documentation**: If there is a review document in $ARGUMENTS file, update the file to reflect the status of addressed items (e.g., mark as resolved/completed). If you are working on an actual PR, make a new comment explaining what you have done.

3.  **Testing & Validation**
    - Run existing tests to ensure no regressions.
    - Create or update tests to verify the fixes.
    - Verify that fixes maintain or improve coverage against the project thresholds (authoritative source `.github/coverage-thresholds.json`, also documented in `CODACY.md` Section 7.1):
      - Statements / lines coverage MUST remain >= 95%
      - Branch coverage MUST remain >= 93%
      - Function coverage MUST remain >= 90%
      - No new code duplication
      - Zero new Critical Codacy issues (Section 4.1) and zero new SRM items (Section 5) introduced by the fix
    - **Crucial**: Work with @"quality-reviewer (agent)" to ensure robust test coverage.

4.  **Codacy MCP Analysis (MANDATORY)**
    - After all review-driven fixes and tests pass, run a Codacy analysis via the Codacy MCP on the files you changed in this PR.
    - This step is **blocking**: do not proceed to Step 4-bis until the MCP analysis has completed and any issues it reports have been addressed (or documented as acknowledged false positives).
    - See the "Codacy CLI Analysis Loop" section below for the exact tool invocation, file-scoping rules, false-positive handling, and iteration limits.

4-bis. **Local `codacy-cli` Verification (MANDATORY)**
    - After Step 4 finishes, run the **local `codacy-cli` binary** as the final, authoritative pass before completion. The binary lives at `/opt/homebrew/bin/codacy-cli` (config: `.codacy/codacy.yaml`, configured tools: eslint, lizard, opengrep, pmd, trivy, dartanalyzer, pylint, revive).
    - This is a separate, blocking step from Step 4 — the MCP and the binary may diverge (the binary is what CI and developers actually run), so we use the binary as the source of truth.
    - See the "Local `codacy-cli` Verification Loop" section below for the exact command, output parsing, and iteration cap.

5.  **Completion (autonomous final report — always reached)**
    - **Pre-flight check before exit.** If *any* file changed during this run (Steps 2, 4e, or 4-bis-f), confirm the **Mandatory Re-validation Loop** below has run to completion since the last edit. If it has not, run it now before continuing. You MUST NOT commit or post the final PR comment until the last edit has been validated by both the Codacy CLI (Step 4-bis) and the test suite (Step 3 commands).
    - Commit your changes with a clear, descriptive message using a conventional-commit prefix (`fix:`, `refactor:`, `test:`, `chore:`).
    - Include in the commit message a summary of which Codacy rule violations were addressed, referencing pattern IDs where applicable (e.g., "Fixed `Lizard_ccn-medium` cyclomatic complexity in task.service.ts", "Fixed `Biome_lint_a11y_useButtonType` in TaskCard.tsx").
    - Push the branch (`git push`) so CI picks up the fixes.
    - **Post a single PR comment via `mcp__github__add_issue_comment`** that contains the run summary. The comment is the run's only externally visible output — it is a record, not a conversation. Required sections:
      - **Status** — one of: `Resolved`, `Resolved (acknowledged false positives only)`, or `Partially resolved (deferred findings documented below)`.
      - **Findings addressed** — bullet list of `<severity>: <file:line> <pattern ID> — <one-line summary of fix>`.
      - **Codacy MCP (Step 4)** — files analyzed, issues fixed, acknowledged false positives (with `Pattern #N` from `CODACY.md` Section 9), iterations used.
      - **Codacy CLI (Step 4-bis)** — `codacy-cli` version, SARIF artifact path, fixes applied, iterations used. If the binary was not on `PATH`, surface this here.
      - **Tests** — commands run + result (pass/fail/coverage delta). Coverage thresholds: 95% statements/lines, 93% branches, 90% functions.
      - **Deferred / acknowledged-only findings** — any items not fixed, with file:line + pattern ID + the reason (false positive Section 9 reference, out-of-scope, or unresolvable after iteration cap).
    - Do NOT include trailing prose like "let me know if you'd like…", "next steps for you…", "want me to schedule…". Do NOT offer to open a follow-up PR, schedule a future agent, or loop on this PR. The comment ends with the deferred-findings section.
    - After the comment is posted, the run is complete. Exit.

---

## Mandatory Re-validation Loop (after ANY file change)

This loop is the autonomous safety net for the Autonomous Execution Contract. Whenever you edit, write, or delete a file in this run — whether in Step 2 (review-driven fixes), Step 4e (MCP-driven fixes), or Step 4-bis-f (binary-driven fixes) — you MUST run BOTH of the following before moving on. Do not skip either, even if the edit looks "obviously safe" (formatting, comment, rename).

1. **Codacy re-check** on every file you just modified:
   - Step 4 (MCP): `mcp__codacy__codacy_cli_analyze` per modified file (one call per file; `tool: ""`).
   - Step 4-bis (binary): `codacy-cli analyze --format sarif -o "$TMPDIR/codacy-cli-improve-pr-$(date +%s).sarif" <modified files>`.
   - Both must run after the latest edit. If only one was run, run the other now.
2. **Test re-check**: run `npm test` (or the most narrowly-scoped Vitest invocation that still covers the modified files — e.g., `npx vitest run path/to/file.test.ts` for a single-file edit; `npm test` if multiple unrelated areas changed). Inspect the result.
   - If coverage is in scope (the diff touches `electron/` or `src/`), also run `npm run test:coverage` and confirm thresholds (95/95/93/90) are still met.

Behaviour after the re-check:
- **Clean** → continue to the next workflow step.
- **New Codacy finding introduced by the fix** → treat the new finding as actionable and loop back into Step 4d (MCP) or 4-bis-e (binary) triage. Respect the iteration caps (3 for MCP, 2 for binary). After the cap, document remaining items per Step 4f / 4-bis-g and proceed.
- **Test failure or coverage regression caused by the fix** → fix the test or the code, then re-run the loop. If after **2 fix attempts** the tests still fail because of an issue you cannot resolve autonomously (e.g., the failure is unrelated to the PR's review feedback or pre-exists this PR), document the failure in the Step 5 PR comment with command output + reason and proceed to Step 5. Do NOT pause for user input.

Definition of "any file change": any successful `Edit`, `Write`, or other write tool call against a file under version control. Comment-only edits and whitespace-only edits still count — they can still trip Lizard / Opengrep / ESLint or alter test selection.

---

## Codacy CLI Analysis Loop (Workflow Step 4)

This is a **mandatory, blocking** step. Before posting the PR comment (Step 5), run the Codacy CLI analysis via the Codacy MCP against the files changed in this PR, then fix any actionable issues it reports. Iterate until the analysis is clean or only acknowledged false positives remain.

### 4a: Determine the Analysis File Set

Use the list of files already identified during the PR review analysis in Step 1 (or, if missing, fetch via `mcp__github__pull_request_read` with `method: "get_files"`). Scope analysis to those files only -- **do not** run the CLI against the entire repository.

- Exclude generated / vendored paths: `dist/`, `out/`, `node_modules/`, `electron/database/migrations/*.sql`, `*.lock`, `*.snap`.
- If a fix touched additional files beyond the PR diff (e.g., a shared utility), include those in the analysis set.

### 4b: Invoke `codacy_cli_analyze` (Codacy MCP)

For each file in the analysis set, invoke:

```
mcp__codacy__codacy_cli_analyze
  rootPath: "<absolute project root>"
  file: "<relative file path>"
  tool: ""   # empty = run every configured tool (Opengrep/Semgrep, Lizard, Trivy, ESLint, etc.)
```

Rules:
- Prefer **one call per changed file** -- this is the documented Codacy MCP pattern and keeps output focused.
- If the MCP returns a "tool not available" / "installation in progress" response, wait and retry up to 2 times before falling back. Do **not** skip the step.
- For batches larger than ~15 files, run the MCP calls sequentially and collect results as you go; do not parallelize (the local CLI shares tool state).
- When a fix touches `package.json`, `package-lock.json`, or dependency manifests, also run an analysis pass on that file to pick up Trivy SCA findings.

### 4c: Wait for Results

Each `codacy_cli_analyze` call is synchronous from the MCP's perspective -- the tool does not return until the local CLI finishes that file. Treat the returned payload as the complete result set for that file. If a call times out or returns an incomplete result, re-run it for the same file once before moving on.

Do not proceed to Step 4d until every file in the analysis set has a completed result.

### 4d: Triage Reported Issues

For every issue returned, run this triage in order:

1. **False positive check** -- Cross-reference against the 13 documented false positive patterns in `CODACY.md` Section 9 and the quick-reject rules in `/fix-codacy`. If it matches, log as "Acknowledged false positive (Pattern #N)" and skip.
2. **Out-of-scope check** -- If the issue is on a line that was not introduced or modified by this PR, note it but do not fix it (it is pre-existing; record it for follow-up).
3. **Lessons learned check** -- Consult `CODACY.md` Section 10 to see if a prior run documented the correct approach for this pattern.
4. Otherwise -> **actionable**; plan a fix.

### 4e: Fix Actionable Issues

Apply fixes following the same standards already enforced in Step 2 (`CODACY.md`). For patterns you have not seen before, call `mcp__codacy__codacy_get_pattern` to retrieve the rule description before editing.

After applying fixes:
- Re-run the tests and type/lint checks from Step 3 to ensure no regressions.
- Re-run `codacy_cli_analyze` on the files you just modified (not the full set) to confirm the finding is resolved and no new issues were introduced by the fix.

### 4f: Iteration Limit

Maximum **3 full iterations** of (analyze -> triage -> fix -> re-analyze). After iteration 3:
- If only false-positive or out-of-scope findings remain -> Step 4 is complete. Proceed to Step 5.
- If genuine findings remain that could not be resolved -> stop fixing, **document them explicitly in the Step 5 PR comment** with file:line + pattern ID + the reason the fix could not be applied (e.g., "requires upstream library change", "blocked by failing test that pre-exists this PR"), then proceed to Step 5 and exit. Do **not** silently ignore them, and do **not** pause waiting for human approval — autonomous execution requires the run to terminate.

### 4g: Record Outcome

Capture for the Step 5 summary:
- Files analyzed (count + list)
- New issues found by the CLI (count, by category)
- Issues fixed (pattern IDs + file:line)
- Acknowledged false positives (pattern IDs + Section 9 pattern #)
- Pre-existing / out-of-scope findings deferred to follow-up
- Iterations used

### 4h: Codacy MCP Troubleshooting

| Symptom | Resolution |
|--------|------------|
| `codacy_cli_analyze` returns "CLI not installed" | Re-invoke once; if still failing, report as blocker -- do not skip Step 4 |
| Analysis reports issues in `dist/` or generated files | Exclude from analysis set (see 4a); do not fix |
| Identical finding keeps reappearing after fix | Clear editor caches, verify file was actually written (Read after Edit), re-run analysis on that one file |
| Tool flags a Section 9 false positive | Log with pattern #, skip -- never "fix" a known false positive |
| Iteration 3 still has actionable findings | Document remaining findings in the Step 5 PR comment with file:line + pattern ID + reason the fix could not be applied, then proceed to Step 5 and exit. Do not pause for user input. |

---

## Local `codacy-cli` Verification Loop (Workflow Step 4-bis)

This is a **mandatory, blocking** step that runs **after** Step 4 (MCP) finishes. The goal is to confirm — using the same binary CI uses — that the fixes from Steps 2 and 4 did not introduce any new Codacy issues, and to fix any that slip through.

### 4-bis-a: Confirm the binary is available

```bash
command -v codacy-cli >/dev/null && codacy-cli version
```

If the binary is not on `PATH`, do NOT skip the step — surface it in the PR comment as a verification gap and stop before completion. The expected install path is `/opt/homebrew/bin/codacy-cli` (Homebrew on macOS).

### 4-bis-b: Determine the file set

Use the same file set as Step 4a (PR-changed files plus any additional files modified during fixes), with the same exclusion list (`dist/`, `out/`, `node_modules/`, `electron/database/migrations/*.sql`, `*.lock`, `*.snap`).

### 4-bis-c: Invoke `codacy-cli analyze`

Run **once per analysis pass**, scoped to the file set, with SARIF output written to `$TMPDIR` (sandbox-friendly). Pass all changed files as positional arguments — the binary does NOT operate against the whole repo when files are specified.

```bash
SARIF="$TMPDIR/codacy-cli-improve-pr-$(date +%s).sarif"
codacy-cli analyze --format sarif -o "$SARIF" <file1> <file2> ... 2>&1
```

Rules:
- Do **not** pass `--tool` — let the binary run every tool from `.codacy/codacy.yaml` (eslint, lizard, opengrep, pmd, trivy, etc.).
- A non-zero exit code does NOT mean the command failed — codacy-cli exits 1 when issues are found. Always read the SARIF file; do not rely on exit code alone.
- Long-running analyses (large file sets, trivy SCA passes) can be run with `run_in_background: true` and the SARIF read once it finishes — but do not start the next iteration until the file is complete.
- If `--fix` is desired for trivially-auto-fixable findings (whitespace, formatting), it is allowed, but always re-run the analysis afterward without `--fix` to confirm the fix was applied correctly.

### 4-bis-d: Parse the SARIF result

Read the SARIF file with `Read` and extract the `runs[].results[]` array. For each result, capture:
- `ruleId` (e.g., `ESL0999`, `Lizard.ccn`, `Opengrep.…`) — the pattern ID
- `message.text` — human-readable description
- `locations[0].physicalLocation.artifactLocation.uri` — file
- `locations[0].physicalLocation.region.startLine` — line number
- `level` — `error` / `warning` / `note`

Filter the results to **lines that this PR introduced or modified** (intersect with the diff from Step 1). Issues on untouched lines are pre-existing and out of scope — record them but do not fix them.

### 4-bis-e: Triage

Apply the same triage as Step 4d:
1. False positive check against `CODACY.md` Section 9.
2. Out-of-scope check (line not in PR diff).
3. Lessons-learned check against `CODACY.md` Section 10.
4. Otherwise → actionable.

### 4-bis-f: Fix and re-run

For each actionable finding, apply the fix following Step 2 standards. After applying fixes, re-run `codacy-cli analyze` against only the files you just modified to confirm the finding is resolved and no new findings were introduced.

### 4-bis-g: Iteration limit

Maximum **2 full iterations** of (analyze → triage → fix → re-analyze). After iteration 2:
- If only false-positive or out-of-scope findings remain → Step 4-bis is complete.
- If genuine findings remain → stop fixing, **document them explicitly in the Step 5 PR comment** with file:line + pattern ID + the reason the fix could not be applied, then proceed to Step 5 and exit. Do NOT silently ignore them, and do NOT pause waiting for human approval — autonomous execution requires the run to terminate.

### 4-bis-h: Record outcome

Capture for the Step 5 summary, in addition to the Step 4 outcome:
- Local CLI version (`codacy-cli version` output)
- SARIF artifact path (under `$TMPDIR`)
- New issues found by the binary that the MCP missed (count + pattern IDs)
- Fixes applied during 4-bis (file:line + pattern ID)
- Iterations used in 4-bis

If 4-bis found nothing new beyond Step 4, say so explicitly — that is a clean signal that the MCP and binary agreed.

### 4-bis-i: `codacy-cli` Troubleshooting

| Symptom | Resolution |
|--------|------------|
| `codacy-cli: command not found` | Surface as verification gap in PR comment; do not skip |
| Exit code 1 with empty SARIF | A tool errored before producing output — re-run with `--tool <name>` per tool to isolate which tool failed |
| Tool reports `executionSuccessful: false` in SARIF `invocations` | A tool failed to run (e.g., missing runtime). Note in PR comment but proceed; do not try to fix the user's local install |
| SARIF file not created | Check that `-o` path is under `$TMPDIR`, not `/tmp` (sandbox blocks raw `/tmp`) |
| Identical finding keeps reappearing after fix | Read the file after Edit to confirm the change landed; re-run the binary on that single file |
| Binary disagrees with MCP findings | The binary is the source of truth. Fix per the binary; record the divergence for follow-up on the MCP integration |

---

## GitHub API via MCP

Use the **GitHub MCP tools** for all GitHub interactions. Never use the `gh` CLI or raw `curl` API calls.

### Reading PR Review Comments

- **PR comments**: `mcp__github__pull_request_read` with `method: "get_comments"`, `owner`, `repo`, `pullNumber`
- **PR review comments**: `mcp__github__pull_request_read` with `method: "get_review_comments"`, `owner`, `repo`, `pullNumber`
- **PR reviews (approval/changes requested)**: `mcp__github__pull_request_read` with `method: "get_reviews"`, `owner`, `repo`, `pullNumber`

### Finding the Open PR for the Current Branch

Use `mcp__github__list_pull_requests` with `owner`, `repo`, `head: "<owner>:<branch>"`, `state: "open"`.

### Posting a Comment on PR

Use `mcp__github__add_issue_comment` with `owner`, `repo`, `issue_number: <PR_NUMBER>`, `body: "<comment>"`.
