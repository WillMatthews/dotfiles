#!/usr/bin/env bash
# GPU (NVIDIA) — two stacked text rows: utilisation % over VRAM used (GiB).
# Plain values (no bar); colour-ramped by load (>=70 warn, >=90 crit). Values
# are width-padded so the pill doesn't jitter. nvidia-smi is ~10ms so no cache.
FG="#EFE3CE"
_sev() { local p=$1; if (( p>=90 )); then echo critical; elif (( p>=70 )); then echo warning; else echo ok; fi; }
_col() { case "$(_sev "$1")" in critical) echo "#D26653";; warning) echo "#E9994A";; *) echo "#8FA672";; esac; }

raw="$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total \
  --format=csv,noheader,nounits 2>/dev/null)"
smi=$?
read -r util memused memtotal < <(printf '%s\n' "$raw" | tr -d ' ' | tr ',' ' ')

# When the dGPU is runtime-suspended (D3) or wedged, nvidia-smi exits non-zero
# and prints "No devices were found" — which must NOT leak into the pill. Show a
# dimmed idle marker instead. Guard on both exit status and a numeric util.
if (( smi != 0 )) || [[ ! $util =~ ^[0-9]+$ ]]; then
  dim="#6B6456"
  text="$(printf '<span size="8192" color="%s"> U <span color="%s">  --</span>\n V <span color="%s">  --G</span></span>' \
    "$dim" "$dim" "$dim")"
  jq -nc --arg t "$text" \
    --arg tip 'GPU (NVIDIA)  —  asleep / unavailable
  nvidia-smi could not query the dGPU (runtime-D3 or wedged).' \
    '{text:$t, tooltip:$tip, class:"ok"}'
  exit 0
fi

util=${util:-0}; memused=${memused:-0}; memtotal=${memtotal:-1}
(( memtotal == 0 )) && memtotal=1
vram=$(( memused * 100 / memtotal ))
gib=$(awk -v m="$memused"  'BEGIN{ printf "%4.1f", m/1024 }')
tgib=$(awk -v m="$memtotal" 'BEGIN{ printf "%.1f", m/1024 }')

if (( util >= vram )); then worst="$(_sev "$util")"; else worst="$(_sev "$vram")"; fi
ucol="$(_col "$util")"; vcol="$(_col "$vram")"

text="$(printf '<span size="8192" color="%s"> U <span color="%s">%3s%%</span>\n V <span color="%s">%sG</span></span>' \
  "$FG" "$ucol" "$util" "$vcol" "$gib")"

jq -nc --arg t "$text" \
  --arg tip "$(printf 'GPU (NVIDIA)\n  util   %s%%\n  VRAM   %sG / %sG  (%s%%)' "$util" "$gib" "$tgib" "$vram")" \
  --arg c "$worst" '{text:$t, tooltip:$tip, class:$c}'
