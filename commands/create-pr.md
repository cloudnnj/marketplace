---
title: "Create Pull Request"
description: "Prepare current branch for PR submission with quality checks and automated creation"
category: "Operations"
tags: [pr, pull-request, git, quality-check, automation]
version: "1.0"
examples:
  - "/create-pr"
---

# Create Pull Request

You are an expert developer. I want you to prepare the current branch for a Pull Request and create it.

### Workflow Instructions

1.  **Pre-Submission Checks**
    - Ensure all changes are committed to the current branch.
    - Run final tests to ensure the build passes.
    - Verify code quality against the following checklist:
        - Follows project naming conventions.
        - Proper error handling implemented.
        - No hardcoded values, secrets, or magic numbers.
        - Appropriate comments and documentation.
        - Follows existing design principles and is consistent with exemplars.
        - No obvious security vulnerabilities.
        - Performance optimizations considered.

2.  **Git Operations**
    - Push the current branch to the remote repository.
    - Compare the changes against the `${CREWDECK_BASE_BRANCH:-main}` branch to verify the diff.

3.  **PR Creation**
    - Create a Pull Request into `${CREWDECK_BASE_BRANCH:-main}` (the configured integration branch, defaulting to `main` if not set).
    - **Description**: Generate a comprehensive PR title and body including:
        - Summary of changes.
        - Business value.
        - Technical details of implementation.
        - Testing steps performed.
        - Suggested next steps.

4.  **Completion**
    - **Suggest Next Steps**: Recommend specific reviewers or next steps for the deployment pipeline.

---

## GitHub API via MCP

Use the **GitHub MCP tools** for all GitHub interactions. Never use the `gh` CLI or raw `curl` API calls.

### Checking for Existing PRs

Use `mcp__github__list_pull_requests` with `owner`, `repo`, `head: "<owner>:<branch>"`, `state: "open"`.

### Creating a Pull Request

Use `mcp__github__create_pull_request` with:
- `owner`, `repo`
- `title: "<title>"`
- `head: "<branch-name>"`
- `base: "${CREWDECK_BASE_BRANCH:-main}"`
- `body: "<PR description>"`
