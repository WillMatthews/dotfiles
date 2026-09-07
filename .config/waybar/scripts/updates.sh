#!/usr/bin/env bash
# APT updates — count via update-notifier's apt-check (fast; prints
# "regular;security" on stderr). The count is cached in the per-user runtime dir
# with a long TTL so all bar instances share one result instead of each monitor
# re-running apt-check. Click opens the upgradable list in a pager.
RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
CACHE="$RT/waybar-updates.count"
TTL=1800
ICON=$''   # cloud-download (BMP)

now="$(date +%s)"
age=999999
[ -s "$CACHE" ] && age=$(( now - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))

if (( age >= TTL )); then
  counts="$(/usr/lib/update-notifier/apt-check 2>&1)"   # "regular;security"
  [ -z "$counts" ] && counts="0;0"
  ( umask 077; printf '%s' "$counts" > "$CACHE.tmp" ) && mv -f "$CACHE.tmp" "$CACHE"
fi

counts="$(cat "$CACHE" 2>/dev/null)"; counts="${counts:-0;0}"
reg="${counts%;*}"; sec="${counts#*;}"
reg="${reg:-0}"; sec="${sec:-0}"

if   (( sec > 0 )); then cls="critical"
elif (( reg > 0 )); then cls="warning"
else                     cls="ok"
fi

tip="${reg} package(s) upgradable"
(( sec > 0 )) && tip="${tip}"$'\n'"${sec} security update(s)"

jq -nc \
  --arg t "<span size='x-large'>${ICON}</span>  <span rise='2000'>${reg}</span>" \
  --arg tip "$tip" --arg c "$cls" '{text:$t, tooltip:$tip, class:$c}'
