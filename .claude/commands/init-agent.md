---
title: "Init Agent"
description: "Initializing of AGENTS.md and CLAUDE.md for new agent sessions"
category: "Init"
tags: [init, agents, setup]
version: "1.0"
examples:
  - "/init-agent"
  - "/init-agent frontend focus"
  - "/init-agent with security emphasis"
---

# Initialize Agent Context Files

You are an expert project analyst. Your goal is to generate `AGENTS.md` and `CLAUDE.md` files that will guide new agent sessions working on this codebase.

## Context

$ARGUMENTS

---

## Workflow Instructions

### Phase 1: Project Analysis

Perform a comprehensive analysis of the project:

1. **Tech Stack Discovery**
   - Read `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, or other dependency files
   - Identify frameworks (React, Vue, Express, FastAPI, etc.)
   - Note build tools (Vite, Webpack, etc.)
   - Identify database technologies and ORMs

2. **Architecture Understanding**
   - Map the folder structure and identify patterns (monorepo, feature-based, etc.)
   - Identify key directories: src/, lib/, components/, services/, etc.
   - Note any existing documentation or README files

3. **Code Conventions**
   - Look for linting configs (eslint, prettier, etc.)
   - Check TypeScript/type configurations
   - Identify testing frameworks and patterns
   - Note naming conventions used in existing code

4. **Domain Context**
   - Understand what the project does from README, package.json description, etc.
   - Identify core entities and domain models
   - Map key workflows and features

---

### Phase 2: Generate AGENTS.md

Create `AGENTS.md` at the project root with the following structure:

```markdown
# AGENTS.md

> Project context and conventions for AI agent sessions. This file helps agents understand the codebase quickly.

## Project Overview

### Description
[Brief description of what this project does]

### Tech Stack
- **Frontend**: [frameworks, libraries]
- **Backend**: [frameworks, runtime]
- **Database**: [database, ORM]
- **Build Tools**: [bundler, compiler]
- **Testing**: [test frameworks]

---

## Project Structure

```
[Simplified directory tree showing key folders]
```

### Key Directories
- `src/` - [description]
- `components/` - [description]
- [etc.]

---

## Code Conventions

### Naming
- Files: [kebab-case, PascalCase, etc.]
- Components: [convention]
- Functions: [convention]
- Variables: [convention]

### TypeScript/JavaScript
- [Key conventions observed]
- [Import order preferences]
- [Type annotation patterns]

### Styling
- [CSS approach: Tailwind, CSS Modules, styled-components, etc.]
- [Theme/design system notes]

---

## Architecture Patterns

### State Management
[How state is managed - stores, context, etc.]

### Data Flow
[How data flows through the application]

### API Patterns
[REST, GraphQL, IPC, etc. and conventions used]

---

## Development Workflow

### Running Locally
```bash
[commands to run the project]
```

### Testing
```bash
[commands to run tests]
```

### Building
```bash
[commands to build]
```

---

## Important Files

| File | Purpose |
|------|---------|
| `file.ts` | Description |
| [etc.] | |

---

## Domain Glossary

| Term | Definition |
|------|------------|
| [Domain term] | [What it means in this project] |

---

## Common Tasks

### Adding a New Feature
1. [Step 1]
2. [Step 2]
3. [etc.]

### Creating a New Component
1. [Step 1]
2. [Step 2]

---

## Gotchas & Warnings

- ⚠️ [Important thing to know]
- ⚠️ [Common pitfall to avoid]
```

---

### Phase 3: Generate CLAUDE.md

Create `CLAUDE.md` at the project root with agent-specific instructions:

```markdown
# CLAUDE.md

> Instructions for Claude agents working on this codebase.

## Quick Start

When starting a new session on this project:
1. Read `AGENTS.md` for project context
2. Check open issues or assigned tasks
3. Run `[dev command]` to ensure the project builds

---

## Behavioral Guidelines

### Before Making Changes
- [ ] Understand the existing patterns in similar files
- [ ] Check for existing utilities before creating new ones
- [ ] Review related tests to understand expected behavior

### Code Style
- Follow existing conventions in the codebase
- Match the formatting of surrounding code
- [Specific style notes for this project]

### Testing Requirements
- [Testing expectations for this project]
- [Coverage requirements if any]

### Commit Standards
- [Commit message format expected]
- [Branch naming conventions if any]

---

## Project-Specific Commands

```bash
# Development
[dev commands]

# Testing
[test commands]

# Linting
[lint commands]
```

---

## Agent Collaboration

When working with other agents or handing off work:
- Update task status in the system
- Leave clear comments on complex logic
- Document any temporary workarounds

---

## Do NOT

- ❌ [Things to avoid in this project]
- ❌ [Anti-patterns specific to this codebase]
- ❌ [Common mistakes to prevent]

---

## Escalation

If you encounter:
- Breaking changes to core APIs → [guidance]
- Security concerns → [guidance]
- Unclear requirements → Ask for clarification before proceeding
```

---

### Phase 4: Confirmation & Next Steps

After generating both files:

1. **Summarize** what was discovered and documented
2. **Highlight** any areas that need human input to complete
3. **Suggest** any additional documentation that might be helpful
4. **Ask** if there are any project-specific conventions or guidelines to add

---

## Output Requirements

- Place `AGENTS.md` and `CLAUDE.md` in the project root directory
- Use clear, concise language
- Include actual values discovered from the project (not placeholders)
- Mark any sections that need human review with `[REVIEW NEEDED]`
- Ensure the files are immediately useful for new agent sessions
