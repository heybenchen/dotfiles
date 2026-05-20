#!/usr/bin/env bash
# Claude Code status line
# Shows: model | context window usage | session usage (5h / 7d)
# Line 2: current git branch

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ANSI codes
dim="\033[2m"
bold="\033[1m"
reset="\033[0m"
blue="\033[0;34m"
green="\033[0;32m"
yellow="\033[0;33m"
red="\033[0;31m"

# Build context usage indicator
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    ctx_color="$red"
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="$yellow"
  else
    ctx_color="$green"
  fi
  ctx_part="${dim}ctx:${reset}${ctx_color}${used_int}%${reset}"
else
  ctx_part=""
fi

# Build session usage indicator (5-hour and 7-day rate limits)
session_part=""
if [ -n "$five_hour" ]; then
  five_int=$(printf '%.0f' "$five_hour")
  if [ "$five_int" -ge 80 ]; then
    five_color="$red"
  elif [ "$five_int" -ge 50 ]; then
    five_color="$yellow"
  else
    five_color="$green"
  fi
  session_part="${dim}5h:${reset}${five_color}${five_int}%${reset}"
fi
if [ -n "$seven_day" ]; then
  seven_int=$(printf '%.0f' "$seven_day")
  if [ "$seven_int" -ge 80 ]; then
    seven_color="$red"
  elif [ "$seven_int" -ge 50 ]; then
    seven_color="$yellow"
  else
    seven_color="$green"
  fi
  if [ -n "$session_part" ]; then
    session_part="${session_part}  ${dim}7d:${reset}${seven_color}${seven_int}%${reset}"
  else
    session_part="${dim}7d:${reset}${seven_color}${seven_int}%${reset}"
  fi
fi

# Get current git branch
cwd=$(echo "$input" | jq -r '.cwd // empty')
branch=""
if [ -n "$cwd" ]; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
fi

# Assemble the status line
line="${dim}model:${reset}${bold}${blue}${model}${reset}"
[ -n "$ctx_part" ]     && line="${line}  ${ctx_part}"
[ -n "$session_part" ] && line="${line}  ${session_part}"

# Second line: git branch
if [ -n "$branch" ]; then
  line="${line}\n${dim}branch:${reset}${bold}${branch}${reset}"
fi

printf "%b\n" "$line"
