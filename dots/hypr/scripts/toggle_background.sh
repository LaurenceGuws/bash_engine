#!/usr/bin/env bash

# PID files
HYPRPAPER_PID_FILE="$HOME/.config/hypr/scripts/hyprpaper.pid"
LIVE_WALL_PID_FILE="$HOME/.config/hypr/scripts/livewall.pid"

# Path to hyprpaper slideshow
HYPRPAPER_CMD="hyprpaper --config $HOME/.config/hypr/scripts/slideshow.sh"

# Path to live wallpaper app (mpv example)
LIVE_WALL_CMD="glpaper -m $HOME/Videos/wallpaper.mp4"

# Check if live wallpaper is running
if [ -f "$LIVE_WALL_PID_FILE" ] && kill -0 $(cat "$LIVE_WALL_PID_FILE") 2>/dev/null; then
    # --- Toggle OFF live wallpaper, restore hyprpaper ---
    echo "Stopping live wallpaper..."
    kill $(cat "$LIVE_WALL_PID_FILE") 2>/dev/null
    rm -f "$LIVE_WALL_PID_FILE"

    echo "Starting hyprpaper..."
    $HYPRPAPER_CMD &
    echo $! > "$HYPRPAPER_PID_FILE"

else
    # --- Toggle ON live wallpaper ---
    echo "Stopping hyprpaper..."
    if [ -f "$HYPRPAPER_PID_FILE" ]; then
        kill $(cat "$HYPRPAPER_PID_FILE") 2>/dev/null
        rm -f "$HYPRPAPER_PID_FILE"
    fi

    echo "Starting live wallpaper..."
    $LIVE_WALL_CMD &
    echo $! > "$LIVE_WALL_PID_FILE"
fi

