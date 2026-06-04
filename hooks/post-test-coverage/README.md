# Post-Test: Coverage Threshold Check

A PostToolUse hook for `Bash` that runs after `vitest`/`npm test`/`npm run test*` invocations. Parses `coverage/coverage-summary.json` and emits a JSON decision block listing which metrics (statements/lines/branches/functions) fell below threshold.

## What it does

- Reads the tool-call payload from stdin (JSON, via `jq`).
- Triggers only when the command looks like a test run.
- Loads thresholds from `.github/coverage-thresholds.json` if present.
- Falls back to defaults of 95% (statements/lines), 93% (branches), 90% (functions).
- Exits silently when coverage meets all thresholds or no summary exists.

## Requirements

- `jq`.
- A test runner that writes `coverage/coverage-summary.json` (vitest with `--coverage` is the canonical case).

## Recommended settings

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-test-coverage.sh",
  "timeout": 15,
  "statusMessage": "Checking coverage thresholds..."
}
```

## Customization

Adjust thresholds by creating `.github/coverage-thresholds.json` in your repo:

```json
{
  "statements": 90,
  "branches": 85,
  "functions": 80,
  "lines": 90
}
```

## Portability

Generic — works on any project with a coverage-summary.json output.
