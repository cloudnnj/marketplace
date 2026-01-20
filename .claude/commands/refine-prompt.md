---
title: "Refine Prompt"
description: "Enrich and refine AI prompts with project context for better AI engineer outputs"
category: "Operations"
tags: [prompt, refinement, ai-engineering, context]
version: "1.1"
examples:
  - "/refine-prompt @draft-prompt.md"
  - "/refine-prompt Add authentication to user profile"
---

# Refine Prompt

@systems-architect

You are refining a task prompt to create comprehensive implementation specifications.

## Input Task
$ARGUMENTS

## Your Mission

Analyze the task above and create a detailed implementation prompt by:

1. **Understand the Request**: Parse the task requirements and identify the core objective
2. **Explore Project Context**: Use Glob and Read to understand relevant existing code, patterns, and architecture
3. **Identify Affected Areas**: Determine which files, services, and components will be impacted
4. **Research Patterns**: Find similar implementations in the codebase to maintain consistency

## Output Format

Generate a comprehensive prompt in markdown format with these sections:

```markdown
# [Feature/Task Title]

## Overview
[Brief description of what needs to be built]

## Requirements
- [Functional requirement 1]
- [Functional requirement 2]
...

## Technical Approach
[Describe the implementation strategy based on existing patterns]

## Affected Files
- `path/to/file1.ts` - [what changes needed]
- `path/to/file2.ts` - [what changes needed]
...

## Implementation Steps
1. [Step 1 with specific details]
2. [Step 2 with specific details]
...

## Testing Requirements
- [Test case 1]
- [Test case 2]
...

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
...
```

## Important Guidelines

- Be specific and actionable - avoid vague instructions
- Reference actual file paths and function names from the codebase
- Include code snippets showing expected patterns where helpful
- Keep the prompt focused - this will be used by AI engineers to implement the feature
- Output ONLY the refined prompt markdown, no additional commentary

