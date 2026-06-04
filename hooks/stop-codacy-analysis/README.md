# Stop: Codacy Analysis on Changed Files

A Stop hook that runs Codacy CLI against files changed in this session (working tree + staged + untracked) and rewakes Claude with any findings.

## What it does

- Reads the Stop payload from stdin (extracts `session_id` for per-session rewake cap).
- Collects files changed in the working tree, staged area, and untracked listings.
- Runs `codacy-cli analyze` against just those files (full-repo runs can take minutes).
- Honors `.codacy/codacy.yaml` `exclude_paths`.
- Exits 0 when clean. Exits 2 with findings on stderr to rewake Claude.
- Caps rewakes per session via `CODACY_STOP_MAX_REWAKES` (default 1) so sessions can actually end.

## Requirements

- `jq`.
- `codacy-cli` installed and on `$PATH`.
- A `.codacy/codacy.yaml` (optional but recommended for excludes).

## IMPORTANT — full settings

**The marketplace install registers only the command path with default settings (60s timeout).** The full project config relies on `asyncRewake` + a longer timeout + custom rewake message. After install, edit `.claude/settings.json` to match:

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/stop-codacy-analysis.sh",
  "timeout": 300,
  "asyncRewake": true,
  "rewakeSummary": "Codacy found issues — see reminder",
  "rewakeMessage": "Codacy CLI reported issues on files changed this session. Fix them before ending the session:",
  "statusMessage": "Running Codacy analysis on changed files..."
}
```

Without `asyncRewake`, the hook still runs but Claude won't be re-awoken — findings surface only on stderr.

## Environment variables

- `CODACY_STOP_MAX_REWAKES` — cap how many times this hook rewakes Claude per session. Default `1`.

## Portability

Generic — any repo that uses Codacy. The hook gracefully degrades when `codacy-cli` or `jq` are missing.
