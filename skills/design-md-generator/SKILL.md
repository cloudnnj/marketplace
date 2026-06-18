---
name: design-md-generator
description: Generate a DESIGN.md design-system spec at a project root by extracting the project's ACTUAL design tokens from its code (CSS theme files, Tailwind config, and the frequency of utility classes used across components). Produces the two-layer DESIGN.md format — machine-readable YAML front matter (colors, typography, rounded, spacing, components) plus a human-readable markdown body with the canonical sections. Use when the user asks to create, generate, bootstrap, or update a DESIGN.md / design system spec / design tokens file for a repo, especially Tailwind + React/Vue/Svelte projects.
---

# DESIGN.md Generator

## Overview

Produces a `DESIGN.md` design-system spec grounded in what a project actually renders — not invented values. The core principle: **mine the real tokens from the codebase, then codify them.** A made-up palette is worse than no spec; agents will trust DESIGN.md as ground truth.

## Workflow

Follow these steps in order.

### 1. Find the styling foundation

Locate where design primitives are declared:
- **Tailwind v4**: `@theme { ... }` blocks inside CSS (e.g. `src/index.css`, `app.css`). Custom `--color-*`, `--font-*`, `--spacing-*`, `--radius-*`, `--animate-*` vars live here. There is usually **no `tailwind.config.js`** in v4.
- **Tailwind v3**: `tailwind.config.{js,ts}` — read `theme.extend` for custom colors/fonts/spacing.
- **CSS variables**: `:root { --... }` in any global stylesheet.
- **Other**: styled-components themes, MUI/Chakra theme objects, `theme.ts`/`tokens.ts` files, SCSS `$variables`.

Also read the global stylesheet end-to-end for: custom keyframe animations, scrollbar styling, font-family declarations, named utility classes, and any CSP/inline-style constraints. Check `index.html` and the entry component for `font-family` and the base `<body>` classes (these reveal the default theme — e.g. dark vs light).

### 2. Mine the real token usage

Most Tailwind projects keep the default theme and express the palette through **utility classes in markup**. The dominant values *are* the design system. Run the bundled frequency analyzer:

```bash
bash scripts/analyze-design-tokens.sh <src-dir>    # defaults to ./src
```

It reports the top background/text/border colors, border-radius, font sizes, font weights, spacing (padding/gap), and font-family signals — each with counts. Treat the highest-frequency values as the canonical tokens; rare values are usually one-offs, not part of the system.

If the project doesn't use Tailwind, fall back to grepping the theme object / CSS variables found in step 1 instead.

### 3. Capture component tokens

Find the canonical shared components and quote their exact class strings — these define component tokens precisely:
- Buttons: search for a shared `Button` component (`buttonClassName`, `VARIANT_CLASSES`, `SIZE_CLASSES`).
- Cards/panels/surfaces: shared `Card`/`Surface` components, or the most representative repeated container.
- Inputs/selects: a representative form field.

Prefer a shared component's variant map over scattered inline usage — it's the source of truth.

### 4. Map utility classes to concrete values

DESIGN.md requires real values (hex, rem, px), not Tailwind class names. Convert using `references/tailwind-token-map.md` (default palette → hex, text sizes → rem + line-height, spacing → px, radius → px). Only consult it for the values that actually appear in the frequency report.

### 5. Write DESIGN.md

Read `references/format-spec.md` for the exact two-layer structure, required/semantic token names, the `{path.to.token}` reference syntax, and the eight canonical markdown sections in order. Then write `DESIGN.md` at the project root:
- **YAML front matter**: `name`, `colors` (must include `primary`), `typography` (9–15 levels), `rounded`, `spacing`, `components` (referencing tokens via `{...}`).
- **Markdown body**: the canonical sections (Overview, Colors, Typography, Layout, Elevation, Shapes, Components, Do's and Don'ts) — explaining *why* tokens exist and *how/when* to apply them, with project-specific guidance derived from what was observed (e.g. which accent means what, dark vs light, shadow strategy, CSP constraints).

Add a comment next to each token noting its source class (e.g. `# gray-800`) so the spec stays traceable.

### 6. Verify

Confirm every `{path.to.token}` reference in `components` resolves to a defined token, sections appear in canonical order, and `colors.primary` is present (linting requires it).
