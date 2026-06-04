# Marketplace Hooks — Staging Area

These are the 10 hooks from this project's `.claude/hooks/`, packaged for the CrewDeck marketplace per `electron/services/marketplace.service.ts`.

## Layout

Each package is a directory under `hooks/<name>/` with:

- `manifest.json` — `AgentManifestSchema` (name, version, displayName, description, tags, `itemType: "hook"`)
- `<name>.json` — `HookConfigSchema` (strict; only `{ "hooks": { <Event>: [{ matcher, hooks }] } }`)
- `<name>.sh` — the executable hook (copied verbatim from `.claude/hooks/<name>.sh`)
- `README.md` — human-readable docs (not installed, marketplace browsing only)

## Marketplace schema constraint

`HookConfigSchema` is `.strict()` and the inner `hooks` field is `z.array(z.string())`. That means **only the simple string form of a hook entry is accepted** — the richer object form (`type`, `timeout`, `statusMessage`, `asyncRewake`) does not validate at install time. Each package's README lists the recommended object-form settings users should apply by editing `.claude/settings.json` after install. The two hooks most affected are:

- `pre-commit-lint` — needs `timeout: 120` (default 60s is too tight for lint + typecheck).
- `stop-codacy-analysis` — relies on `asyncRewake: true` + `timeout: 300` + custom rewake messages.

## Hooks

| Hook | Event | Scope | Portability |
|---|---|---|---|
| `pre-tool-use-relative-paths` | PreToolUse | `Bash` | Generic |
| `pre-tool-use-gh-to-mcp` | PreToolUse | `Bash` | Generic (needs GitHub MCP) |
| `pre-commit-lint` | PreToolUse | `Bash` | Project-specific (`npm run lint`/`typecheck`) |
| `post-edit-schema` | PostToolUse | `Edit\|Write` on `**/electron/database/schema.ts` | Project-specific (Drizzle) |
| `post-edit-store` | PostToolUse | `Edit\|Write` on `src/stores/*.store.ts` | Project-specific (Zustand Map pattern) |
| `post-edit-docs-index` | PostToolUse | `Edit\|Write` on `**/docs/**/*.md` | Generic |
| `post-edit-types` | PostToolUse | `Edit\|Write` (self-filters to `shared/types.ts`) | Project-specific (Electron IPC) |
| `post-edit-renderer-imports` | PostToolUse | `Edit\|Write` (self-filters to `src/**`) | Project-specific (Electron renderer) |
| `post-test-coverage` | PostToolUse | `Bash` | Generic (any `coverage-summary.json`) |
| `stop-codacy-analysis` | Stop | — | Generic (needs `codacy-cli`) |

## Test scripts

The two test scripts in `.claude/hooks/` (`test-gh-to-mcp.sh`, `test-relative-paths.sh`) are **not** packaged — they aren't registered hooks. They live in the source project to validate the hook scripts locally and aren't expected at install destinations.

## Moving to the marketplace repo

Copy the `hooks/` subtree to the root of your marketplace repo, then trigger a marketplace sync from CrewDeck. The scanner walks `agents/`, `marketplace/`, `.claude/marketplace/`, `skills/`, `commands/`, and `hooks/`.
