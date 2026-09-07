#!/usr/bin/env bash
# Dunst Do-Not-Disturb — bell / bell-slash. No-arg prints state JSON; "toggle"
# flips DND then signals waybar (SIGRTMIN+9) for an instant refresh.
SIG=9
BELL=$''        # bell
BELL_OFF=$''    # bell-slash

if [ "${1:-}" = "toggle" ]; then
  dunstctl set-paused toggle >/dev/null 2>&1
  pkill -RTMIN+"$SIG" waybar 2>/dev/null
  exit 0
fi

if [ "$(dunstctl is-paused 2>/dev/null)" = "true" ]; then
  jq -nc --arg t "<span size='x-large'>${BELL_OFF}</span>" \
    --arg tip "Notifications paused (DND)" --arg c "paused" \
    '{text:$t, tooltip:$tip, class:$c}'
else
  jq -nc --arg t "<span size='x-large'>${BELL}</span>" \
    --arg tip "Notifications on" --arg c "active" \
    '{text:$t, tooltip:$tip, class:$c}'
fi
