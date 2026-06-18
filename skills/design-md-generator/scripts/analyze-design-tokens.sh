#!/usr/bin/env bash
#
# analyze-design-tokens.sh — frequency analysis of Tailwind utility classes.
#
# Mines the ACTUAL design tokens a project uses by counting how often each
# utility value appears across component markup. The highest-frequency values
# are the de-facto design system; rare values are usually one-offs.
#
# Usage:
#   bash analyze-design-tokens.sh [src-dir]    # defaults to ./src
#
# Searches .tsx .jsx .ts .js .vue .svelte .html files.

set -euo pipefail

DIR="${1:-./src}"

if [ ! -d "$DIR" ]; then
  echo "Error: directory '$DIR' not found" >&2
  exit 1
fi

# Build the file list once (NUL-safe).
FILES=$(find "$DIR" -type f \( \
  -name '*.tsx' -o -name '*.jsx' -o -name '*.ts' -o -name '*.js' \
  -o -name '*.vue' -o -name '*.svelte' -o -name '*.html' \
\) 2>/dev/null)

if [ -z "$FILES" ]; then
  echo "Error: no source files found under '$DIR'" >&2
  exit 1
fi

# top <regex> <count> — print the N most frequent matches of an extended regex.
top() {
  local pattern="$1" n="${2:-20}"
  echo "$FILES" | tr '\n' '\0' | xargs -0 grep -ohE "$pattern" 2>/dev/null \
    | sort | uniq -c | sort -rn | head -n "$n"
}

echo "===================================================================="
echo " Design token frequency report for: $DIR"
echo " ($(echo "$FILES" | wc -l | tr -d ' ') files scanned)"
echo "===================================================================="

echo; echo "## BACKGROUND COLORS (top 25)"
top 'bg-(gray|zinc|slate|neutral|stone|blue|indigo|purple|violet|cyan|sky|teal|green|emerald|lime|red|rose|pink|orange|amber|yellow)-[0-9]{2,3}(/[0-9]{1,3})?' 25

echo; echo "## TEXT COLORS (top 25)"
top 'text-(white|black|gray|zinc|slate|neutral|stone|blue|indigo|purple|violet|cyan|sky|teal|green|emerald|lime|red|rose|pink|orange|amber|yellow)(-[0-9]{2,3})?' 25

echo; echo "## BORDER COLORS (top 20)"
top 'border-(gray|zinc|slate|neutral|stone|blue|indigo|purple|violet|cyan|sky|teal|green|emerald|lime|red|rose|pink|orange|amber|yellow)-[0-9]{2,3}(/[0-9]{1,3})?' 20

echo; echo "## BORDER RADIUS"
top 'rounded(-(none|sm|md|lg|xl|2xl|3xl|full))?\b' 12

echo; echo "## FONT SIZES"
top 'text-(xs|sm|base|lg|xl|2xl|3xl|4xl|5xl|6xl)\b' 12

echo; echo "## FONT WEIGHTS"
top 'font-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black)\b' 10

echo; echo "## FONT FAMILY"
top 'font-(sans|serif|mono)\b' 5

echo; echo "## PADDING (all-sides / x / y)"
top '\bp[xy]?-[0-9]+(\.[0-9]+)?\b' 20

echo; echo "## GAP"
top '\bgap-[0-9]+(\.[0-9]+)?\b' 12

echo; echo "## SHADOWS"
top 'shadow(-(sm|md|lg|xl|2xl|inner|none))?\b' 10

echo; echo "## FOCUS RINGS (accessibility signal)"
top 'focus:ring-[a-z]+-[0-9]{2,3}' 10

echo
echo "Note: highest-frequency values are the de-facto tokens. Map class names to"
echo "concrete hex/rem/px values via references/tailwind-token-map.md."
