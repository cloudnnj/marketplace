---
title: "Commit and PR"
description: "Commit staged changes to a feature branch, push to remote, and create or update a pull request with a comprehensive description"
category: "Operations"
tags: [git, commit, pr, pull-request, automation]
version: "1.0"
examples:
  - "/commit-and-pr"
  - "/commit-and-pr Added GitHub token validation"
---

# Commit and PR

You are an expert developer. Commit the current changes to a feature branch, push to remote, and create a pull request. If a PR already exists for this branch, push new commits and add an update comment to the existing PR.

`$ARGUMENTS` - Optional description of the changes. If provided, use it to inform the commit message and PR title/body.

**GitHub API Access**: Use the **GitHub MCP tools** for all GitHub interactions. Never use the `gh` CLI or raw `curl` API calls.

---

## Phase 1: Pre-Flight Checks

1. **Verify Branch**
   - Confirm you are NOT on `main` or `master`. If you are, stop and ask the user which feature branch to create or switch to.
   - Get current branch name:
     ```bash
     BRANCH=$(git rev-parse --abbrev-ref HEAD)
     ```

2. **Check Working Tree**
   - Run `git status` to see staged, unstaged, and untracked changes.
   - If there are no changes at all (clean working tree), inform the user and stop.
   - If there are unstaged or untracked changes, stage relevant files. Prefer staging specific files by name over `git add -A`. Do NOT stage files that likely contain secrets (`.env`, `credentials.json`, etc.).

3. **Run Quality Checks**
   - Run `npx tsc --noEmit` to verify no TypeScript errors.
   - Run `npm run lint` to check for lint issues.
   - Run `npm test` to ensure tests pass.
   - If any check fails, fix the issues before proceeding. Do NOT commit broken code.

---

## Phase 2: Commit

1. **Analyze Changes**
   - Review the staged diff with `git diff --cached` to understand what changed.
   - Review recent commit messages with `git log --oneline -10` to follow the repository's commit style.

2. **Create Commit**
   - Write a commit message following conventional commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`).
   - If `$ARGUMENTS` is provided, use it to inform the commit message.
   - Keep the first line under 72 characters.
   - Add a body if the changes warrant further explanation.
   - Include the co-author trailer:
     ```bash
     git commit -m "$(cat <<'EOF'
     <type>: <concise description>

     <optional body explaining the why>

     Co-Authored-By: Claude <noreply@anthropic.com>
     EOF
     )"
     ```

---

## Phase 3: Push

Push the branch to the remote:
```bash
git push -u origin HEAD
```

If the push fails due to diverged history, do NOT force push. Instead, pull with rebase and try again:
```bash
git pull --rebase origin "$BRANCH" && git push -u origin HEAD
```

---

## Phase 4: Create or Update Pull Request

### 4a: Check for Existing PR

Use `mcp__github__list_pull_requests` with `owner`, `repo`, `head: "<owner>:<branch>"`, `state: "open"`.

### 4b: If PR Exists — Add Update Comment

If a PR already exists, push was already done in Phase 3, so just add a comment describing the new changes:

Use `mcp__github__add_issue_comment` with `owner`, `repo`, `issue_number: <PR_NUMBER>`, and a body summarizing what changed in this push.

Output the existing PR URL and stop.

### 4c: If No PR Exists — Create One

1. **Gather Context**
   - Run `git log main..HEAD --oneline` to see all commits on this branch.
   - Run `git diff main...HEAD --stat` to see all files changed relative to main.

2. **Create the PR**
   Use `mcp__github__create_pull_request` with:
   - `owner`, `repo`
   - `title: "<type>: <concise PR title>"`
   - `head: "<branch-name>"`
   - `base: "main"`
   - `body`: Include Summary, Changes, Testing, and Checklist sections.

3. **Output Result**
   - Display the PR URL from the MCP response.

---

## Important Notes

- **Never commit to main** — Always use a feature branch.
- **Never force push** — Use `git pull --rebase` if the branch has diverged.
- **Never commit secrets** — Skip `.env`, credentials, tokens, or API keys.
- **Conventional commits** — Use `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`.
- **Atomic commits** — Each commit should represent a single logical change.
- **Minimal PR scope** — The PR description should accurately reflect only the changes made.
