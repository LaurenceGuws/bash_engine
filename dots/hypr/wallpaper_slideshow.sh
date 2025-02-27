#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
MONITOR="DP-1"  # Change this if your monitor name is different (`hyprctl monitors`)
DELAY=30  # Time in seconds between wallpaper changes (5 minutes)

# Preload all wallpapers before the loop starts
find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | while read -r img; do
    hyprctl hyprpaper preload "$img"
done

sleep 2  # Give Hyprpaper time to load images

while true; do
    find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | shuf | while read -r img; do
        hyprctl hyprpaper wallpaper "$MONITOR,$img"
        sleep $DELAY
    done
done
