#!/bin/bash

function set_wallpapers() {
  # Kill hyprpaper and clear the config
  hyprctl hyprpaper unload all 2>/dev/null
  killall hyprpaper 2>/dev/null
  sleep 1
  
  # Initialize hyprpaper config
  echo "splash = false" >~/.config/hypr/hyprpaper.conf
  echo "ipc = true" >>~/.config/hypr/hyprpaper.conf

  # Get all monitor names
  monitors=$(hyprctl monitors -j | jq -r ".[] | .name")

  # Assign random wallpaper to each monitor
  for monitor in $monitors; do
    wallpaper=$(fd -e png -e jpg -e jpeg -e webp . ~/Pictures/wallpapers/ | shuf -n1)
    echo "preload = $wallpaper" >>~/.config/hypr/hyprpaper.conf
    echo "wallpaper = $monitor,$wallpaper" >>~/.config/hypr/hyprpaper.conf
  done

  # Restart hyprpaper
  hyprpaper &
  sleep 1
}

# The main loop instead of recursion
function slideshow() {
  # Initial wallpaper setup
  set_wallpapers
  
  # Loop instead of recursion
  while true; do
    # Wait and refresh wallpapers every 10 minutes
    sleep 10m
    set_wallpapers
  done
}

# If we're already running, don't start again
pgrep -f "bash $0" | grep -v $$ > /dev/null
if [ $? -eq 0 ]; then
  echo "Slideshow is already running"
  exit 0
fi

# Run the slideshow function in the background
slideshow &

# Detach from the terminal
disown
