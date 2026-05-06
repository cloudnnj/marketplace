---
title: "Review Pull Request"
description: "Comprehensive PR code review analyzing quality, bugs, performance, security, and testing against Codacy standards"
category: "Code Quality"
tags: [review, pr, code-review, quality-assurance, security, codacy]
version: "5.1"
tools: Read, Grep, Glob, Bash
model: "sonnet"
examples:
  - "/review-pr 123"
  - "/review-pr Focus on security concerns"
---

# Review Pull Request

You are an expert engineer. Please review this pull request and provide feedback on $ARGUMENTS

Use the repository's CLAUDE.md for guidance on style and conventions. Be constructive and helpful in your feedback.

---

## Execution Contract (READ FIRST)

This command runs **non-interactively** under model `sonnet`. CrewDeck does not currently support interactive sessions for this command, so any prompt back to the user will halt automation.

You MUST:

- **Never ask the user a question.** Do not say "would you like me to...", "should I...", "do you want me to...". Make the call yourself based on the data you have.
- **Never write, edit, or create files.** No `Edit`, `Write`, or `NotebookEdit`. No staging, committing, pushing, branching, or any git mutation.
- **Never offer to implement fixes.** A separate `/improve-pr` agent picks up your feedback. Your job ends when the review comment is posted.
- **Always post the review.** The single deliverable of this command is a review comment posted to the PR via the GitHub MCP. If you cannot determine the PR, post a comment explaining what was missing -- do not bail out silently and do not ask for clarification.
- **Stay read-only.** Allowed tools: `Read`, `Grep`, `Glob`, `Bash` (read-only commands like `npx tsc --noEmit`), and the GitHub MCP read/comment methods listed at the bottom of this file.

If the user's `$ARGUMENTS` is ambiguous (e.g. "Focus on security concerns" with no PR number), detect the PR from the current branch and proceed -- do not ask which PR they meant.

---

## Phase 1: Deterministic Data Collection

> **IMPORTANT**: Phase 1 is purely mechanical data collection. Execute every command
> and capture the FULL output. Do NOT skip commands based on assumptions. Do NOT begin
> analysis, classification, or fixes until Phase 2. This reduces token waste from
> re-reading and backtracking.

### 1a: PR Detection

If `$ARGUMENTS` contains a PR number, use it directly. Otherwise, detect the PR from the current branch using `mcp__github__list_pull_requests` with `owner`, `repo`, `head: "<owner>:<branch>"`, `state: "open"`.

### 1b: PR Metadata

Use `mcp__github__pull_request_read` with `method: "get"`, `owner`, `repo`, `pullNumber` to fetch PR title, author, description, base/head branches.

### 1c: PR Diff and Files

- **PR diff**: `mcp__github__pull_request_read` with `method: "get_diff"`, `owner`, `repo`, `pullNumber`
- **PR files changed**: `mcp__github__pull_request_read` with `method: "get_files"`, `owner`, `repo`, `pullNumber`

### 1c-bis: Originating Plan File (Requirement Source of Truth)

Every CrewDeck PR is built against an implementation plan persisted by the `/refine-prompt` + `/validate-architecture` pipeline at:

- `prompts/build/<NN>-<slug>.md` — feature plans
- `prompts/bugfix/<NN>-<slug>.md` — bug-fix plans

Recover the plan that originated this PR. Use the steps below in order; stop at the first one that yields exactly one match.

1. **From the PR file list (preferred).** In the `get_files` result from 1c, filter for entries whose `filename` starts with `prompts/build/` or `prompts/bugfix/` and whose status is `added`. If exactly one matches, that is the plan file.
2. **From git history on the branch.** If step 1 yields nothing, run:
   ```bash
   git log --name-only --diff-filter=A --pretty=format: <base>..<head> -- prompts/build prompts/bugfix
   ```
   substituting the PR's base and head refs (`base` and `head` from 1b). The most recent unique result is the plan file. If multiple plan files were added in the PR's commit range, fetch all of them and treat the set as the requirement.
3. **From the PR title or body.** If steps 1–2 are empty, scan the PR title and description for an explicit `prompts/build/...md` or `prompts/bugfix/...md` reference and read that file.
4. **Fallback: explicit branch-name match.** Branch names typically include the plan slug (e.g. `feature/sdlc` → look for `prompts/build/*sdlc*.md`). If exactly one file matches, use it.
5. **No plan found.** If steps 1–4 all fail, do NOT abort. Record `Originating plan: NOT FOUND` in the data summary, then in Phase 2 flag this as a **High** finding ("PR does not appear to be backed by a plan in `prompts/`; cannot verify against original requirement") and continue with the rest of the review.

Once located, read the plan file with the `Read` tool. The plan is the source of truth for what was supposed to be built.

### 1d: Quality Standards Documents

Read both quality standards documents from the project root:
- **`CODACY.md`** -- Codacy grade targets, active tool rules (Opengrep/Semgrep, Lizard, Trivy, Biome), SRM categories, known false positives (Section 9), and lessons learned from prior `/fix-codacy` runs (Section 10)
- **`CLAUDE.md`** -- Project conventions, architecture patterns, lessons learned

### 1e: TypeScript Check (optional)

```bash
npx tsc --noEmit 2>&1
```

### PR Review Data Summary (populate before proceeding)

```
## PR Info
- PR Number: [number]
- PR URL: [url]
- Title: [title]
- Author: [author]
- Base Branch: [base] ← Head Branch: [head]
- Description: [PR body]

## PR Diff
[paste full diff here]

## PR Files Changed
[list all changed files with change type (added/modified/deleted)]

## Originating Plan File
- Path: [prompts/build/<NN>-<slug>.md | prompts/bugfix/<NN>-<slug>.md | NOT FOUND]
- Discovery method: [PR file list | git log | PR description | branch name | NOT FOUND]
- Plan contents: [paste full contents, or "NOT FOUND" if discovery failed]

## CODACY.md Contents
[paste full contents or key sections]

## CLAUDE.md Contents
[paste full contents or key sections]

## TypeScript Check (`npx tsc --noEmit`) (optional)
[paste full output or "skipped"]
```

---

## Phase 2: Code Review Analysis

Using the data collected in Phase 1, analyze the PR against all review areas below. Where a check overlaps with Codacy tooling, the corresponding `CODACY.md` section is referenced.

### 0. Requirement Conformance (originating plan)

This check is the most important one in the review. The plan in `prompts/build/<NN>-<slug>.md` or `prompts/bugfix/<NN>-<slug>.md` (recovered in Phase 1c-bis) is the contract the PR must satisfy. Compare the PR diff against it section by section.

For feature plans (`prompts/build/`):
- **Requirements** -- every bullet must be satisfied by the diff. Quote the requirement and cite the file/line that satisfies it. Anything unsatisfied is a finding.
- **Affected Files** -- every file the plan said would change MUST appear in the diff (or the plan must explicitly say it became unnecessary). Files in the diff that the plan did not anticipate are not automatically wrong, but call out scope creep.
- **Technical Approach** -- the implementation must follow the approach the plan described. If the PR took a materially different path (different abstraction, different layering, different IPC channel, different store helper), call it out -- it may be the right call, but it is a deviation that needs to be acknowledged.
- **Acceptance criteria / coverage targets** -- if the plan specified thresholds (e.g. "maintain 95/93/90"), verify them from the diff and tests.

For bug-fix plans (`prompts/bugfix/`):
- **Root cause** -- does the diff actually address the root cause the plan identified, or is it patching a symptom?
- **Regression test coverage** -- the plan should call for a test that would have caught the bug. Confirm that test exists in the diff.
- **Verification steps** -- if the plan listed manual or scripted verification steps, confirm the diff supports them.

Classify findings:
- **Critical / High** -- requirement missed, root cause not addressed, regression test missing.
- **Medium** -- material deviation from the plan's technical approach without a documented reason.
- **Low** -- minor scope creep beyond the plan, or polish items the plan did not explicitly request.

If the plan was NOT FOUND in Phase 1c-bis, surface a single **High** finding here ("Cannot verify against an originating plan; `prompts/build` and `prompts/bugfix` were not updated and no plan path was referenced") and proceed with the rest of the review on its own merits.

### 1. Code Quality and Best Practices

- Code follows project conventions from CLAUDE.md
- TypeScript strict mode compliance -- no untyped `any` without justification (Biome `noExplicitAny`, `CODACY.md` Section 4.3)
- Functional React components with hooks (no class components)
- Zustand Map-based store pattern followed
- Tailwind CSS utility-first styling (no separate CSS files)
- Import order: React/framework, third-party, internal, types

### 2. Potential Bugs and Reliability

| Check | Notes |
|-------|-------|
| Functions MUST NOT be empty | ESLint `@typescript-eslint/no-empty-function` (`CODACY.md` Section 4.3) |
| Functions MUST NOT have identical implementations | Manual review |
| Conditions MUST NOT unconditionally evaluate to true or false | Manual review |
| Boolean expressions MUST NOT be gratuitous | Manual review |
| Dead stores -- no unused assignments | ESLint `@typescript-eslint/no-unused-vars` (`CODACY.md` Section 4.3) |
| `useEffect` dependencies MUST be correct | Manual review against the React Hooks rules |
| Unstable component props -- no objects/arrays created in render | Manual review (re-render hazard, see CLAUDE.md Lesson #5) |

### 3. Performance Considerations

- No unnecessary re-renders (check reference equality per CLAUDE.md lessons learned #5)
- No unbounded string/array growth (lessons learned #15)
- Efficient data structures and algorithms
- No blocking operations on the main thread

### 4. Security Vulnerabilities

| Check | Codacy Reference |
|-------|------------------|
| Pseudorandom number generators MUST NOT be used for security purposes | `Semgrep_rules_lgpl_javascript_crypto_rule-node-insecure-random-generator` (`CODACY.md` Section 4.1) |
| Cryptographic keys MUST be robust | `CODACY.md` Section 6 (Electron and Node.js Security) |
| Regular expressions MUST NOT be vulnerable to ReDoS | `Semgrep_javascript_dos_rule-non-literal-regexp` + `CODACY.md` Section 6.6 |
| Expanding archive files MUST be done safely (no zip slip) | Manual review against `path.resolve` + base-dir allowlist |
| Path traversal in dynamic file paths | `Semgrep_javascript_pathtraversal_rule-non-literal-fs-filename` (`CODACY.md` Section 6.5) |
| Dynamic method invocation on user-controlled strings | `Semgrep_javascript.lang.security.audit.unsafe-dynamic-method` |
| YAML deserialization MUST use safe schema | `CODACY.md` Section 9.3 (`yaml.JSON_SCHEMA`) |

### 5. Test Coverage

- New/changed code has corresponding tests
- Tests cover edge cases and error conditions
- Test fixtures include all required fields with sensible defaults (Lesson #9)
- Coverage on new code meets the project's Vitest thresholds: 95% statements, 95% lines, 93% branches, 90% functions (`CODACY.md` Section 7.1, authoritative source `.github/coverage-thresholds.json`)

### 6. Code Smells and Maintainability

Per `CODACY.md` Section 4.2 (Lizard) and Section 4.3 (ESLint / Biome):

| Check | Threshold |
|-------|-----------|
| Cyclomatic complexity per function | MUST NOT exceed 15 |
| Cognitive complexity per function | MUST NOT exceed 15 |
| Function length (NLOC) | SHOULD NOT exceed 200 lines |
| File length (NLOC) | SHOULD NOT exceed 1000 lines |
| Function parameter count | SHOULD NOT exceed 5 |
| Unused imports | MUST be removed (ESLint `no-unused-vars`) |
| Unnecessary type assertions | MUST be removed (ESLint `no-unnecessary-type-assertion`) |
| Non-null assertion `!` | Prefer optional chaining or explicit guard (Biome `noNonNullAssertion`) |
| String concatenation where a template literal would be clearer | Biome `useTemplate` |

### 7. TypeScript and React Specific

- Components MUST use PascalCase
- Deprecated React lifecycle methods MUST NOT be used
- Unnecessary JSX fragments SHOULD be removed
- `<button>` elements MUST have an explicit `type` attribute (Biome `useButtonType`, `CODACY.md` Section 4.3)
- `<svg>` elements MUST be accessible: `aria-hidden="true"` for decorative icons, `<title>` only when the SVG conveys meaning independently (Biome `noSvgWithoutTitle`)

### 8. Duplications

- Flag any duplicated code blocks introduced or expanded by the PR
- Prefer extracting shared helpers when three or more sites converge on the same logic; below that, duplication can be acceptable per CLAUDE.md (YAGNI)

---

## Electron and Node.js Security

Per `CODACY.md` Section 6, check the following Electron-specific concerns:

**IPC Handler Security (`CODACY.md` Section 6.1):**
- All user-controlled input flowing through IPC MUST be validated at the handler boundary via Zod schemas in `ipc-channel-schemas.ts`
- Unused Electron event parameters MUST be prefixed with underscore (`_`)
- `withServiceResult` middleware wraps all handler responses

**SQL Injection (`CODACY.md` Section 6.2):**
- All database queries MUST use Drizzle ORM query builder or parameterized prepared statements
- No string interpolation in SQL queries

**Command Injection (`CODACY.md` Section 6.3):**
- All process spawning MUST use array-based arguments (not shell strings)
- `shell: true` MUST NOT be used in spawn options
- Input passed to `spawnSync` or `node-pty` MUST be validated against an allowlist (see `command-security.service.ts`, `shell-validation.ts`)

**Context Bridge (`CODACY.md` Section 6.4):**
- Only scoped IPC methods exposed via `contextBridge`
- Raw `ipcRenderer` MUST NOT be exposed to the renderer process

**File System Access (`CODACY.md` Section 6.5):**
- File paths constructed from user input MUST be validated against path traversal (`path.resolve` + `path.normalize` + allowed-base check)
- Internal file operations using `app.getPath('userData')` are safe and should not be flagged

**Dynamic RegExp (`CODACY.md` Section 6.6):**
- User-derived input MUST be escaped before `new RegExp(...)` (e.g., `escapeRegex()`)
- Avoid unbounded quantifiers on user-controlled portions

---

## Codacy Known False Positives

Per `CODACY.md` Section 9, do NOT flag the following patterns as issues:

- **Dynamic file paths from `app.getPath()`** -- System-controlled paths, not user input (`CODACY.md` Section 9.1)
- **Dynamic RegExp with `escapeRegex()`** -- Input is escaped before construction (`CODACY.md` Section 9.2)
- **YAML load with `JSON_SCHEMA`** -- Safe schema prevents code execution (`CODACY.md` Section 9.3)
- **Private key regex pattern** -- Pattern for *detecting* keys, not a hardcoded key (`CODACY.md` Section 9.4)
- **Dynamic method on `window.api`** -- Fixed API surface from preload bridge (`CODACY.md` Section 9.5)
- **All 13 patterns from `CODACY.md` Section 9 summary table** -- including ES-X rules, wrong-language tools, `child_process` in terminal files, etc.
- **Unused IPC event `_` parameter** -- Required by the Electron `ipcMain.handle()` API signature
- **Zustand Map-based stores** -- Intentional architectural pattern for O(1) lookup by parent ID
- **Drizzle ORM `.$type<T>()`** -- Type-safe API for JSON column type narrowing, not an unsafe assertion
- **Dynamic `require()` for native modules** -- Required in Electron preload/worker contexts; import paths are static strings

Also check `CODACY.md` **Section 10: Lessons Learned** for pitfalls from prior `/fix-codacy` runs that may apply to this PR.

---

## Phase 3: Review Output

Structure the review comment as follows:

1. **Requirement Conformance Summary (lead with this).** A short section at the top stating: the originating plan path (or `NOT FOUND`), a one-line verdict (`Conforms` / `Conforms with deviations` / `Does not conform`), and a checklist mapping each requirement bullet from the plan to the file/line that satisfies it (or "Missing").
2. **Findings by severity.** Then list findings using these levels:
   - **Critical** -- Must fix before merge (security vulnerabilities, data loss risks, requirement missed in a way that breaks the feature)
   - **High** -- Should fix before merge (bugs, reliability issues, missing regression test for a bug-fix plan)
   - **Medium** -- Recommended improvements (code smells, maintainability, undocumented deviation from the plan's technical approach)
   - **Low** -- Optional suggestions (style, minor optimizations, scope creep beyond the plan)

When citing a Codacy rule, use the pattern ID from `CODACY.md` (e.g., `Semgrep_javascript_dos_rule-non-literal-regexp`, `Lizard_ccn-medium`, `Biome_lint_a11y_useButtonType`). When citing a requirement gap, quote the bullet from the plan file and reference the plan path.

---

## Hard Constraints (REPEAT)

- **DO NOT** commit, push, branch, or otherwise mutate the repo. No `Edit`/`Write` tools. No `git` mutations via `Bash`.
- **DO NOT** ask the user any question. No confirmations, no "would you like me to...", no "should I implement this?". A different agent (`/improve-pr`) handles fixes.
- **DO NOT** offer to implement, refactor, or open follow-up PRs. Your output is review feedback only.
- **DO** post the review as a PR comment via the GitHub MCP -- this is the single required side effect of the command.

---

## GitHub API via MCP

Use the **GitHub MCP tools** for all GitHub interactions. Never use the `gh` CLI or raw `curl` API calls.

### Reading PR Details

- **PR metadata**: `mcp__github__pull_request_read` with `method: "get"`, `owner`, `repo`, `pullNumber`
- **PR files changed**: `mcp__github__pull_request_read` with `method: "get_files"`, `owner`, `repo`, `pullNumber`
- **PR diff**: `mcp__github__pull_request_read` with `method: "get_diff"`, `owner`, `repo`, `pullNumber`
- **PR comments**: `mcp__github__pull_request_read` with `method: "get_comments"`, `owner`, `repo`, `pullNumber`
- **PR review comments**: `mcp__github__pull_request_read` with `method: "get_review_comments"`, `owner`, `repo`, `pullNumber`

### Posting a Review Comment on the PR

Use `mcp__github__add_issue_comment` with `owner`, `repo`, `issue_number: <PR_NUMBER>`, `body: "<review comment>"`.

For inline review comments, use `mcp__github__pull_request_review_write` with `method: "create"`, `event: "COMMENT"`, and provide the review body.
