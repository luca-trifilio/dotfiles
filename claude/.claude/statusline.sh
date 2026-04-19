#!/bin/bash

# Read JSON input
input=$(cat)

# Colors
RESET="\033[0m"
CYAN="\033[36m"
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
MAGENTA="\033[35m"
DIM="\033[2m"

# Model name
model=$(echo "$input" | jq -r '.model.display_name // "?"')

# Current directory (basename only)
dir=$(echo "$input" | jq -r '.cwd // ""')
dir_name=$(basename "$dir" 2>/dev/null || echo "?")

# Git branch and status
git_info=""
if [ -n "$dir" ] && [ -d "$dir/.git" ]; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    if ! git -C "$dir" diff --quiet 2>/dev/null || ! git -C "$dir" diff --cached --quiet 2>/dev/null; then
      git_info="${YELLOW}${branch}*${RESET}"
    else
      git_info="${GREEN}${branch}${RESET}"
    fi
  fi
fi

# Context usage
pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
bar_width=10
filled=$((pct * bar_width / 100))
empty=$((bar_width - filled))
if [ "$pct" -lt 50 ]; then
  BAR_COLOR="${GREEN}"
elif [ "$pct" -lt 80 ]; then
  BAR_COLOR="${YELLOW}"
else
  BAR_COLOR="${RED}"
fi
bar="${BAR_COLOR}["
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done
bar+="] ${pct}%${RESET}"

# Cost
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_fmt=$(echo "$cost" | LC_ALL=C awk '{printf "%.2f", $1}')

# Vim mode
vim_mode=$(echo "$input" | jq -r '.vim.mode // ""')
case "$vim_mode" in
  NORMAL)  vim_info="${GREEN}N${RESET}" ;;
  INSERT)  vim_info="${YELLOW}I${RESET}" ;;
  VISUAL)  vim_info="${MAGENTA}V${RESET}" ;;
  *)       vim_info="" ;;
esac

# Build output
SEP="${DIM}|${RESET}"
output="${CYAN}${dir_name}${RESET}"
[ -n "$git_info" ] && output+=" ${SEP} ${git_info}"
[ -n "$vim_info" ] && output+=" ${SEP} ${vim_info}"
output+=" ${SEP} ${MAGENTA}${model}${RESET}"
output+=" ${SEP} ${bar}"
output+=" ${SEP} 💰 ${GREEN}\$${cost_fmt}${RESET}"

echo -e "$output"
