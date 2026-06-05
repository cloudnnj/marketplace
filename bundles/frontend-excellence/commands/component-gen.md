---
title: "Generate Component"
description: "Scaffold React component with Zustand store integration and tests"
category: "Development"
tags: [react, component, scaffold, testing, frontend]
version: "1.0"
model: "opus"
examples:
  - "/component-gen TaskList component to display tasks with filtering"
  - "/component-gen Create a DepartmentSelector dropdown component"
  - "/component-gen Build SearchBar with debounced query"
---

# Generate Component

Scaffolds a new React component with optional Zustand store and test files.

## Features

- Creates functional React component with TypeScript
- Generates Zustand store if state management needed
- Includes component tests with full coverage
- Applies Tailwind CSS styling
- Adds dark-theme support
- Integrates with existing project structure

## Usage

Provide the component name and a brief description of what it should do:

```
/component-gen MyComponent - displays user profile information
```

The command will:
1. Create `src/components/my-component/MyComponent.tsx`
2. Create `src/components/my-component/MyComponent.test.tsx`
3. Generate store if needed: `src/stores/my-entity.store.ts`
4. Apply project conventions and patterns

## Output

Generated files follow these conventions:
- Component files use PascalCase
- Store files use kebab-case
- All tests use co-location pattern
- Dark-theme Tailwind classes pre-applied

---
*Frontend Excellence Bundle Component*
