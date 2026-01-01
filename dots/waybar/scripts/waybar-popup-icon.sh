#!/usr/bin/env bash

set -euo pipefail

popup_open=false
if hyprctl clients -j 2>/dev/null \
  | jq -e '.[] | select(.class=="waybar-popup" and .title=="Waybar Popup")' >/dev/null; then
  popup_open=true
fi

if $popup_open; then
  printf '{"text":"","class":"popup-open"}\n'
else
  printf '{"text":"<","class":"popup-closed"}\n'
fi
