#!/usr/bin/env bash
# CronSchedule hook: Syncs CRM pipeline data daily for forecasting and health scoring.
# Scheduled to run at 6 AM PT before the sales team's morning standup.
#
# Schedule: 0 6 * * * (daily at 6 AM PT)

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_FILE="${PROJECT_DIR}/.claude/logs/pipeline-sync-$(date +%Y%m%d).log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[${TIMESTAMP}] $*" >> "$LOG_FILE"
}

log "Starting daily pipeline sync..."

# Check CRM connectivity (example - adapt to your CRM)
if ! command -v crm-cli &>/dev/null; then
  log "ERROR: CRM CLI not found, skipping sync"
  exit 1
fi

# Fetch latest pipeline data
log "Fetching pipeline data from CRM..."
if ! crm-cli export pipeline --format=json > "${PROJECT_DIR}/.claude/data/pipeline-$(date +%Y%m%d).json" 2>>"$LOG_FILE"; then
  log "ERROR: Failed to export pipeline data"
  exit 1
fi

log "Pipeline data exported successfully"

# Run health scoring on updated data
log "Updating customer health scores..."
if ! node "${PROJECT_DIR}/scripts/update-health-scores.js" 2>>"$LOG_FILE"; then
  log "WARNING: Health score update encountered issues"
fi

# Update forecasts
log "Regenerating weekly forecast..."
if ! node "${PROJECT_DIR}/scripts/generate-forecast.js" 2>>"$LOG_FILE"; then
  log "WARNING: Forecast generation encountered issues"
fi

# Check for churn risks and send alerts
log "Checking for churn risks..."
if ! node "${PROJECT_DIR}/scripts/check-churn-risks.js" --alert 2>>"$LOG_FILE"; then
  log "WARNING: Churn risk check encountered issues"
fi

log "Daily pipeline sync completed"
exit 0
