#!/usr/bin/env bash
# CPU — two stacked text rows: usage % over 1-min load average, matching the
# gpu/memory stacked style. Values are left plain (white); the pill itself ramps
# (.warning) / blinks (.critical) via style.css, preserving the built-in cpu
# module's behaviour it replaces. Usage is sampled from two /proc/stat reads.
FG="#EFE3CE"
ncpu=$(nproc 2>/dev/null || echo 1); (( ncpu < 1 )) && ncpu=1

snap() { set -- $(head -1 /proc/stat); shift; local idle=$(( $4 + $5 )) total=0 v
         for v in "$@"; do total=$(( total + v )); done; echo "$total $idle"; }
read t1 i1 < <(snap); sleep 0.2; read t2 i2 < <(snap)
dt=$(( t2 - t1 )); (( dt <= 0 )) && dt=1
usage=$(( (100 * (dt - (i2 - i1))) / dt ))
(( usage < 0 )) && usage=0; (( usage > 100 )) && usage=100

read -r load load5 load15 _ < /proc/loadavg
loadpct=$(awk -v l="$load" -v n="$ncpu" 'BEGIN{ printf "%d", (l/n)*100 }')

_sev()   { local p=$1; if (( p>=90 )); then echo critical; elif (( p>=70 )); then echo warning; else echo ok; fi; }
_order() { case "$1" in critical) echo 2;; warning) echo 1;; *) echo 0;; esac; }
su="$(_sev "$usage")"; sl="$(_sev "$loadpct")"
if (( $(_order "$su") >= $(_order "$sl") )); then worst="$su"; else worst="$sl"; fi

text="$(printf '<span size="8192" color="%s"> C %3s%%\n L %5s</span>' "$FG" "$usage" "$load")"

jq -nc --arg t "$text" \
  --arg tip "$(printf 'CPU\n  usage   %s%%\n  load    %s / %s / %s   (%s cores)' "$usage" "$load" "$load5" "$load15" "$ncpu")" \
  --arg c "$worst" '{text:$t, tooltip:$tip, class:$c}'
