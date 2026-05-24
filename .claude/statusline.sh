#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | xargs printf "%.0f")
IN_TOK=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOK=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' | xargs printf "%.4f")
ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0' | xargs printf "%.0f")
VIM=$(echo "$input" | jq -r '.vim.mode // empty')
AGENT=$(echo "$input" | jq -r '.agent.name // empty')
VERSION=$(echo "$input" | jq -r '.version // "?"')
SESSION=$(echo "$input" | jq -r '.session_id // "?"')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // ""')
CWD="${CWD:-$PWD}"
CWD="${CWD/#$HOME/~}"

# Abbreviate token count to k
tok() { [ "$1" -ge 1000 ] && printf "%dk" $(($1 / 1000)) || printf "%d" "$1"; }

# Format duration
SECS=$((DURATION_MS / 1000))
DURATION="${SECS}s"
[ "$SECS" -ge 60 ] && DURATION="$((SECS / 60))m$((SECS % 60))s"

# Optional parts
[ -n "$EFFORT" ] && MODEL_PART="$MODEL $EFFORT" || MODEL_PART="$MODEL"
[ -n "$VIM" ]   && VIM_PART=" $VIM"             || VIM_PART=""
[ -n "$AGENT" ] && AGENT_PART=" | $AGENT"       || AGENT_PART=""

CTX="ctx:${PCT}% ↓$(tok "$IN_TOK") ↑$(tok "$OUT_TOK") /$(tok "$CTX_SIZE") ♻ $(tok "$CACHE_READ") ＋$(tok "$CACHE_CREATE") \$${COST}"

echo "${CWD} │ ${MODEL_PART}${AGENT_PART}${VIM_PART} │ ${CTX} │ diff:+${ADDED}/-${REMOVED} ${DURATION} │ v${VERSION} │ ${SESSION}"
