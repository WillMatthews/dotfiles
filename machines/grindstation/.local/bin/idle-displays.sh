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
set -euo pipefail

action="${1:?usage: idle-displays.sh off|on}"
case "$action" in off|on) ;; *) echo "usage: idle-displays.sh off|on" >&2; exit 2 ;; esac

# Every active output whose name is NOT the internal panel (eDP*).
mapfile -t externals < <(swaymsg -t get_outputs | jq -r '.[] | select(.name | test("^eDP"; "i") | not) | .name')

for o in "${externals[@]}"; do
    swaymsg output "$o" power "$action" >/dev/null || true
done
