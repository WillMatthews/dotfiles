#!/usr/bin/env bash
# One-button caffeine control for waybar (an `image` module). Cycles 3 states:
#   off         -> moon.png   : normal — screen idles/locks, lid suspends
#   caffeine    -> coffee.png : screen kept awake (swayidle paused)
#   amphetamine -> pill.png   : screen awake AND lid-close won't suspend
# Left-click cycles off -> caffeine -> amphetamine -> off. Right-click forces off.
#
# Idle inhibition: there is no Wayland idle-inhibit CLI here, so we pause/resume
# swayidle with SIGSTOP/SIGCONT — a stopped swayidle never fires its lock/blank
# timeouts, and resuming restores it. Lid-close suspend is blocked by a transient
# handle-lid-switch inhibitor unit (logind ignores generic sleep/idle locks for
# the lid; only handle-lid-switch works). Both need no sudo.

DIR="$(dirname "$0")"
RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATEF="$RT/caffeine.state"
UNIT="caffeine-lid.service"     # holds the handle-lid-switch inhibitor
WAYBAR_SIGNAL=8                 # must match "signal" in the image#caffeine module

state() { cat "$STATEF" 2>/dev/null || echo off; }

idle_pause()  { pkill -STOP -x swayidle 2>/dev/null; }
idle_resume() { pkill -CONT -x swayidle 2>/dev/null; }

lid_lock_on() {
  systemctl --user is-active --quiet "$UNIT" && return
  systemd-run --user --unit="$UNIT" \
    --description="Amphetamine: keep awake with lid closed" \
    systemd-inhibit --what=handle-lid-switch \
      --who="Amphetamine" --why="lid closed but stay awake" --mode=block \
      sleep infinity >/dev/null 2>&1
}
lid_lock_off() {
  systemctl --user stop "$UNIT" 2>/dev/null
  systemctl --user reset-failed "$UNIT" 2>/dev/null
}

apply() {
  case "$1" in
    off)         idle_resume; lid_lock_off ;;
    caffeine)    idle_pause;  lid_lock_off ;;
    amphetamine) idle_pause;  lid_lock_on  ;;
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

refresh() { pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null; }

case "${1:-icon}" in
  cycle)
    case "$(state)" in
      off)      next=caffeine ;;
      caffeine) next=amphetamine ;;
      *)        next=off ;;
    esac
    echo "$next" > "$STATEF"; apply "$next"; notify "$next"; refresh
    ;;
  off)
    echo off > "$STATEF"; apply off; notify off; refresh
    ;;
  icon)
    case "$(state)" in
      caffeine)    echo "$DIR/coffee.png" ;;
      amphetamine) echo "$DIR/pill.png" ;;
      *)           echo "$DIR/moon.png" ;;
    esac
    ;;
esac
