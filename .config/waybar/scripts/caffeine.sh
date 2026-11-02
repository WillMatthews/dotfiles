#!/usr/bin/env bash
# One-button caffeine control for waybar (an `image` module). Cycles 3 states:
#   off         -> moon.png   : normal — screen idles/locks, lid suspends
#   caffeine    -> coffee.png : screen kept awake (logind idle inhibitor)
#   amphetamine -> pill.png   : screen awake AND lid-close won't suspend
# Left-click cycles off -> caffeine -> amphetamine -> off. Right-click forces off.
#
# swayidle observes logind's idle inhibitor and disables only its idle timers.
# It stays running to lock before suspend and restore external displays on wake.
# The separate handle-lid-switch inhibitor preserves the third button state.

DIR="$(dirname "$0")"
RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
IDLE_UNIT="caffeine-idle.service"
UNIT="caffeine-lid.service"     # holds the handle-lid-switch inhibitor
WAYBAR_SIGNAL=8                 # must match "signal" in the image#caffeine module

state() {
  if ! systemctl --user is-active --quiet "$IDLE_UNIT"; then
    echo off
  elif systemctl --user is-active --quiet "$UNIT"; then
    echo amphetamine
  else
    echo caffeine
  fi
}

# Type=notify reports success only AFTER systemd-inhibit acquired its lock.
# Failed acquisition times out rather than showing a misleading active icon.
inhibit_on() {
  local unit="$1" what="$2" why="$3"
  systemctl --user is-active --quiet "$unit" && return 0
  systemd-run --user --collect --unit="$unit" \
    --service-type=notify --property=NotifyAccess=all \
    --property=TimeoutStartSec=5 --description="$why" \
    sh -c 'exec systemd-inhibit "$@" env NOTIFY_SOCKET="$NOTIFY_SOCKET" sh -c "systemd-notify --ready && exec sleep infinity"' \
      sh --what="$what" --who=Caffeine --why="$why" --mode=block >/dev/null 2>&1
}
inhibit_off() {
  if systemctl --user is-active --quiet "$1"; then
    systemctl --user stop "$1"
  fi
}

lid_lock_on() {
  inhibit_on "$UNIT" handle-lid-switch "Keep awake with lid closed"
}
lid_lock_off() {
  inhibit_off "$UNIT"
}

apply() {
  case "$1" in
    off)         lid_lock_off && inhibit_off "$IDLE_UNIT" ;;
    caffeine)    inhibit_on "$IDLE_UNIT" idle "Keep screen awake" && lid_lock_off ;;
    amphetamine) inhibit_on "$IDLE_UNIT" idle "Keep screen awake" && lid_lock_on ;;
  esac
}

notify() {
  case "$1" in
    off)         notify-send -a caffeine -i weather-clear-night \
                   "Caffeine off" "Screen may sleep; lid suspends." ;;
    caffeine)    notify-send -a caffeine -i system-lock-screen \
                   "Caffeine on" "Screen stays awake." ;;
    amphetamine) notify-send -a caffeine -i computer \
                   "Amphetamine" "Awake even with the lid closed." ;;
  esac
}

refresh() { pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null || true; }

change() {
  if ! apply "$1"; then
    notify-send -a caffeine "Caffeine change failed" "Current state: $(state)" >&2
    refresh
    return 1
  fi
  notify "$1"
  refresh
}

# Serialize clicks from different monitor bars; state is read from live units.
if [[ ${1:-icon} != icon ]]; then
  exec 9>"$RT/caffeine.lock"
  flock -x 9
fi

case "${1:-icon}" in
  cycle)
    case "$(state)" in
      off)      next=caffeine ;;
      caffeine) next=amphetamine ;;
      *)        next=off ;;
    esac
    change "$next"
    ;;
  off)
    change off
    ;;
  icon)
    case "$(state)" in
      caffeine)    echo "$DIR/coffee.png" ;;
      amphetamine) echo "$DIR/pill.png" ;;
      *)           echo "$DIR/moon.png" ;;
    esac
    ;;
esac
