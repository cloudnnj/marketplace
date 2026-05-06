---
title: "Update User Guide"
description: "Update project documentation files scoped to changes since the previous release tag"
category: "Documentation"
tags: [documentation, user-guide, docs, release]
version: "1.0"
model: "haiku"
examples:
  - "/update-user-guide"
---

# Update User Guide

You are a documentation expert. Update the project's documentation files to reflect changes since the last release.

## Scope Determination

First, determine what has changed since the last release:

```bash
# Find the previous release tag
PREV_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$PREV_TAG" ]; then
  echo "No previous tag found — will review all documentation against current state"
else
  echo "Previous release: $PREV_TAG"
  git diff --name-only "$PREV_TAG"..HEAD
  git diff --name-only "$PREV_TAG"..HEAD -- prompts/build/ prompts/bugfix/
  git log --oneline "$PREV_TAG"..HEAD
fi
```

## Documentation Update Strategy

**If a previous tag exists:** Only update documentation sections affected by the identified changes. Do NOT rewrite entire documents — make targeted edits.

**If no previous tag exists (first release):** Review all documentation against the current application state.

## Files to Update

### 1. User Guide (`docs/guides/user-guide.md`)
- Add or update sections for new features
- Update UI descriptions if the UI changed
- Remove references to deprecated functionality

### 2. Functional Guide (`docs/guides/crewdeck-functional-guide.html`)
- Update functional specifications for changed features

### 3. Technical Guide (`docs/guides/crewdeck-technical-guide.html`)
- Update architecture descriptions if backend/IPC/database changed

### 4. Task Execution Service (`docs/guides/task-execution-service.md`)
- Update only if task execution logic changed

### README.md Badges
Add workflow status badges at the top of `README.md` (if not already present):
```markdown
![Unit Tests](https://github.com/OWNER/REPO/workflows/Unit%20Tests/badge.svg)
![Release](https://github.com/OWNER/REPO/workflows/Release/badge.svg)
```
Replace OWNER/REPO with the actual GitHub repository path from the git remote.

## Important Notes

- Make targeted, scoped updates — do NOT rewrite entire files
- Preserve existing formatting and structure
- Do NOT create git commits — the calling system handles version control
