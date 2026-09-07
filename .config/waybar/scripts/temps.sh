#!/usr/bin/env bash
# Temperatures — two stacked text rows: CPU package °C over GPU °C. Plain values
# (no bar chart); each value is colour-ramped (>=70 warn, >=90 crit) so a hot
# reading stands out while idle temps stay calm. Width-padded to 3 cells so the
# pill doesn't jitter as a value crosses 2->3 digits.
FG="#EFE3CE"

_sev() { local p=$1; if (( p>=90 )); then echo critical; elif (( p>=70 )); then echo warning; else echo ok; fi; }
_col() { case "$(_sev "$1")" in critical) echo "#D26653";; warning) echo "#E9994A";; *) echo "#8FA672";; esac; }

cpu="$(sensors -j 2>/dev/null \
  | jq -r '."coretemp-isa-0000"."Package id 0" | to_entries[] | select(.key|endswith("_input")) | .value' \
  | head -1)"
cpu=${cpu%.*}; cpu=${cpu:-0}

gpu="$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')"
gpu=${gpu:-0}

if (( cpu >= gpu )); then worst="$(_sev "$cpu")"; else worst="$(_sev "$gpu")"; fi
ccol="$(_col "$cpu")"; gcol="$(_col "$gpu")"

text="$(printf '<span size="8192" color="%s"> C <span color="%s">%3s°</span>\n G <span color="%s">%3s°</span></span>' \
  "$FG" "$ccol" "$cpu" "$gcol" "$gpu")"

jq -nc --arg t "$text" \
  --arg tip "$(printf 'Temperatures\n  CPU pkg   %s°C\n  GPU       %s°C' "$cpu" "$gpu")" \
  --arg c "$worst" '{text:$t, tooltip:$tip, class:$c}'
