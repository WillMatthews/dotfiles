#!/usr/bin/env bash
# hp-dock-layout.sh — apply the HP USB-C Dock G5 triple-display layout by hand.
#
# Use this when kanshi gets it wrong (e.g. brings the vertical panel up
# upside-down, or falls through to the `mobile` profile and forces eDP@300
# so the laptop goes dark). These are the exact swaymsg commands verified
# working 2026-06-26. Transform values here are sway ON-SCREEN values (no
# kanshi 90<->270 swap to worry about).
#
# Layout: vertical-left (flipped panel) | laptop-centre | horizontal-right
#   - DP-7 = portrait MSI, mounted 180°-flipped -> transform 270 = upright
#   - DP-8 = landscape MSI -> transform normal
#   - eDP-2 capped at 240Hz (300Hz blows the iGPU budget with two externals)
set -euo pipefail

swaymsg output DP-7  enable transform 270 scale 1 mode 2560x1440@60Hz  position 0 0
swaymsg output eDP-2 enable scale 1.3       mode 2560x1600@240Hz       position 1440 665
swaymsg output DP-8  enable transform normal scale 1 mode 2560x1440@60Hz position 3409 560

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
