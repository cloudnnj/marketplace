---
title: "Build Feature"
description: "Orchestrated full-stack feature development using specialized subagents with parallel execution"
category: "Development"
tags: [feature, orchestration, electron, react, subagents, workflow, parallel]
version: "3.0"
model: "opus"
examples:
  - "/build-feature Add department archiving with confirmation modal"
  - "/build-feature /prompts/features/agent-scheduling.md"
  - "/build-feature Implement task filtering and search on Kanban board"
---

# Build Feature

@"feature-orchestrator (agent)" I want you to orchestrate the implementation of the following feature: $ARGUMENTS

## Pre-Flight (before orchestration begins)

1. **Branch**: If not already on a feature branch, create `feature/<feature-short-name>`. Never commit to `main`.
2. **Input**: If `$ARGUMENTS` is a `.md` file path, read it and commit it to the feature branch first.
3. **Working directory**: Verify clean or stash changes. Run `npm run dev` to confirm the build is clean before starting.

## Orchestration Guidance

Follow the 3-phase workflow defined in your agent instructions and `.claude/rules/orchestration.md`. All project conventions, patterns, and code examples are in CLAUDE.md and the rules files -- do not ask for them.

Key reminders:
- Select agents dynamically based on which files need to change (do not follow a fixed sequence)
- For cross-domain features, use non-overlapping file assignments per agent
- Run `npm test` and `npm run test:coverage` as quality gates; fix failures before creating the PR

## Completion

1. Commit with conventional format: `feat(<scope>): <description>`
2. Create PR with description, testing instructions, and screenshots if UI changed
3. Suggest related improvements or technical debt discovered
