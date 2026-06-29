#!/usr/bin/env bash
# hp-dock-layout.sh — apply the HP USB-C Dock G5 triple-display layout by hand.
#
# Use this when kanshi gets it wrong (e.g. brings the vertical panel up
# upside-down, or falls through to the `mobile` profile and forces eDP@300
# so the laptop goes dark).
#
# Panels are found by SERIAL, not connector: the HP dock's DP connector
# numbers are NOT stable (seen DP-7/DP-8 on 2026-06-26, DP-9/DP-10 on
# 2026-06-29), which is exactly what breaks connector-based kanshi rules.
# Serials have been stable: …885 = portrait/left, …621 = landscape/right.
#
# Layout: vertical-left (flipped panel) | laptop-centre | horizontal-right
#   - …885 = portrait MSI, mounted 180°-flipped -> sway transform 270 = upright
#   - …621 = landscape MSI -> transform normal
#   - eDP-2 capped at 240Hz (300Hz blows the iGPU budget with two externals)
#
# Transform values here are sway ON-SCREEN values (swaymsg), NOT the kanshi
# config values — no 90<->270 swap to worry about. (kanshi config uses 90 for
# the same panel; see ~/.config/kanshi/config.)
set -euo pipefail

LEFT_SERIAL=CC2HM54A00885   # portrait, left
RIGHT_SERIAL=CC2HM54A00621  # landscape, right

# Resolve the current connector name for a given panel serial.
conn_for_serial() {
    swaymsg -t get_outputs \
        | jq -r --arg s "$1" '.[] | select(.serial==$s) | .name' \
        | head -n1
}

LEFT=$(conn_for_serial "$LEFT_SERIAL")
RIGHT=$(conn_for_serial "$RIGHT_SERIAL")

if [[ -z "$LEFT" || -z "$RIGHT" ]]; then
    echo "ERROR: could not find both MSI panels by serial." >&2
    echo "  left  ($LEFT_SERIAL): ${LEFT:-<not connected>}" >&2
    echo "  right ($RIGHT_SERIAL): ${RIGHT:-<not connected>}" >&2
    echo "Connected outputs:" >&2
    swaymsg -t get_outputs | jq -r '.[] | "  \(.name)  \(.make) \(.model)  serial=\(.serial)"' >&2
    exit 1
fi

echo "Resolved panels: left=$LEFT ($LEFT_SERIAL)  right=$RIGHT ($RIGHT_SERIAL)"

swaymsg output "$LEFT"  enable transform 270    scale 1   mode 2560x1440@60Hz  position 0 0
swaymsg output eDP-2    enable scale 1.3                  mode 2560x1600@240Hz position 1440 665
swaymsg output "$RIGHT" enable transform normal scale 1   mode 2560x1440@60Hz  position 3409 560

echo "Applied HP-dock triple layout. Current outputs:"
swaymsg -t get_outputs | python3 -c '
import json, sys
for o in json.load(sys.stdin):
    if not o.get("active"):
        continue
    r = o["rect"]
    m = o.get("current_mode") or {"width": 0, "height": 0, "refresh": 0}
    print("  {:6} power={} {:8} pos={},{} {}x{}@{}".format(
        o["name"], o.get("power"), o.get("transform"),
        r["x"], r["y"], m["width"], m["height"], m["refresh"] // 1000))'
