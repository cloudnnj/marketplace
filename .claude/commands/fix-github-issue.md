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

### Pre-Flight Checks

1. **Fetch Full Issue Details**
   Run this command to get complete issue context:
   ```bash
   gh issue view $ARGUMENTS --json title,body,labels,comments,assignees,state
   ```

2. **Check Issue State**
   - If issue has `awaiting-response` label, this is a follow-up after clarification
   - If issue has `needs-clarification` label but NO new comments, wait for user
   - Otherwise, this is an initial analysis

3. **Check for Existing Work**
   - Search for existing PRs: `gh pr list --search "Fixes #$ARGUMENTS" --state all`
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
   Create a structured, friendly comment asking for specific information:

   ```bash
   gh issue comment $ARGUMENTS --body "## 🔍 Clarification Needed

   Hi! I'm analyzing this issue and need a bit more information to provide an accurate fix.

   ### Questions

   <Ask 1-3 specific, targeted questions. Examples:>

   1. **[Question about reproduction]** Can you provide the exact steps to reproduce this issue?
   2. **[Question about expected behavior]** What should happen instead of the current behavior?
   3. **[Question about context]** Which page/component were you on when this occurred?

   ### What I Understand So Far

   <Summarize your current understanding to show you've read the issue>

   - You're experiencing: <brief description>
   - This appears to affect: <component/feature>
   - Potential area of investigation: <your hypothesis>

   ---
   ⏳ *I'll continue with the fix once you provide these details. Just reply to this comment!*

   🤖 *Automated analysis by Claude Code*"
   ```

2. **Update Labels**
   ```bash
   gh issue edit $ARGUMENTS --remove-label "auto-fix" --add-label "needs-clarification"
   ```

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
   - **CRITICAL**: You must run BOTH commands. Do not stop after git push.
   ```bash
   git push -u origin HEAD
   gh pr create \
     --title "fix: <concise description>" \
     --body "$(cat <<'EOF'
   ## Summary

   <1-2 sentence description of fix>

   ## Issue

   Fixes #$ARGUMENTS

   ## Root Cause

   <Brief explanation of what was causing the issue>

   ## Solution

   <Brief explanation of how it was fixed>

   ## Changes

   - <bullet points of changes>

   ## Testing

   - <how tested>
   - <new tests added>

   ---
   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   EOF
   )"
   ```

6. **Update Issue**
   ```bash
   gh issue comment $ARGUMENTS --body "## 🔧 Fix Ready for Review

   **Root Cause:** <explanation>

   **Solution:** <explanation>

   **Pull Request:** #<PR_NUMBER>

   The fix is ready for review. Once approved and merged, this issue will close automatically.

   ---
   🤖 *Automated fix by Claude Code*"
   ```

7. **Clean Up Labels**
   ```bash
   gh issue edit $ARGUMENTS --remove-label "needs-clarification" --remove-label "awaiting-response" 2>/dev/null || true
   ```

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

### Important Guidelines

- **NEVER GUESS** - If uncertain, ask for clarification
- **Ask focused questions** - 1-3 specific questions, not a laundry list
- **Show your understanding** - Summarize what you know to build trust
- **Minimal changes only** - Fix only what's reported
- **No force push** - Never use `git push --force`
- **Security first** - Never commit secrets or credentials

