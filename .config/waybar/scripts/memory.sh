#!/usr/bin/env bash
# Memory pressure — two stacked text rows: RAM used % over swap used %. Plain
# values (no bar); colour-ramped (>=70 warn, >=90 crit). Replaces the built-in
# `memory` pill so swap (which runs hot on this 30GB box) stays visible.
FG="#EFE3CE"
_sev() { local p=$1; if (( p>=90 )); then echo critical; elif (( p>=70 )); then echo warning; else echo ok; fi; }
_col() { case "$(_sev "$1")" in critical) echo "#D26653";; warning) echo "#E9994A";; *) echo "#8FA672";; esac; }

mt=1; ma=0; st=0; sf=0
while read -r k v _; do
  case "$k" in
    MemTotal:)     mt=$v ;;
    MemAvailable:) ma=$v ;;
    SwapTotal:)    st=$v ;;
    SwapFree:)     sf=$v ;;
  esac
done < /proc/meminfo

(( mt == 0 )) && mt=1
ramp=$(( (mt - ma) * 100 / mt ))
if (( st > 0 )); then swp=$(( (st - sf) * 100 / st )); else swp=0; fi

ramu=$(awk -v x="$((mt-ma))" 'BEGIN{ printf "%.1f", x/1048576 }')
ramt=$(awk -v x="$mt"        'BEGIN{ printf "%.1f", x/1048576 }')
swpu=$(awk -v x="$((st-sf))" 'BEGIN{ printf "%.1f", x/1048576 }')
swpt=$(awk -v x="$st"        'BEGIN{ printf "%.1f", x/1048576 }')

if (( ramp >= swp )); then worst="$(_sev "$ramp")"; else worst="$(_sev "$swp")"; fi
rcol="$(_col "$ramp")"; scol="$(_col "$swp")"

text="$(printf '<span size="8192" color="%s"> M <span color="%s">%3s%%</span>\n S <span color="%s">%3s%%</span></span>' \
  "$FG" "$rcol" "$ramp" "$scol" "$swp")"

jq -nc --arg t "$text" \
  --arg tip "$(printf 'Memory\n  RAM    %sG / %sG  (%s%%)\n  swap   %sG / %sG  (%s%%)' \
       "$ramu" "$ramt" "$ramp" "$swpu" "$swpt" "$swp")" \
  --arg c "$worst" '{text:$t, tooltip:$tip, class:$c}'
