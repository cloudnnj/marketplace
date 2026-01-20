---
title: "Sync Documentation"
description: "Automatically synchronize project documentation with current codebase state"
category: "Documentation"
tags: [documentation, sync, automation, maintenance]
version: "2.0"
examples:
  - "/sync-docs"
---

# Sync Documentation

Automatically update project documentation with the current state of the codebase. This command runs non-interactively and updates README.md, CLAUDE.md, and docs/architecture/technical-roadmap.md.

## Task

Scan the entire project and update documentation files to accurately reflect the current implementation state. Then commit changes and create a PR for review.

## Instructions

### Phase 0: Git Setup

Before making any changes, set up the git branch:

1. **Fetch latest and ensure clean state**
   ```bash
   git fetch origin
   git stash --include-untracked 2>/dev/null || true
   ```

2. **Checkout main and pull latest**
   ```bash
   git checkout main
   git pull origin main
   ```

3. **Create or reset the doc-update branch**
   ```bash
   git branch -D chore/doc-update 2>/dev/null || true
   git checkout -b chore/doc-update
   ```

### Phase 1: Codebase Analysis

Scan and analyze the following to understand current project state:

1. **Frontend Structure**
   - Scan `frontend/app/` for all implemented pages and routes
   - Scan `frontend/components/` for all component categories
   - Check `frontend/lib/` for utilities and API clients
   - Review `frontend/package.json` for dependencies and versions

2. **Backend Structure**
   - Scan `backend/functions/` for all Lambda function directories
   - Check `backend/migrations/` for database schema state
   - Review handler files to understand implemented endpoints

3. **Infrastructure**
   - Scan `infrastructure/terraform/` for deployed resources
   - Identify which AWS services are configured

4. **Documentation**
   - Scan `docs/` folder for all existing documentation files
   - Note any new docs that should be linked

### Phase 2: Update README.md

Update the following sections in README.md:

1. **Features Section** - Update completed/in-development features
2. **Tech Stack Section** - Verify versions match package.json
3. **Project Structure** - Update directory tree to match actual structure
4. **Documentation Section** - Add/remove links as needed
5. **Last Updated** - Update the date at bottom of file

### Phase 3: Update CLAUDE.md

**CRITICAL**: CLAUDE.md must be optimized for AI agent context efficiency. Follow these guidelines strictly:

#### Size Target
- **Maximum 400 lines** (current optimized version is ~293 lines)
- If updates push beyond 400 lines, consolidate or remove less critical content

#### Content Principles

1. **Reference, Don't Duplicate**
   - Do NOT include full database schema SQL - reference `backend/migrations/`
   - Do NOT include detailed API endpoint examples - reference handler files
   - Do NOT include full project structure trees - keep to essential directories only

2. **Keep Decision Context**
   - WHY decisions were made is more valuable than WHAT was built
   - Preserve: Tech stack choices, architectural decisions, code patterns

3. **Keep Style/Consistency Rules**
   - Naming conventions
   - Design consistency requirements
   - Security requirements
   - Git workflow

4. **Remove Human-Oriented Content**
   - Contributing guidelines belong in CONTRIBUTING.md
   - Detailed onboarding steps belong in README.md
   - Roadmap details belong in docs/architecture/technical-roadmap.md

#### Required Sections (in order)

```markdown
# Momentum - Learning Management Platform

## Project Overview
[2-3 sentences max]

## Project Goals
[5-6 bullet points max]

## Tech Stack
[Organized by layer: Frontend, API, Backend, Database, AI, Auth, Infrastructure]
[Include versions for key dependencies]

## Project Structure
[Essential directories only - max 30 lines]
[AI can glob for details]

## Database Schema
[4-5 lines: reference migrations/, list table categories]

## Development Guidelines
### Code Patterns
[Backend service pattern - 1 example]
[Frontend API client - 1 example]
[Component pattern - bullet points only]

### Code Style
[Naming conventions, principles]

### Design Consistency
[5-6 lines of critical requirements]

### Git Workflow
[Branch naming, commit format]

### Testing
[3 bullet points]

### Secrets & Environment
[List secret names, env var example]

### Security
[5 bullet points]

## AI Content Generation
[Workflow summary - 4 lines]
[Prompt system location and pattern - 10 lines max]

## Performance Targets
[Table format, 5-6 metrics]

## Key Design Decisions
[4 decisions with 1-line rationale each]

## Common Tasks
[3-4 common tasks, numbered steps only]

## Local Development
[4-line code block]

## Deployment
[3-line summary]

## Resources
[4-5 links to detailed docs]

---
[Repository info footer]
```

#### What to Update

1. **Tech Stack** - Verify versions match package.json
2. **Project Structure** - Add new essential directories only
3. **Database Schema** - Update table category list if new tables added
4. **API Endpoints** - Update single-line endpoint list
5. **Resources** - Add/remove doc links as needed

#### What NOT to Add

- Full SQL CREATE TABLE statements
- Detailed API request/response examples
- Step-by-step contributing guides
- Detailed roadmap with checkboxes
- Environment variable values (only var names)
- Redundant code examples

### Phase 4: Update technical-roadmap.md

Update `docs/architecture/technical-roadmap.md`:

1. **Version and Date** - Increment version, update date
2. **Key Findings** - Update completion percentage
3. **Feature Sections** - Mark completed features
4. **Remaining MVP Features** - Update list

### Phase 5: Validation

Before completing:

1. Verify all file paths in documentation links exist
2. Ensure CLAUDE.md is under 400 lines: `wc -l CLAUDE.md`
3. Check that dates are in correct format (YYYY-MM-DD)
4. Verify markdown formatting is valid

### Phase 6: Commit and Create PR

After all documentation updates are complete:

1. **Check for changes**
   ```bash
   git status
   ```
   If no changes detected, output "No documentation changes needed" and exit.

2. **Verify CLAUDE.md size**
   ```bash
   LINES=$(wc -l < CLAUDE.md)
   if [ "$LINES" -gt 400 ]; then
     echo "WARNING: CLAUDE.md is $LINES lines (target: <400). Consider consolidating."
   fi
   ```

3. **Stage and commit**
   ```bash
   git add README.md CLAUDE.md docs/architecture/technical-roadmap.md
   git commit -m "chore(docs): sync documentation with current codebase state

   - Updated README.md with current features and structure
   - Updated CLAUDE.md with current architecture (optimized for AI context)
   - Updated technical-roadmap.md with current completion status

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

4. **Push and create PR**
   ```bash
   git push -f origin chore/doc-update

   EXISTING_PR=$(gh pr list --head chore/doc-update --json number --jq '.[0].number' 2>/dev/null)

   if [ -n "$EXISTING_PR" ]; then
     echo "PR #$EXISTING_PR already exists - updated with new commits"
   else
     gh pr create \
       --title "chore(docs): automated documentation sync" \
       --body "## Automated Documentation Sync

   This PR syncs documentation with the current codebase state.

   ### Files Updated
   - \`README.md\` - Project overview and features
   - \`CLAUDE.md\` - Development guidelines (optimized for AI context)
   - \`docs/architecture/technical-roadmap.md\` - Feature roadmap

   ### CLAUDE.md Optimization
   - Target: <400 lines for AI context efficiency
   - References source files instead of duplicating content
   - Preserves decision context and style guidelines

   ### Review Checklist
   - [ ] Verify CLAUDE.md is under 400 lines
   - [ ] Check that new features are documented
   - [ ] Confirm documentation links are valid

   ---
   🤖 Generated with [Claude Code](https://claude.com/claude-code)" \
       --base main \
       --head chore/doc-update
   fi
   ```

## Output

After completing all updates, provide a summary:

```
## Documentation Update Summary

### Git Operations
- Branch: chore/doc-update
- Commit: [commit hash]
- PR: [PR number and URL, or "No changes needed"]

### Files Updated
- README.md: [sections updated]
- CLAUDE.md: [sections updated] - [X] lines (target: <400)
- technical-roadmap.md: [sections updated]

### Key Changes
- [List major changes]

### Warnings
- [List any issues: broken links, CLAUDE.md over limit, etc.]
```

## Important Notes

### Behavioral Guidelines
- Do NOT ask questions - make reasonable decisions based on code analysis
- Do NOT remove existing content unless clearly outdated
- Do NOT add speculative features - only document what exists
- Preserve existing formatting and style conventions
- Keep CLAUDE.md optimized for AI context (reference files, don't duplicate)

### CLAUDE.md Quality Checklist
Before finalizing CLAUDE.md updates:
- [ ] Under 400 lines
- [ ] No full SQL schemas (reference migrations/)
- [ ] No detailed API examples (reference handlers/)
- [ ] No contributing/onboarding content
- [ ] No detailed roadmap (link to technical-roadmap.md)
- [ ] Preserves: tech stack, patterns, style, security, decisions

### CI/CD Requirements
This command is designed to run in CI/CD pipelines. The environment must have:
- `git` configured with push permissions
- `gh` CLI authenticated with PR creation permissions
- Write access to the repository

### Git Behavior
- Always creates a fresh branch from latest `main`
- Force pushes to `chore/doc-update` (overwrites previous runs)
- Reuses existing PR if one is open, otherwise creates new PR
- Skips commit/PR if no documentation changes are detected

