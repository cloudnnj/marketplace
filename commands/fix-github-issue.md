---
title: "Fix GitHub Issue (Interactive)"
description: "Interactive GitHub issue fixing with clarification workflow and automated PR creation"
category: "Bug Fixing"
tags: [github, issue, bugfix, interactive, pr-automation]
version: "2.0"
examples:
  - "/fix-github-issue 42"
  - "/fix-github-issue 123"
---

# Fix GitHub Issue (Interactive)

You are an expert developer fixing GitHub Issue #$ARGUMENTS with an interactive clarification workflow.

**GitHub API Access**: Use the **GitHub MCP tools** for all GitHub interactions. Never use the `gh` CLI or raw `curl` API calls. See the "GitHub API via MCP" section at the end for the tool reference.

### Pre-Flight Checks

1. **Fetch Full Issue Details**
   - Use `mcp__github__issue_read` with `method: "get"`, `owner`, `repo`, `issue_number: $ARGUMENTS`
   - Use `mcp__github__issue_read` with `method: "get_comments"`, `owner`, `repo`, `issue_number: $ARGUMENTS`

2. **Check Issue State**
   - If issue has `awaiting-response` label, this is a follow-up after clarification
   - If issue has `needs-clarification` label but NO new comments, wait for user
   - Otherwise, this is an initial analysis

3. **Check for Existing Work**
   - Search for existing PRs: Use `mcp__github__search_pull_requests` with `query: "Fixes #$ARGUMENTS"`, `owner`, `repo`
   - Search for existing branches: `git branch -r | grep -i "issue-$ARGUMENTS\|$ARGUMENTS"`
   - If PR exists and is open, update it instead of creating new one

### Phase 1: Initial Analysis & Clarification Check

**CRITICAL**: Before attempting ANY fix, you MUST determine if you have enough information.

1. **Analyze the Issue**
   - Read the issue title, body, and all comments carefully
   - Identify what the user is reporting (bug, error, unexpected behavior)
   - Look for reproduction steps, error messages, or screenshots
   - Check which files/components are mentioned or likely involved

2. **Assess Information Completeness**
   Rate the issue clarity (be honest):

   | Criteria | Clear? |
   |----------|--------|
   | What is the expected behavior? | ✅/❌ |
   | What is the actual behavior? | ✅/❌ |
   | Steps to reproduce? | ✅/❌ |
   | Error messages/logs provided? | ✅/❌ |
   | Which component/feature affected? | ✅/❌ |
   | Environment details (if relevant)? | ✅/❌ |

3. **Decision Point**
   - If 4+ criteria are clear: **Proceed to Phase 2 (Investigation)**
   - If <4 criteria are clear: **Proceed to Clarification Request**

### Clarification Request (If Needed)

If the issue lacks sufficient detail, DO NOT GUESS. Instead:

1. **Post a Clarifying Comment**
   Use `mcp__github__add_issue_comment` with `owner`, `repo`, `issue_number: $ARGUMENTS`, and a structured body containing:
   - "Clarification Needed" header
   - 1-3 specific, targeted questions
   - "What I Understand So Far" section summarizing current understanding

2. **Update Labels**
   Use `mcp__github__issue_write` with `method: "update"`, `owner`, `repo`, `issue_number: $ARGUMENTS`, `labels: ["needs-clarification"]`

3. **STOP HERE** - Do not proceed with any fix until clarification is received.

### Phase 2: Investigation (After Clarification or If Issue Is Clear)

If this is a follow-up after clarification:
1. Read the NEW comments since the clarification request
2. Incorporate the new information into your analysis

Proceed with investigation:

1. **Root Cause Analysis**
   - Search the codebase for relevant files
   - Read error-related code paths
   - Identify the specific failure mechanism
   - Document your findings with file:line references

2. **Verify Understanding**
   If still uncertain after investigation, ask ONE more clarifying question and stop.
   Otherwise, proceed to Phase 3.

### Phase 3: Implementation

1. **Version Control (Mandatory)**
   - Ensure you're on the latest main: `git fetch origin && git checkout main && git pull`
   - Create branch: `git checkout -b auto-fix/issue-$ARGUMENTS-<short-description>`
   - Use kebab-case for the short description

2. **Write the Fix**
   - Write the minimal code required to fix the issue
   - Follow existing project patterns (reference CLAUDE.md)
   - Ensure the code compiles/lints: `npm run lint`
   - Do not introduce unrelated changes

3. **Testing**
   - Create or update tests to cover the fix
   - Run the full test suite: `npm test`
   - Ensure ALL tests pass

4. **Commit Changes**
   ```bash
   git add -A
   git commit -m "$(cat <<'EOF'
   fix: <short description>

   <longer description if needed>

   Fixes #$ARGUMENTS

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

5. **Push and Create Pull Request**
   - **CRITICAL**: You must push AND create the PR. Do not stop after git push.
   ```bash
   git push -u origin HEAD
   ```
   Then use `mcp__github__create_pull_request` with:
   - `owner`, `repo`
   - `title: "fix: <concise description>"`
   - `head: "<branch-name>"`
   - `base: "main"`
   - `body`: Include Summary, Issue (Fixes #$ARGUMENTS), Root Cause, Solution, Changes, and Testing sections.

6. **Update Issue**
   Use `mcp__github__add_issue_comment` with `owner`, `repo`, `issue_number: $ARGUMENTS`, and a body summarizing root cause, solution, and PR number.

7. **Clean Up Labels**
   Use `mcp__github__issue_write` with `method: "update"`, `owner`, `repo`, `issue_number: $ARGUMENTS` to update labels (remove `needs-clarification` and `awaiting-response`).

### Error Handling

| Situation | Action |
|-----------|--------|
| Cannot reproduce | Ask for more details, add `needs-clarification` label |
| Too complex/risky | Add `needs-human-review` label, explain in comment |
| Requires breaking changes | Add `needs-human-review` label, do NOT proceed |
| Tests fail (unrelated) | Add `needs-human-review` label, explain |
| Missing dependencies | Add `needs-human-review` label, explain what's needed |

### Label Reference

| Label | Purpose |
|-------|---------|
| `auto-fix` | Triggers auto-fix workflow |
| `needs-clarification` | Waiting for user to provide more info |
| `awaiting-response` | Claude asked questions, waiting for reply |
| `autofix-applied` | PR has been successfully created |
| `fix-attempted` | PR creation was attempted (deprecated, use autofix-applied) |
| `needs-human-review` | Too complex for automated fix |
| `needs-more-info` | Alternative to needs-clarification |
| `dont-fix` | Exclude from auto-fix queue |

### Managing Labels via MCP

- **Add/update labels**: Use `mcp__github__issue_write` with `method: "update"`, `owner`, `repo`, `issue_number`, `labels: ["<label-name>"]`
- **Read current labels**: Use `mcp__github__issue_read` with `method: "get_labels"`, `owner`, `repo`, `issue_number`

### Important Guidelines

- **NEVER GUESS** - If uncertain, ask for clarification
- **Ask focused questions** - 1-3 specific questions, not a laundry list
- **Show your understanding** - Summarize what you know to build trust
- **Minimal changes only** - Fix only what's reported
- **No force push** - Never use `git push --force`
- **Security first** - Never commit secrets or credentials
