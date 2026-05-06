---
title: "Fix Bug (Orchestrated)"
description: "Orchestrated bug investigation and resolution with specialized subagents for root cause analysis, implementation, and verification"
category: "Bug Fixing"
tags: [bugfix, orchestration, debugging, electron, subagents, root-cause, workflow]
version: "3.0"
model: "opus"
examples:
  - "/fix-bug Terminal session crashes after 20 concurrent PTY instances"
  - "/fix-bug bug-report.md"
  - "/fix-bug Kanban drag-and-drop loses task on rapid moves"
  - "/fix-bug GitHub repo connection fails with 401 after token refresh"
---

# Fix Bug (Orchestrated)

@"bugfix-orchestrator (agent)" I need you to orchestrate the investigation and resolution of the following bug: $ARGUMENTS

## Pre-Flight (before orchestration begins)

1. **Branch**: If not already on a bugfix branch, create `bugfix/<issue-short-description>`. Never commit to `main`.
2. **Input**: If `$ARGUMENTS` is a `.md` file path, read it and commit it to the branch first.
3. **Recent context**: Run `git log --oneline -10` to check for related recent changes.

## Evidence Template

When collecting evidence in Phase 1, structure it as:

```
Bug: [Short description]
Symptom: [What user sees]
Error: [Error message/code if available]
Repro: [Steps to reproduce]
Process: [Main | Renderer | IPC | Database]
Timeline: [When it started, frequency]
```

## Orchestration Guidance

Follow the 3-phase workflow defined in your agent instructions and `.claude/rules/orchestration.md`. Check `.claude/rules/lessons-*.md` for documented bug patterns that may match this issue. All project conventions and code patterns are in CLAUDE.md and the rules files.

Key reminders:
- Evidence first, then hypothesis, then minimal fix
- Ask ONE clarifying question at a time if information is insufficient
- Create regression tests that cover the specific bug scenario

## Completion

1. Commit with: `fix(<scope>): <description>` including root cause in commit body
2. Create `docs/changelog/bugfixes/XX-description.md` (Problem, Root Cause, Fix, Files, Tests, Lesson)
3. Create PR with bug description, root cause explanation, fix summary, and testing performed
