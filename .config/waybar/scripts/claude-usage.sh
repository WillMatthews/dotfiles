#!/usr/bin/env bash
# Claude usage box for waybar.
#
# Data source: ccusage (https://github.com/ryoppippi/ccusage), which parses the
# local Claude Code transcripts under ~/.claude/projects. ONE `ccusage blocks`
# call gives us both:
#   * the current 5h billing "session" (the active block), and
#   * a rolling-7-day "week" (sum of recent non-gap blocks).
#
# IMPORTANT: ccusage knows cost & tokens, but NOT your plan's real ceiling
# (the official /usage percentages need an authenticated Anthropic API call).
# So the bars are driven off cost against the ESTIMATED Max 20x caps below.
# These are rough — tune them to taste once you've watched real usage.
#
# RENDERING: a waybar module is a single Pango-markup label — we can't draw
# real graphics, but we fake two horizontal bars by painting runs of spaces
# with a background colour (filled) vs a track colour (empty), stacked on two
# lines with a "\n". No icon glyph — the "S"/"W" row labels identify it,
# which also sidesteps the editor's habit of stripping Private-Use-Area bytes.
SESSION_LIMIT_USD=150      # approx cost ceiling for one 5h session block
WEEKLY_LIMIT_USD=1500      # approx cost ceiling for a rolling 7-day window
BAR_WIDTH=12               # bar length in character cells

export PATH="$HOME/.local/bin:$PATH"

JSON="$(npx --yes ccusage blocks --json --offline 2>/dev/null)"
if [ -z "$JSON" ]; then
  jq -nc '{text:"<span size=\"8192\" color=\"#A89880\"> ccusage n/a</span>", tooltip:"ccusage unavailable", class:"idle"}'
  exit 0
fi

now="$(date +%s)"

printf '%s' "$JSON" | jq -c \
  --argjson now "$now" \
  --argjson slim "$SESSION_LIMIT_USD" \
  --argjson wlim "$WEEKLY_LIMIT_USD" \
  --argjson w "$BAR_WIDTH" '

  def clamp(r): if r < 0 then 0 elif r > 1 then 1 else r end;
  def rep(n): (if n <= 0 then "" else ([range(0;n)] | map(" ") | join("")) end);
  def fillcol(r): if r >= 0.9 then "#D26653" elif r >= 0.7 then "#E9994A" else "#8FA672" end;
  # one horizontal bar: filled run + track run, both coloured spaces
  def hbar(r):
      (clamp(r) * $w | round) as $f
      | "<span bgcolor=\"\(fillcol(r))\" color=\"\(fillcol(r))\">\(rep($f))</span>"
      + "<span bgcolor=\"#4E3F32\" color=\"#4E3F32\">\(rep($w - $f))</span>";
  def money: (. * 100 | round) / 100;
  def hum:
      if   . >= 1000000000 then ((. / 100000000 | round) / 10 | tostring) + "B"
      elif . >= 1000000    then ((. / 100000    | round) / 10 | tostring) + "M"
      elif . >= 1000       then ((. / 1000       | round)      | tostring) + "k"
      else (. | floor | tostring) end;
  def ep(t): (t | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601);

  # --- session = active block (nullable) ---
  ([.blocks[] | select(.isActive == true)][0] // null) as $a
  # --- week = non-gap blocks started within the last 7 days ---
  | [.blocks[] | select((.isGap | not) and (ep(.startTime) >= ($now - 604800)))] as $wk

  | ($a.costUSD // 0)      as $scost
  | ($a.totalTokens // 0)  as $stok
  | (($wk | map(.costUSD)     | add) // 0) as $wcost
  | (($wk | map(.totalTokens) | add) // 0) as $wtok
  | (if $a then (((ep($a.endTime) - $now) / 60) | floor) else 0 end) as $rawleft
  | (if $rawleft < 0 then 0 else $rawleft end) as $minleft

  | ($scost / $slim) as $sr
  | ($wcost / $wlim) as $wr
  | ([$sr, $wr] | max) as $sev

  | (($minleft / 60) | floor) as $hh
  | ($minleft % 60)           as $mm
  | (if $a then "\($hh)h\($mm)m" else "idle" end) as $tleft

  | (if $sev >= 0.9 then "critical" elif $sev >= 0.7 then "warning" else "ok" end) as $cls

  # two stacked bars; mono font keeps the "S"/"W" labels and bars aligned.
  # " S " and " W " are both 3 cells wide, so both bars start at the same column.
  | ("<span size=\"8192\" color=\"#EFE3CE\">"
      + " S " + hbar($sr) + " \($sr * 100 | floor)%  \($tleft)\n"
      + " W " + hbar($wr) + " \($wr * 100 | floor)%"
      + "</span>") as $text

  | ("<b>Claude usage</b>  <i>(ccusage · est. Max 20x caps)</i>\n"
      + "\n"
      + "<b>Session</b>  (current 5h block)\n"
      + "  cost    $\($scost|money) / $\($slim)   (\($sr*100|floor)%)\n"
      + "  tokens  \($stok|hum)\n"
      + (if $a then
            "  resets  in \($tleft)\n"
          + "  burn    $\(($a.burnRate.costPerHour // 0)|money)/h → proj $\(($a.projection.totalCost // 0)|money)\n"
        else "  (no active session)\n" end)
      + "\n"
      + "<b>Week</b>  (rolling 7 days)\n"
      + "  cost    $\($wcost|money) / $\($wlim)   (\($wr*100|floor)%)\n"
      + "  tokens  \($wtok|hum)"
    ) as $tip

  | {text: $text, tooltip: $tip, class: $cls, percentage: ($sr * 100 | floor)}
'
