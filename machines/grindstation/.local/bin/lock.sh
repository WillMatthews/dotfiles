#!/usr/bin/env bash
# lock.sh — swaylock, then power the external displays back on at unlock.
#
# Why (see ~/Documents/SCREEN.md): swayidle's `resume` hook can't be trusted to
# bring the externals back. When a logind idle inhibitor appears mid-idle (e.g.
# orchid's "agent run in progress" block), swayidle drops its timeouts WITHOUT
# running the resume command — externals stay dark after you come back. The
# externals only ever go dark after the 600s lock, so unlocking is a reliable
# "user is back" signal.
set -uo pipefail

# Already locked (idle lock, then before-sleep, etc.) — the first instance's
# watcher will handle unlock.
pgrep -x "swaylock|swaylock-plugin" >/dev/null && exit 0

# Screensaver behind the lock (~/coding/screensaver): swaylock-plugin runs
# lock-bg.sh on each output. One pick per lock so every display matches; the
# shared seed + epoch let flightsim render one continuous scene across them.
# Same config file as plain swaylock. Falls back to plain swaylock if it's
# missing or fails to lock.
# -f returns once the lock is in place (required for before-sleep).
SS=/home/wam/coding/screensaver
PLUGIN=$SS/build/swaylock-plugin/build/swaylock-plugin
SAVER=$("$SS/pick-saver.sh")   # shuffle bag, so no long streaks
# lock-bg.sh reads the pick from here on every (re)start; $mod+n
# (lock-next.sh) rewrites it to skip to the next saver.
echo "$SAVER $((SRANDOM | 1)) $(date +%s.%N)" > "${XDG_RUNTIME_DIR:-/tmp}/lock-bg.cur"   # saver seed epoch
if [[ -x $PLUGIN ]] && "$PLUGIN" -f --command-each "$SS/lock-bg.sh" "$@"; then
    :
else
    swaylock -f "$@" || exit 1
fi

(
    while pgrep -x "swaylock|swaylock-plugin" >/dev/null; do sleep 1; done
    /home/wam/.local/bin/idle-displays.sh on
) </dev/null >/dev/null 2>&1 &
disown
