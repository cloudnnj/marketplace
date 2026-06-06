---
title: "Feature Prioritize"
description: "Score and rank a backlog of features using an explicit framework (RICE by default) and produce a sequenced now/next/later roadmap"
category: "Product Management"
tags: [prioritization, roadmap, rice, backlog, product]
version: "1.0"
model: "opus"
examples:
  - "/feature-prioritize Rank our Q3 backlog with RICE"
  - "/feature-prioritize Value-vs-effort on these 8 onboarding ideas"
  - "/feature-prioritize What should we build next to improve retention?"
---

# Feature Prioritize

Scores a list of features or initiatives with a transparent framework and turns
the result into a sequenced, goal-aligned roadmap.

## Features

- RICE scoring by default (Reach, Impact, Confidence, Effort)
- Alternative lenses: ICE, value-vs-effort, WSJF, MoSCoW
- Explicit assumptions and confidence per item
- Now / next / later sequencing
- Goal-to-feature traceability
- Capacity-aware recommendations
- Dependency and risk flags
- Stakeholder-ready summary

## Usage

Prioritize a backlog:

```
/feature-prioritize
```

Or with specific focus:

```
/feature-prioritize Use value-vs-effort and assume a 2-engineer team
/feature-prioritize Prioritize for activation, not revenue, this quarter
/feature-prioritize Rank these and tell me what to cut
```

## Output

Generates:
- Scoring table with per-item framework scores and assumptions
- Ranked list with reasoning
- Now/next/later roadmap
- Goal alignment notes for each item
- Items recommended to defer or cut, with why
- Dependencies and risks to watch

---
*Product Management Studio Bundle Component*
