---
title: "Fix GitHub Issue (Direct)"
description: "Direct GitHub issue fixing without interactive clarification - assumes issue is clear"
category: "Bug Fixing"
tags: [github, issue, bugfix, automated, pr-creation]
version: "1.0"
examples:
  - "/fix-github-issue-direct 42"
  - "/fix-github-issue-direct 123"
---

# Fix GitHub Issue (Direct)

You are an expert developer fixing GitHub Issue #$ARGUMENTS

**Note**: This command assumes the issue is clear. For issues that may need clarification, use `/fix-github-issue` instead.

**GitHub API Access**: Use the **GitHub MCP tools** for all GitHub interactions. Never use the `gh` CLI or raw `curl` API calls.

### Pre-Flight Checks

1. **Fetch Full Issue Details**
   - Use `mcp__github__issue_read` with `method: "get"`, `owner`, `repo`, `issue_number: $ARGUMENTS`
   - Use `mcp__github__issue_read` with `method: "get_comments"`, `owner`, `repo`, `issue_number: $ARGUMENTS`

2. **Check for Existing Work**
   - Search for existing PRs: Use `mcp__github__search_pull_requests` with `query: "Fixes #$ARGUMENTS"`, `owner`, `repo`
   - Search for existing branches: `git branch -r | grep -i "issue-$ARGUMENTS\|$ARGUMENTS"`
   - If PR exists and is open, update it instead of creating new one
   - If PR was closed without merge, understand why before proceeding

### Workflow Instructions

1. **Version Control (Mandatory)**
   - Ensure you're on the latest main: `git fetch origin && git checkout main && git pull`
   - Create branch: `git checkout -b auto-fix/issue-$ARGUMENTS-<short-description>`
   - Use kebab-case for the short description (e.g., `auto-fix/issue-42-fix-login-error`)
   - Do **not** commit directly to the main branch

2. **Investigation**
   - Summon @"code-debugger (agent)" to analyze the issue
   - Read any files, error messages, or stack traces mentioned in the issue
   - Check issue comments for additional context or reproduction steps
   - Understand the full scope before making changes

3. **Implementation**
   - Write the minimal code required to fix the issue
   - Follow existing project patterns (reference CLAUDE.md)
   - Ensure the code compiles/lints: `npm run lint` or equivalent
   - Do not introduce unrelated changes or refactoring

4. **Testing & Validation**
   - Create or update unit tests to cover the fix
   - Tests should:
     - Reproduce the original bug (would fail without fix)
     - Verify the fix works correctly
   - Work with @"quality-reviewer (agent)" for proper coverage
   - Run the full test suite: `npm test`
   - Ensure ALL tests pass before proceeding

5. **Commit Changes**
   - Stage your changes: `git add -A`
   - Commit with a descriptive message following conventional commits:
     ```
     fix: <short description>

     <longer description if needed>

     Fixes #$ARGUMENTS

     🤖 Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude <noreply@anthropic.com>
     ```

6. **Push and Create Pull Request**
   - Push branch: `git push -u origin HEAD`
   - Create PR via MCP: Use `mcp__github__create_pull_request` with:
     - `owner`, `repo`
     - `title: "fix: <concise description of the fix>"`
     - `head: "<branch-name>"`
     - `base: "main"`
     - `body`: Include Summary, Issue (Fixes #$ARGUMENTS), Changes, Testing, and Checklist sections.

7. **Comment on Issue**
   - Use `mcp__github__add_issue_comment` with `owner`, `repo`, `issue_number: $ARGUMENTS`, and a body summarizing root cause, solution, and PR number.

### Error Handling

If you encounter issues that prevent a fix:

1. **Cannot Reproduce**
   - Post a comment asking for more details using `mcp__github__add_issue_comment`
   - Add label using `mcp__github__issue_write` with `method: "update"`, `labels: ["needs-more-info"]`

2. **Too Complex / Risky**
   - Post a comment explaining the complexity using `mcp__github__add_issue_comment`
   - Add label using `mcp__github__issue_write` with `method: "update"`, `labels: ["needs-human-review"]`
   - Suggest an approach for a human developer

3. **Requires Breaking Changes**
   - Post a comment explaining the situation
   - Add `needs-human-review` label (same as above)
   - Do NOT proceed with breaking changes

4. **Tests Fail**
   - If existing tests fail (not related to your fix), comment and add `needs-human-review` label
   - If your fix causes test failures, debug and resolve before creating PR

5. **Missing Dependencies/Access**
   - Post a comment explaining what's needed
   - Add `needs-human-review` label

### Label Reference

Use these labels to communicate status:

| Label | When to Use |
|-------|-------------|
| `auto-fix` | Triggers the auto-fix workflow (usually set externally) |
| `dont-fix` | Exclude issue from auto-fix queue |
| `fix-attempted` | After creating a PR (set by workflow) |
| `needs-human-review` | Issue is too complex or risky for auto-fix |
| `needs-more-info` | Cannot reproduce, need more details |
| `needs-clarification` | Claude asked questions, waiting for user response |
| `awaiting-response` | Processing user's clarification response |

### Managing Labels via MCP

- **Add/update labels**: Use `mcp__github__issue_write` with `method: "update"`, `owner`, `repo`, `issue_number`, `labels: ["<label-name>"]`
- **Read current labels**: Use `mcp__github__issue_read` with `method: "get_labels"`, `owner`, `repo`, `issue_number`

### Interactive Workflow

For a more interactive experience where Claude asks clarifying questions before attempting fixes, use the `/fix-github-issue` command instead. This is the default behavior for the auto-fix GitHub workflow.

### Important Notes

- **Minimal Changes**: Only fix what's reported. Avoid scope creep.
- **No Force Push**: Never use `git push --force`
- **Respect .gitignore**: Don't commit ignored files
- **Security**: Don't commit secrets, credentials, or sensitive data
- **Existing Patterns**: Match the codebase style, don't introduce new patterns
