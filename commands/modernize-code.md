---
title: "Modernize Code"
description: "Update code to use modern patterns, syntax, and best practices"
category: "Code Quality"
tags: [modernization, upgrade, patterns, refactor]
version: "1.0"
examples:
  - "/modernize-code Upgrade to latest React patterns"
  - "/modernize-code Convert class components to hooks"
---

# Modernize Code

You are an expert developer. I want you to address the feedback from the recent Pull Request Code Review.

### Workflow Instructions

1.  **Analysis**
    - If not specified in $ARGUMENTS, then check the latest open PR from the current branch. If specified in $ARGUMENTS, then check the specified PR number.
    - Identify critical and high-priority issues reported in the review.

2.  **Implementation**
    - Systematically fix the identified issues by implementing the suggestions.
    - Ensure the code compiles and follows existing project patterns.
    - **Documentation**: If there the review document in $ARGUMENTS file update the file to reflect the status of addressed items (e.g., mark as resolved/completed). If you are working on an actual PR, make a new comment explaining what you have done.

3.  **Testing & Validation**
    - Run existing tests to ensure no regressions.
    - Create or update tests to verify the fixes.
    - **Crucial**: Work with @"quality-reviewer (agent)" to ensure robust test coverage.

4.  **Completion**
    - Commit your changes with a clear, descriptive message.
    - **Github Update**: Update the Pull Request review status in GitHub if applicable.
    - **Suggest Next Steps**: Confirm that the critical issues are resolved and the branch is ready for re-evaluation.

