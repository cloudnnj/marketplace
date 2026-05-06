---
title: "Init Agent"
description: "Initialize CLAUDE.md for new agent sessions"
category: "Init"
tags: [init, agents, setup]
version: "2.0"
examples:
  - "/init-agent"
  - "/init-agent frontend focus"
  - "/init-agent with security emphasis"
---

# Initialize Agent Context Files

You are an expert project analyst. Your goal is to generate a `CLAUDE.md` file that will guide new agent sessions working on this codebase.

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

### Phase 2: Generate CLAUDE.md

Create `CLAUDE.md` at the project root with the following structure:

```markdown
# CLAUDE.md

> Instructions for Claude agents working on this codebase.

## Project Overview

[Brief description of what this project does]

### Tech Stack
- **Frontend**: [frameworks, libraries]
- **Backend**: [frameworks, runtime]
- **Build**: [bundler, compiler]
- **Integrations**: [external services, APIs]

---

## Project Structure

```
[Simplified directory tree showing key folders]
```

## Key Files Reference

| File | Purpose |
|------|---------|
| `file.ts` | Description |
| [etc.] | |

---

## Quick Start

When starting a new session:
1. Check the task you've been assigned (task title/description)
2. Run `[dev command]` to ensure the project builds
3. Familiarize yourself with the relevant area of the codebase before making changes

---

## Before Making Changes

- [ ] Read existing similar files to understand patterns
- [ ] Check for existing type definitions
- [ ] Review related flows if change involves cross-process communication
- [ ] Understand database schema for data changes

---

## Code Conventions

### Naming
- Files: [kebab-case, PascalCase, etc.]
- Components: [convention]
- Functions: [convention]
- Variables: [convention]

### Import Order
[Describe the import order convention]

### Styling
[CSS approach: Tailwind, CSS Modules, styled-components, etc.]

### Code Style
- [Key conventions observed]
- [Type annotation patterns]

---

## Architecture Patterns

### State Management
[How state is managed - stores, context, etc.]

### Data Flow
[How data flows through the application]

### API Patterns
[REST, GraphQL, IPC, etc. and conventions used]

---

## Architecture Quick Reference

### Adding Frontend Features
[File location patterns for new frontend features]

### Adding Backend Features
[File location patterns for new backend features]

### Type Changes
[Where to put shared vs local types]

---

## Development Commands

```bash
# Development
[dev commands]

# Testing
[test commands]

# Database
[db commands if applicable]

# Build
[build commands]
```

---

## Testing Requirements

[Testing framework, thresholds, guidelines]

### Test File Structure
[Where tests go, naming convention]

### Testing Guidelines
[Key testing principles for this project]

### Test Categories
[Categories of tests and their locations]

### Pre-Commit Checklist
- [ ] Run tests and ensure all pass
- [ ] Check coverage thresholds
- [ ] Add tests for new functionality

---

## Database
[Database details, migration workflow, or reference to rules file]

---

## Domain Glossary

| Term | Definition |
|------|------------|
| [Domain term] | [What it means in this project] |

---

## Do NOT

- [Things to avoid in this project]
- [Anti-patterns specific to this codebase]
- [Common mistakes to prevent]

---

## Critical Warnings

- [Important gotchas]
- [Common pitfalls to avoid]

---

## Commit Standards
[Commit message format expected]

---

## Escalation

If you encounter:
- Breaking changes to core APIs -> [guidance]
- Security concerns -> [guidance]
- Unclear requirements -> Ask for clarification before proceeding
```

---

### Phase 3: Confirmation & Next Steps

After generating CLAUDE.md:

1. **Summarize** what was discovered and documented
2. **Highlight** any areas that need human input to complete
3. **Suggest** any additional documentation that might be helpful (e.g., `.claude/rules/` files for database or lessons learned)
4. **Ask** if there are any project-specific conventions or guidelines to add

---

## Output Requirements

- Place `CLAUDE.md` in the project root directory
- Use clear, concise language
- Include actual values discovered from the project (not placeholders)
- Mark any sections that need human review with `[REVIEW NEEDED]`
- Ensure the file is immediately useful for new agent sessions
