#!/usr/bin/env bash
# Claude usage box for waybar.
#
# Data source: the SAME endpoint Claude Code's `/usage` view uses —
#   GET https://api.anthropic.com/api/oauth/usage
# authenticated with the OAuth access token Claude Code stores in
# ~/.claude/.credentials.json (key: claudeAiOauth.accessToken). This returns
# your plan's REAL utilisation percentages, not an estimate:
#   .five_hour.utilization   -> current 5h "session" %   (+ .resets_at)
#   .seven_day.utilization   -> rolling 7-day "all models" %
#   .seven_day_opus / _sonnet.utilization -> per-model 7-day % (nullable)
#
# This replaces the old ccusage approach, which divided ESTIMATED cost by
# guessed caps and so never matched the official numbers. (Old version saved
# as claude-usage.sh.ccusage.bak.)
#
# Claude Code keeps the access token fresh whenever you use it; this script
# only reads the file, never refreshes. If the token is missing/expired we
# fall back to the last good reading (cached in $CACHE), then to an "auth"
# placeholder.
#
# RENDERING: a waybar module is a single Pango-markup label — we fake two
# horizontal bars by painting runs of spaces with a background colour (filled)
# vs a track colour (empty), stacked on two lines. The "S"/"W" row labels
# identify it (no PUA glyphs, which the editor strips).
BAR_WIDTH=12               # bar length in character cells
CREDS="$HOME/.claude/.credentials.json"
CACHE="/tmp/waybar-claude-usage.cache.json"

now="$(date +%s)"

render() {
  # $1 = raw usage JSON from the API (or cache)
  printf '%s' "$1" | jq -c \
    --argjson now "$now" \
    --argjson w "$BAR_WIDTH" '

    def clamp(r): if r < 0 then 0 elif r > 1 then 1 else r end;
    def rep(n): (if n <= 0 then "" else ([range(0;n)] | map(" ") | join("")) end);
    def fillcol(r): if r >= 0.9 then "#D26653" elif r >= 0.7 then "#E9994A" else "#8FA672" end;
    def hbar(r):
        (clamp(r) * $w | round) as $f
        | "<span bgcolor=\"\(fillcol(r))\" color=\"\(fillcol(r))\">\(rep($f))</span>"
        + "<span bgcolor=\"#4E3F32\" color=\"#4E3F32\">\(rep($w - $f))</span>";
    # ISO8601 (UTC, microseconds) -> epoch seconds
    def ep(t): (t | sub("\\.[0-9]+";"") | sub("\\+00:00$";"Z") | fromdateiso8601);
    def hm(mins):
        (if mins < 0 then 0 else mins end) as $m
        | "\(($m / 60) | floor)h\($m % 60)m";

    (.five_hour.utilization // 0) as $su
    | (.seven_day.utilization // 0) as $wu
    | ($su / 100) as $sr
    | ($wu / 100) as $wr
    | ([$sr, $wr] | max) as $sev

    | (.five_hour.resets_at  // null) as $srt
    | (.seven_day.resets_at  // null) as $wrt
    | (if $srt then (((ep($srt) - $now) / 60) | floor) else null end) as $smin
    | (if $smin == null then "idle" else hm($smin) end) as $tleft

    | (if $sev >= 0.9 then "critical" elif $sev >= 0.7 then "warning" else "ok" end) as $cls

    | ("<span size=\"8192\" color=\"#EFE3CE\">"
        + " S " + hbar($sr) + " \($su|floor)%  \($tleft)\n"
        + " W " + hbar($wr) + " \($wu|floor)%"
        + "</span>") as $text

    | ("<b>Claude usage</b>  <i>(live · /usage endpoint)</i>\n"
        + "\n"
        + "<b>Session</b>  (current 5h block)\n"
        + "  used    \($su|floor)%\n"
        + (if $srt then "  resets  in \($tleft)  (\((ep($srt))|strflocaltime("%a %H:%M")))\n" else "" end)
        + "\n"
        + "<b>Week</b>  (rolling 7 days, all models)\n"
        + "  used    \($wu|floor)%\n"
        + (if $wrt then "  resets  \((ep($wrt))|strflocaltime("%a %H:%M"))\n" else "" end)
        + ([ (.seven_day_opus.utilization   | select(. != null) | "  opus    \(.|floor)%"),
             (.seven_day_sonnet.utilization | select(. != null) | "  sonnet  \(.|floor)%") ]
           | if length > 0 then "\n" + join("\n") else "" end)
        + (if (.extra_usage.is_enabled // false) and (.extra_usage.utilization != null)
           then "\n\n<b>Extra usage</b>  \(.extra_usage.utilization|floor)%" else "" end)
      ) as $tip

    | {text: $text, tooltip: $tip, class: $cls, percentage: ($su | floor)}
  '
}

placeholder() {  # $1 = message, $2 = class
  jq -nc --arg m "$1" --arg c "$2" \
    '{text:"<span size=\"8192\" color=\"#A89880\"> \($m)</span>", tooltip:$m, class:$c}'
}

TOKEN="$(jq -r '.claudeAiOauth.accessToken // empty' "$CREDS" 2>/dev/null)"
if [ -z "$TOKEN" ]; then
  if [ -s "$CACHE" ]; then render "$(cat "$CACHE")"; else placeholder "no token" "idle"; fi
  exit 0
fi

JSON="$(curl -sS --max-time 8 \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" \
  "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)"

# Valid responses always carry .five_hour; anything else (401, network blip,
# error body) falls back to the last good reading so the bar doesn't flicker.
if printf '%s' "$JSON" | jq -e '.five_hour' >/dev/null 2>&1; then
  printf '%s' "$JSON" > "$CACHE"
  render "$JSON"
elif [ -s "$CACHE" ]; then
  render "$(cat "$CACHE")"
else
  placeholder "usage n/a" "idle"
fi
