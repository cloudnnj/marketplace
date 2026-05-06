---
title: "Refine Prompt"
description: "Enrich and refine AI prompts into a detailed implementation plan with project context"
category: "Operations"
tags: [prompt, refinement, ai-engineering, context, planning]
model: "opus"
tools: Read, Grep, Glob, Bash
thinking: ultra
version: "2.4"
examples:
  - "/refine-prompt draft-prompt.md"
  - "/refine-prompt Add authentication to user profile"
---

# Refine Prompt

ultrathink

You are turning a raw task description into a **detailed implementation plan** — the kind of document a senior engineer hands to an AI engineer (or a teammate) so they can execute without guessing. The plan you produce IS the deliverable. It is not a summary of what you did, not a chat reply, not a wrapper around the plan. It is the plan itself. Output it directly — begin with the `#` title and end with the final line of the plan, with nothing before or after.

> **CRITICAL OUTPUT CONSTRAINT — read before doing anything else:**
> Your entire response MUST start with the character `#` (a markdown heading). No sentence, word, or character may appear before it. Any preamble — including "Here is the plan:", "I've analyzed the codebase…", "The refined prompt is below:", or any similar framing — will cause automated extraction to fail and the task to abort. The orchestrator reads your raw output; it is not displayed to a human first. Write the plan directly. The first byte you emit must be `#`.

## Input Task
$ARGUMENTS

## Your Mission

Treat this like Claude's planning mode: think deeply, then commit to a concrete, file-level plan.

1. **Parse the request.** Identify the core objective, in-scope behavior, and what is explicitly *not* being asked for. Note any ambiguity that the implementer must resolve before coding.
2. **Map the codebase.** Use Glob, Grep, and Read to locate the actual files, services, stores, IPC channels, schemas, and tests this will touch. Do not invent paths — cite real ones.
3. **Find the precedent.** Identify at least one existing pattern in this repo that the implementation should mirror (e.g. an analogous IPC handler, store, component, or migration). Reference it by path and line range.
4. **Decide architecture.** Choose where each piece lives: which domain file in `shared/types/`, which schema in `electron/database/schemas/`, which `_shared/` service, which preload namespace, which Zustand store. Justify each placement against the rules in `CLAUDE.md` and the layered architecture.
5. **Sequence the work.** Order steps so the codebase compiles and tests pass at every phase boundary. Call out which steps can run in parallel and which are blocking.
6. **Plan parallel agents.** Map each work stream to the right specialized agent using the routing table in `.claude/rules/orchestration.md`. If the task spans 2+ domains (frontend + backend + database, etc.), design non-overlapping file scopes that can execute in parallel git worktrees. For single-domain tasks, recommend a single agent and skip worktrees.
7. **Surface risk.** Flag race conditions, schema constraints, native-module rebuilds, dual-DB locations, breaking IPC contracts, security-sensitive surfaces, and any "Lessons Learned" entry that applies (cite the lesson number).

## Hard Rules

- **No file writes. This is enforced.** Do NOT call `Write`, `Edit`, `MultiEdit`, or `Bash` to write to files — the orchestrator denies these tools for this command. Any attempt to write to disk instead of outputting text will result in captured output that is empty or invalid, causing the downstream task to fail. Your text output IS the artifact.
- **No preamble, no postamble. This will cause task failure.** The very first character of your output MUST be `#`. Do NOT write "The refined prompt has been generated", "The plan has been generated", "Here's a summary", "I've analyzed the codebase and…", "emitted to stdout", or any other framing. The last character must be the final character of the plan itself.
- **No meta-commentary** about your process, the tools you used, or how confident you are. The plan stands on its own.
- **No placeholders left in the output.** Every section must be filled in based on actual exploration. If a section genuinely does not apply, write "None." — never `[TODO]` or `[fill in]`.
- **Cite real paths.** Every file reference must exist in the repo or be a new file you are explicitly creating. Use `path:Lstart-Lend` for ranges when referencing existing code.
- **Mirror existing patterns.** When the repo has an established pattern (Map-based stores, `unwrapResult`, `withServiceResult`, domain-scoped schema files, HandlerModule), the plan must follow it — not invent a new one.
- **Follow CLAUDE.md.** Respect the modularization rules: never put new content in barrel files (`shared/types.ts`, `electron/database/schema.ts`, `electron/ipc/handlers/_shared.ts`, `electron/ipc/ipc-channel-schemas.ts`); always use the domain-scoped module.

## Output Format

Output ONLY the markdown document below. Begin directly with the `#` title line — do not introduce, summarize, or sign off. Your response IS the plan document.

```markdown
# [Feature/Task Title]

## Overview
One paragraph: what is being built and why. Include the user-visible behavior change, if any.

## Goals & Non-Goals
**Goals**
- [Concrete, testable goal]

**Non-Goals**
- [What this explicitly does not do — surface scope creep risks here]

## Architectural Context
- Layer(s) touched: [renderer | preload | main | database | services | workers]
- Domain(s): [tasks | terminal | github | …]
- Precedent in codebase: `path/to/analogous-file.ts:Lstart-Lend` — describe what to mirror

## Affected Files
| File | Change | Notes |
|------|--------|-------|
| `path/to/file.ts` | create / modify / delete | Specific edits, function names, or sections |

Group barrel files (`shared/types.ts`, `electron/database/schema.ts`, `electron/ipc/handlers/_shared.ts`, `electron/ipc/ipc-channel-schemas.ts`) separately and confirm whether they need a new re-export line — never inline new content into them.

## Data Model Changes
- New tables / columns (with types, constraints, indices) in `electron/database/schemas/{domain}.ts`
- Drizzle migration command: `npm run db:generate -- --name <descriptive_name>`
- Journal-timestamp check: confirm `_journal.json` `when` is monotonically increasing (Lesson #24)
- If no DB changes: state "None."

## IPC / API Contract
- New or modified channels (format `domain:action`)
- Zod schema additions in `electron/ipc/channel-schemas/{domain}.ts`
- Preload namespace: `electron/preload/namespaces/{domain}.ts`
- Shared types: `shared/types/{domain}.ts`
- ServiceResult shape and error codes
- If no IPC changes: state "None."

## Technical Approach
Walk through the implementation strategy in prose. Explain *why* this approach over alternatives. Reference the precedent file from Architectural Context. Include a Mermaid sequence diagram for any non-trivial control flow.

## Implementation Steps
Phase-numbered, each step concrete enough that an AI engineer can execute it without further interpretation.

### Phase 1 — [Foundation, e.g. schema + types]
1. [Action] in `path/to/file.ts` — [exact change]
2. …

### Phase 2 — [Backend, e.g. service + IPC]
1. …

### Phase 3 — [Frontend, e.g. store + components]
1. …

### Phase 4 — [Tests + verification]
1. …

Mark steps that can run in parallel with `(parallel)`. Mark steps that must complete before the next phase with `(blocking)`.

## Agent Parallelization Plan
Map work to specialized agents using the routing table in `.claude/rules/orchestration.md`. Pick the **Primary Agent** for each file pattern; only fall back to `@full-stack-developer` for cross-cutting work that touches 3+ domains and cannot be cleanly split.

If the task is single-domain (one agent owns everything), state `Single agent: @<agent-name>` and skip the rest of this section.

If the task is multi-domain, fill in:

### Agent Assignments
| Stream | Agent | Worktree Branch | Owned Files / Scope | Files NOT to Touch | Required Rules |
|--------|-------|-----------------|---------------------|--------------------|----------------|
| Database | @database-designer | `feature/<domain>-db` | `electron/database/schemas/<domain>.ts`, migration, `backwards-compat.ts` | `src/**`, `electron/services/**` | `database, lessons-concurrency, lessons-general` |
| Backend / IPC | @typescript-developer or @backend-developer | `feature/<domain>-backend` | `electron/services/<domain>.service.ts`, `electron/ipc/handlers/<domain>.ts`, `electron/ipc/channel-schemas/<domain>.ts`, `shared/types/<domain>.ts`, `electron/preload/namespaces/<domain>.ts` | `src/**`, schema files | `ipc, lessons-api-data, lessons-general` |
| Frontend | @frontend-developer | `feature/<domain>-frontend` | `src/stores/<domain>.store.ts`, `src/components/<domain>/**`, `src/pages/**` | `electron/**`, `shared/**` | `frontend, lessons-ui-layout, lessons-state-management, lessons-general` |
| Terminal (if applicable) | @terminal-specialist | `feature/<domain>-terminal` | `electron/services/terminal*`, `**/terminal/**` | unrelated services | `terminal, ipc, lessons-resources, lessons-concurrency, lessons-general` |
| Tests | @playwright-test-generator | `feature/<domain>-tests` | `**/*.test.*`, `e2e/**` | implementation files | `testing, frontend, lessons-state-management, lessons-general` |

Drop rows that don't apply. Add rows for any other stream the task requires (e.g. @performance-specialist for memory work, @code-security-auditor for IPC/auth surfaces).

### Parallel vs Sequential Execution
- **Parallel (run simultaneously in worktrees):** [list streams that can run at the same time because their file scopes don't overlap]
- **Sequential (must complete before downstream streams):** [e.g. Database must merge before Backend so types/schemas exist; Backend must merge before Frontend so `window.api` types are available]
- **Max parallel worktrees:** 3 (per `orchestration.md`)

### Worktree Setup
```bash
git worktree add -b feature/<domain>-db ../crewdeck-feature-<domain>-db
git worktree add -b feature/<domain>-backend ../crewdeck-feature-<domain>-backend
git worktree add -b feature/<domain>-frontend ../crewdeck-feature-<domain>-frontend
```

### Hotspot Ownership
Identify which agent owns each barrel/hotspot file edit. Only ONE agent may modify each:
- `electron/ipc/handlers/_shared/service-registry.ts` — owner: [agent]
- `shared/types/index.ts` (only if a brand-new domain file is added) — owner: [agent]
- `electron/preload/index.ts` (only if a brand-new namespace) — owner: [agent]
- `electron/ipc/handlers.ts` (only if a brand-new HandlerModule) — owner: [agent]

Other agents that need additions to these hotspots must list them under "Deferred Hotspot Changes" in their handoff so the owner applies them after their merge.

### Merge Order
Following the hotspot dependency order from `orchestration.md`:
1. [Stream] — [why first]
2. [Stream] — [why second]
3. [Stream] — [why last]

Run `npm test` after each merge. If a merge conflict occurs, prefer the LATER change and re-run tests.

### Verification Phase (Post-Merge)
- @quality-reviewer — always
- @code-security-auditor — required if any stream touched `electron/ipc/`, `electron/preload/`, `shared/types/`, auth, or credentials
- @coverage-orchestrator — required if coverage drops below 95/93/90 after merge

## Testing Strategy
- **Unit:** which `*.test.ts` files to add or extend, with the specific behaviors to assert
- **Integration:** store-level tests that exercise the `window.api` mock path
- **E2E (Playwright):** user flows to cover, if applicable
- **Edge cases & failure modes:** enumerate explicitly (network failure, empty state, concurrency, large payloads, idle timeouts, etc.)
- **Coverage:** confirm 95% statements / 95% lines / 93% branches / 90% functions thresholds will hold

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [e.g. race on concurrent task creation] | Medium | High | UNIQUE constraint + `onConflictDoNothing()` (Lesson #12) |

## Lessons Applied
List any `lessons-*.md` entries (by number and topic) that govern this change. If none apply, state "None."

## Rollout & Backwards Compatibility
- Migration ordering and reversibility
- Feature flag / staged rollout (if any)
- Cleanup obligations (delete-once-X TODOs, scheduled follow-ups)

## Open Questions
- [Question that the implementer or product owner must resolve before coding]
- If none: state "None."

## Acceptance Criteria
- [ ] [Verifiable outcome — behavior, not implementation detail]
- [ ] All affected tests pass; coverage thresholds hold
- [ ] No regressions in adjacent flows: [list flows]
- [ ] Documentation / `CLAUDE.md` updated if architecture changed
```
