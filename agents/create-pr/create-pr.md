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
    - Compare the changes against the `main` branch to verify the diff.

3.  **PR Creation**
    - Create a Pull Request into `main` (or the appropriate target branch).
    - **Description**: Generate a comprehensive PR title and body including:
        - Summary of changes.
        - Business value.
        - Technical details of implementation.
        - Testing steps performed.
        - Suggested next steps.

4.  **Completion**
    - **Suggest Next Steps**: Recommend specific reviewers or next steps for the deployment pipeline.
