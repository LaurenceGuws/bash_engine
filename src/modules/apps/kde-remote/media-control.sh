#!/bin/bash
# KDE Media Control Script with reliable notifications (Plasma 6)
# Usage: media-control.sh {play|pause|toggle|next|prev|stop|status}

ACTION="$1"
PLAYERCTL="/usr/bin/playerctl"
NOTIFY="/usr/bin/notify-send"
APPNAME="Media Control"

notify() {
  local icon="$1"
  local msg="$2"
  # Sends through org.freedesktop.Notifications (works in Plasma 6)
  $NOTIFY -i "$icon" -a "$APPNAME" "$msg"
}

if [[ -z "$ACTION" ]]; then
  echo "Usage: $0 {play|pause|toggle|next|prev|stop|status}"
  exit 1
fi

if ! command -v "$PLAYERCTL" &>/dev/null; then
  notify "dialog-error" "⚠️ playerctl not installed"
  echo "Error: playerctl not installed. Install with: sudo pacman -S playerctl"
  exit 1
fi

case "$ACTION" in
  play)
    "$PLAYERCTL" play
    notify "media-playback-start" "▶️ Playing"
    ;;
  pause)
    "$PLAYERCTL" pause
    notify "media-playback-pause" "⏸️ Paused"
    ;;
  toggle|play-pause)
    "$PLAYERCTL" play-pause
    STATE=$("$PLAYERCTL" status 2>/dev/null)
    if [[ "$STATE" == "Playing" ]]; then
      notify "media-playback-start" "▶️ Playing"
    else
      notify "media-playback-pause" "⏸️ Paused"
    fi
    ;;
  next)
    "$PLAYERCTL" next
    TITLE=$("$PLAYERCTL" metadata xesam:title 2>/dev/null)
    ARTIST=$("$PLAYERCTL" metadata xesam:artist 2>/dev/null)
    notify "media-skip-forward" "⏭️ Next: $ARTIST – $TITLE"
    ;;
  prev|previous)
    "$PLAYERCTL" previous
    TITLE=$("$PLAYERCTL" metadata xesam:title 2>/dev/null)
    ARTIST=$("$PLAYERCTL" metadata xesam:artist 2>/dev/null)
    notify "media-skip-backward" "⏮️ Previous: $ARTIST – $TITLE"
    ;;
  stop)
    "$PLAYERCTL" stop
    notify "media-playback-stop" "⏹️ Stopped"
    ;;
  status)
    STATE=$("$PLAYERCTL" status 2>/dev/null)
    TRACK=$("$PLAYERCTL" metadata xesam:title 2>/dev/null)
    ARTIST=$("$PLAYERCTL" metadata xesam:artist 2>/dev/null)
    notify "dialog-information" "🎶 $STATE: $ARTIST – $TRACK"
    ;;
  *)
    echo "Usage: $0 {play|pause|toggle|next|prev|stop|status}"
    exit 1
    ;;
esac

