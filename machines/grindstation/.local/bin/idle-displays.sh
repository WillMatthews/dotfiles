#!/usr/bin/env bash
# idle-displays.sh {off|on} — DPMS-toggle the EXTERNAL outputs only, never eDP.
#
# Why this exists (see ~/Documents/SCREEN.md):
#   swayidle used to run `swaymsg "output * power off"` / `... power on`, which
#   includes the internal panel eDP-2. On this Meteor Lake iGPU the eDP link
#   bring-UP (DDI BUF A / PHY A) intermittently fails on resume:
#       [drm] *ERROR* Failed to bring PHY A to idle.
#       [drm] *ERROR* Timeout waiting for DDI BUF A to get active
#   The two external DPs recover, the laptop panel stays dark, and `power on`
#   does no retry — you tap a key, everything wakes EXCEPT the laptop screen.
#
# Powering eDP OFF is safe; powering it back ON is the gamble. So we simply
# never cycle it: leave eDP-2 lit (swaylock already covers its content) and
# only DPMS the externals, whose bring-up is reliable. External connector
# names are unstable across dock hotplugs (DP-7/8 <-> DP-9/10), so enumerate
# at runtime rather than hardcoding.
set -uo pipefail
# No `set -e`: a transient swaymsg IPC failure must not abort the whole run
# (suspected cause of externals staying dark after idle-wake, 2026-09-25).

action="${1:?usage: idle-displays.sh off|on}"
case "$action" in off|on) ;; *) echo "usage: idle-displays.sh off|on" >&2; exit 2 ;; esac

log="${XDG_STATE_HOME:-$HOME/.local/state}/idle-displays.log"
mkdir -p "$(dirname "$log")"
say() { echo "$(date '+%F %T') [$action] $*" >>"$log"; }

# Every output whose name is NOT the internal panel (eDP*), with its power state.
externals_state() {
    swaymsg -t get_outputs 2>/dev/null \
        | jq -r '.[] | select(.name | test("^eDP"; "i") | not) | "\(.name) \(.power)"'
}

want=$([ "$action" = on ] && echo true || echo false)

# Up to 5 attempts, 1s apart: re-enumerate each time (connector names shuffle
# across dock hotplugs) and only re-issue power to outputs not yet in state.
for attempt in 1 2 3 4 5; do
    pending=()
    while read -r name power; do
        [ -n "$name" ] && [ "$power" != "$want" ] && pending+=("$name")
    done < <(externals_state)

    if [ ${#pending[@]} -eq 0 ]; then
        say "ok (attempt $attempt)"
        exit 0
    fi

    say "attempt $attempt: power $action -> ${pending[*]}"
    for o in "${pending[@]}"; do
        swaymsg output "$o" power "$action" >/dev/null 2>&1 || say "swaymsg failed for $o"
    done
    sleep 1
done

say "GAVE UP; still not $action: $(externals_state | tr '\n' ' ')"
exit 1
