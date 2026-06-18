# DESIGN.md Format Specification

A DESIGN.md has two layers:
1. **YAML front matter** (between `---` fences) — machine-readable exact values agents parse programmatically.
2. **Markdown body** — human-readable prose explaining *why* tokens exist and *how/when* to apply them.

> "Tokens give agents exact values. Prose tells them why those exist and how to apply them."

## Table of Contents
- [YAML front matter](#yaml-front-matter)
- [Colors](#colors)
- [Typography](#typography)
- [Rounded (border radius)](#rounded-border-radius)
- [Spacing](#spacing)
- [Components](#components)
- [The eight canonical markdown sections](#the-eight-canonical-markdown-sections)
- [Minimal example](#minimal-example)

## YAML front matter

Top-level keys: `name`, `colors`, `typography`, `rounded`, `spacing`, `components`.

### Colors
Hex values in sRGB, prefixed with `#`. Recommended **semantic names**: `primary`, `secondary`, `tertiary`, `neutral`, `surface`, `on-surface`, `error`. Custom names (any valid string) are allowed, but **`primary` is required for linting to pass.** Add as many custom color tokens as the project actually uses (background tiers, text hierarchy, status colors, categorical colors).

### Typography
Recommended **9–15 levels**. A practical set: `headline-display`, `headline-lg`, `headline-md`, `body-lg`, `body-md`, `body-sm`, `label-lg`, `label-md`, `label-sm`. Each token is an object with any of:
- `fontFamily` (string)
- `fontSize` (dimension with unit: px/em/rem)
- `fontWeight` (number: 400, 700, …)
- `lineHeight` (unitless multiplier or dimension)
- `letterSpacing` (dimension)
- `fontFeature` (string → CSS `font-feature-settings`)
- `fontVariation` (string → CSS `font-variation-settings`)

### Rounded (border radius)
Named scale: `none`, `sm`, `md`, `lg`, `xl`, `full`. Values are dimensions with units. (Extra steps like `base`/`2xl`/`3xl` are fine.)

### Spacing
Named scale: `xs`, `sm`, `md`, `lg`, `xl`. Values are dimensions or plain numbers.

### Components
Reference tokens with **`{path.to.token}` syntax** (e.g. `{colors.tertiary}`, `{typography.label-caps}`, `{rounded.sm}`). This keeps values DRY and lets the linter verify references resolve. Valid component properties: `backgroundColor`, `textColor`, `typography`, `rounded`, `padding`, `size`, `height`, `width`. Variants use related keys, e.g. `button-primary`, `button-primary-hover`, `button-primary-active`.

## The eight canonical markdown sections

When present, sections must follow this order (the linter warns on out-of-order sections; unknown headings are preserved without error; not all are required):

1. **Overview** (alias: "Brand & Style") — holistic product description, brand personality, emotional tone.
2. **Colors** — palettes with semantic roles and usage guidelines.
3. **Typography** — type scale, font pairings, hierarchy rules.
4. **Layout** (alias: "Layout & Spacing") — grid models, spacing strategy, responsive behavior.
5. **Elevation & Depth** (alias: "Elevation") — shadow and depth techniques.
6. **Shapes** — border radius, corner treatments, decorative geometry.
7. **Components** — style guidance for UI atoms (buttons, cards, inputs, navigation).
8. **Do's and Don'ts** — guardrails and common pitfalls.

Write prose that is *project-specific*: which accent means what, dark vs light theme, when to reach for each type level, the shadow/elevation strategy, spacing discipline, and any platform constraints discovered (e.g. CSP blocking inline styles, no web fonts).

## Minimal example

```markdown
---
name: Acme Corp
colors:
  primary: "#1A1C1E"
  secondary: "#6C7278"
  tertiary: "#B8422E"
  neutral: "#F7F5F2"
  surface: "#FFFFFF"
  on-surface: "#1A1C1E"
  error: "#D32F2F"
typography:
  headline-lg:
    fontFamily: Public Sans
    fontSize: 2.5rem
    fontWeight: 700
    lineHeight: 1.2
  body-md:
    fontFamily: Public Sans
    fontSize: 1rem
    fontWeight: 400
    lineHeight: 1.6
  label-caps:
    fontFamily: Space Grotesk
    fontSize: 0.75rem
    fontWeight: 600
    letterSpacing: 0.08em
rounded:
  sm: 4px
  md: 8px
  lg: 16px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 48px
components:
  button-primary:
    backgroundColor: "{colors.tertiary}"
    textColor: "{colors.neutral}"
    typography: "{typography.label-caps}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
  button-primary-hover:
    backgroundColor: "#9A3521"
  card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.md}"
    padding: "{spacing.lg}"
---
## Overview
Acme Corp's design language is industrial and confident...

## Colors
The primary palette is deliberately restrained...

## Typography
Two families. Public Sans for everything structural...

## Components
### Buttons
Primary buttons use the Boston Clay accent with cream text...

## Do's and Don'ts
- Do use the tertiary accent sparingly...
- Don't mix Space Grotesk into body text...
```
