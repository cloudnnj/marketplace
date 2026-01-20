---
title: "Parallel Development"
description: "Develop multiple features simultaneously using Git worktrees to avoid context switching"
category: "Development"
tags: [parallel, worktrees, git, multi-feature, workflow]
version: "1.0"
examples:
  - "/parallel-development @features-list.md"
  - "/parallel-development Feature A: Add login; Feature B: Add dashboard; Feature C: Add settings"
---

# Parallel Development

You are an expert in Git workflows and parallel development. I want to implement multiple features simultaneously using Git worktrees to avoid conflicts and context switching.

### Context & Setup
- **Source Branch**: Determine the current branch.
  - If the current branch is **NOT** `main`, treat it as the **Integration Branch** for all new features.
  - If the current branch **IS** `main`, use it as the base.
- **Pre-flight Check**: If acting as an integration branch, ensure all current changes are committed before proceeding.

### Feature Requests
The features to be implemented are described in: $ARGUMENTS

### Instructions
1.  **Prepare Environment**:
    - If there are uncommitted changes on the current branch (and it is not `main`), commit them immediately with a generic "WIP: save state before parallel work" message or ask for a message, to ensure a clean slate for the integration branch.
2.  **Create Worktrees**:
    - For each feature described in the arguments, create a new Git worktree.
    - **Path**: Create the worktree in a sibling directory: `../momentum-<feature-name>` (relative to the current project root).
    - **Branch Naming**: `feature/<feature-name>`.
    - **Base Branch**: Create the new feature branch off the **Source Branch** identified above.
3.  **Post-Creation**:
    - Verify all worktrees are set up correctly.
    - Analyze the features and recommend a **Merge Order** to minimize potential conflicts when integrating back into the Source Branch.

### Output
- Confirm the Source Branch used.
- List all created worktrees with their paths and branch names.
- Provide the recommended merge order with a brief justification.

