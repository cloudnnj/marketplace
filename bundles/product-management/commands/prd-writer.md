---
title: "PRD Writer"
description: "Turn a feature idea into a clear, engineering-ready Product Requirements Document with goals, user stories, acceptance criteria, and a success metric"
category: "Product Management"
tags: [prd, requirements, user-stories, product, spec]
version: "1.0"
model: "opus"
examples:
  - "/prd-writer Add SSO login for enterprise customers"
  - "/prd-writer In-app onboarding checklist to improve activation"
  - "/prd-writer Usage-based billing with metered API limits"
---

# PRD Writer

Generates a structured, engineering-ready Product Requirements Document from a
feature idea, so the team builds the right thing with no ambiguity.

## Features

- Problem statement grounded in a target user and pain
- Explicit goals and non-goals (scope boundaries)
- User stories with acceptance criteria
- Edge cases, error states, and open questions
- Success metric with baseline and target
- Dependencies, risks, and rollout/launch plan
- Smallest-viable-version scoping
- Stakeholder and review notes

## Usage

Generate a PRD:

```
/prd-writer
```

Or with a specific idea:

```
/prd-writer Add a self-serve trial that converts to paid after 14 days
/prd-writer Real-time collaboration cursors in the editor
/prd-writer Reduce checkout drop-off for mobile users
```

## Output

Generates:
- Title, summary, and problem statement
- Goals and non-goals
- Target users and key user stories with acceptance criteria
- Functional requirements and edge cases
- Success metric (North Star link, baseline, target)
- Dependencies, risks, and open questions
- Rollout plan and smallest-viable-version recommendation

---
*Product Management Studio Bundle Component*
