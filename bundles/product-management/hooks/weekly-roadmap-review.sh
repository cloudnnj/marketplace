#!/usr/bin/env bash
# CronSchedule hook: Assembles a weekly roadmap review packet for the product team.
# Scheduled to run Friday at 9 AM PT so the team can review progress and re-prioritize.
#
# Schedule: 0 9 * * 5 (every Friday at 9 AM PT)

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_FILE="${PROJECT_DIR}/.claude/logs/roadmap-review-$(date +%Y%m%d).log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[${TIMESTAMP}] $*" >> "$LOG_FILE"
}

log "Starting weekly roadmap review..."

# Pull the latest product metrics to ground the review in outcomes (example - adapt to your stack)
log "Fetching product metrics..."
if ! node "${PROJECT_DIR}/scripts/export-product-metrics.js" --range=7d > "${PROJECT_DIR}/.claude/data/product-metrics-$(date +%Y%m%d).json" 2>>"$LOG_FILE"; then
  log "WARNING: Failed to export product metrics, proceeding without outcome context"
fi

# Collect shipped work and roadmap status from the issue tracker
log "Collecting shipped items and roadmap status..."
if ! node "${PROJECT_DIR}/scripts/collect-roadmap-status.js" 2>>"$LOG_FILE"; then
  log "ERROR: Roadmap status collection failed"
  exit 1
fi

log "Roadmap status collected successfully"

# Re-score the backlog so prioritization reflects the latest signal
log "Re-scoring backlog..."
if ! node "${PROJECT_DIR}/scripts/rescore-backlog.js" 2>>"$LOG_FILE"; then
  log "WARNING: Backlog re-scoring encountered issues"
fi

# Assemble the review packet for the team (not auto-published)
log "Assembling review packet..."
if ! node "${PROJECT_DIR}/scripts/build-review-packet.js" --out "${PROJECT_DIR}/.claude/data/roadmap-review-$(date +%Y%m%d).md" 2>>"$LOG_FILE"; then
  log "WARNING: Review packet assembly encountered issues"
fi

log "Weekly roadmap review completed"
exit 0
