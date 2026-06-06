#!/usr/bin/env bash
# CronSchedule hook: Prepares and queues the upcoming week's social media content.
# Scheduled to run Monday at 8 AM PT so drafts are ready for the team's weekly review.
#
# Schedule: 0 8 * * 1 (every Monday at 8 AM PT)

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_FILE="${PROJECT_DIR}/.claude/logs/content-scheduler-$(date +%Y%m%d).log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[${TIMESTAMP}] $*" >> "$LOG_FILE"
}

log "Starting weekly content scheduling..."

# Check social scheduling tool connectivity (example - adapt to your stack)
if ! command -v social-cli &>/dev/null; then
  log "ERROR: social-cli not found, skipping scheduling"
  exit 1
fi

# Pull last week's performance data to inform this week's plan
log "Fetching last week's campaign analytics..."
if ! social-cli analytics export --range=7d --format=json > "${PROJECT_DIR}/.claude/data/social-analytics-$(date +%Y%m%d).json" 2>>"$LOG_FILE"; then
  log "WARNING: Failed to export analytics, proceeding without performance context"
fi

# Generate this week's content calendar from pillars and upcoming launches
log "Generating weekly content calendar..."
if ! node "${PROJECT_DIR}/scripts/generate-content-calendar.js" 2>>"$LOG_FILE"; then
  log "ERROR: Content calendar generation failed"
  exit 1
fi

log "Content calendar generated successfully"

# Draft platform-native copy for each scheduled post
log "Drafting post copy..."
if ! node "${PROJECT_DIR}/scripts/draft-post-copy.js" 2>>"$LOG_FILE"; then
  log "WARNING: Post copy drafting encountered issues"
fi

# Queue drafts to the scheduler for team review (not auto-published)
log "Queuing drafts for review..."
if ! social-cli queue import --status=draft --dir "${PROJECT_DIR}/.claude/data/drafts" 2>>"$LOG_FILE"; then
  log "WARNING: Failed to queue some drafts"
fi

log "Weekly content scheduling completed"
exit 0
