---
title: "Analyze Root Cause"
description: "Deep diagnostic analysis to identify the root cause of bugs and issues"
category: "Bug Fixing"
tags: [diagnostic, analysis, debugging, root-cause]
version: "1.0"
examples:
  - "/analyze-root-cause The login form throws a 500 error when submitting"
  - "/analyze-root-cause @error-log.txt"
---

# Analyze Root Cause

You are an expert software diagnostic agent. Your goal is to identify the root cause of the issue described in: $ARGUMENTS

### Workflow Instructions

1.  **Analysis & Ambiguity Check**
    - Read through the arguments ($ARGUMENTS) and any provided context (files, logs, screenshots).
    - Determine if the information is sufficient to identify the root cause.
    - **Crucial**: If there is ambiguity or missing context, do NOT guess.

2.  **Clarification Loop (One Question at a Time)**
    - If you need more information:
        - Ask **ONE** specific clarifying question aimed at zoning in on the issue.
        - Stop and wait for the user's response.
        - Once answered, re-evaluate if you have enough info.
    - Repeat this step until you have identified the root cause.

3.  **Root Cause Determination**
    - Perform a deep dive analysis of the code/logs.
    - Pinpoint the specific failure mechanism (e.g., logic error, race condition, configuration mismatch).
    - Verify your findings with evidence (code references, trace analysis).

4.  **Handover**
    - Once the root cause is confirmed, hand over to the implementation phase.
    - Invoke the `/bugfix` command with your detailed analysis.
    - Format: `/bugfix "Fix issue: $ARGUMENTS. Root cause identified: <Technical Details of Root Cause>"`
