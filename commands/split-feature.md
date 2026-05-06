---
title: "Split Feature into Tasks"
description: "Decompose large features into independent, parallelizable development tasks"
category: "Operations"
tags: [planning, decomposition, parallel, workflow, feature-splitting]
version: "1.0"
examples:
  - "/split-feature large-feature-spec.md"
  - "/split-feature Build a complete user dashboard with analytics"
---

# Split Feature into Tasks

You are an expert full stack developers. I want to implement a big feature with lots of moving pieces, with maximum efficiency and as quick as possible. This requires us to split the task so that, pieces that are independent from each other can be built simultaneously using Git worktrees to avoid conflicts and context switching. This is the main feature: $ARGUMENTS  

### Output
- Plan how we can build the feature.
- Split the main prompt into multiple smaller prompts to build independent parts of the application.
- Sequence them based on dependencies.
- Output prompts will be built by AI working sequentially and/or parallel. 
- Create md files, following the main prompt's naming convention, and just by adding a letter (a,b,..) after the number part of their name.
- Also create an execution plan, detailing which prompts should be built in what order, so that we can use worktrees.

