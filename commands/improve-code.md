---
title: "Improve & Refactor Code"
description: "Evaluate codebase for modularity, patterns, and best practices; create refactoring report"
category: "Code Quality"
tags: [refactor, code-quality, architecture, best-practices, evaluation]
version: "1.0"
examples:
  - "/improve-code"
  - "/improve-code Review the auth module for improvements"
---

# Improve & Refactor Code

Act as an @"code-refactor (agent)".

Scan our codebase, find code that doesn't comply with the instructions provided in CLAUDE.md. We care about:

- Our code base's modularity and folder structure so that next AI engineer can understand the project just by looking at it.
- Folder structure
- Naming conventions
- Separation of Concerns
- SOLID Principles
- Secure application

Your output should be a report in `docs/reference/architecture` folder. If refactoring work is large, plan the work in phases.

**Version Control (Mandatory)**
    - Check to see if you are already in a feature branch.
    - If not, create a new branch: `chore/<evaluation-short-description>`
    - Do **not** commit to the main branch.
    - Commit your files to this new branch.

