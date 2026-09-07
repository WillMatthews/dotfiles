#!/usr/bin/env bash
# Tailscale VPN — a lock/shield icon coloured by backend state. Tooltip shows
# the state, this node's Tailscale IP, and any active exit node. Icon glyph is
# written as a bash \u escape (ASCII in this file) so the PUA char is never
# stored literally — see ~/Documents memory on PUA-glyph stripping.
ICON=$''   # lock (BMP) — VPN tunnel

json="$(tailscale status --json 2>/dev/null)"
state="$(printf '%s' "$json" | jq -r '.BackendState // "Stopped"' 2>/dev/null)"
ip="$(printf '%s' "$json"    | jq -r '.Self.TailscaleIPs[0] // "—"' 2>/dev/null)"
exitn="$(printf '%s' "$json" | jq -r '.ExitNodeStatus.TailscaleIPs[0] // empty' 2>/dev/null)"

case "$state" in
  Running) cls="connected" ;;
  Stopped) cls="disconnected" ;;
  *)       cls="warning" ;;
esac

tip="Tailscale: ${state}"$'\n'"IP: ${ip}"
[ -n "$exitn" ] && tip="${tip}"$'\n'"exit node: ${exitn}"

jq -nc --arg t "<span size='x-large'>${ICON}</span>" --arg tip "$tip" --arg c "$cls" \
  '{text:$t, tooltip:$tip, class:$c}'
