#!/usr/bin/env bash
# Microphone (default source) — mic / mic-slash. No-arg prints state JSON;
# "toggle" mutes/unmutes then signals waybar (SIGRTMIN+10) for instant refresh.
SIG=10
MIC=$''         # microphone
MIC_OFF=$''     # microphone-slash

if [ "${1:-}" = "toggle" ]; then
  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle >/dev/null 2>&1
  pkill -RTMIN+"$SIG" waybar 2>/dev/null
  exit 0
fi

vol="$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)"
if printf '%s' "$vol" | grep -q MUTED; then
  jq -nc --arg t "<span size='x-large'>${MIC_OFF}</span>" \
    --arg tip "Mic muted" --arg c "muted" '{text:$t, tooltip:$tip, class:$c}'
else
  pct="$(printf '%s' "$vol" | awk '{ printf "%d", $2*100 }')"
  jq -nc --arg t "<span size='x-large'>${MIC}</span>" \
    --arg tip "Mic live (${pct}%)" --arg c "live" '{text:$t, tooltip:$tip, class:$c}'
fi
