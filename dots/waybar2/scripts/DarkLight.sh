#!/bin/bash

# Simple script to toggle between light and dark themes

# Configuration
THEME_STATE_FILE="/tmp/theme_state"
LIGHT_GTK_THEME="Adwaita"  # Replace with your light theme
DARK_GTK_THEME="Adwaita-dark"  # Replace with your dark theme
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"

# Function to get current theme state
get_theme_state() {
    # If the file doesn't exist, create it with default theme
    if [ ! -f "$THEME_STATE_FILE" ]; then
        echo "dark" > "$THEME_STATE_FILE"
    fi
    
    cat "$THEME_STATE_FILE"
}

# Function to set GTK theme
set_gtk_theme() {
    theme="$1"
    
    # Set GTK theme using gsettings
    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.interface gtk-theme "$theme"
    fi
    
    # Set theme using Xsettingsd if available
    if command -v xsettingsd >/dev/null 2>&1; then
        echo "Net/ThemeName \"$theme\"" > "$HOME/.xsettingsd"
        pkill -HUP xsettingsd || xsettingsd &
    fi
}

# Function to toggle between light and dark themes
toggle_theme() {
    current=$(get_theme_state)
    
    if [ "$current" = "dark" ]; then
        # Switch to light theme
        set_gtk_theme "$LIGHT_GTK_THEME"
        
        # Update state file
        echo "light" > "$THEME_STATE_FILE"
        
        # Notify user
        notify-send "Theme" "Switched to light theme"
        
        # Optional: Restart Waybar with light theme
        if [ -d "$WAYBAR_CONFIG_DIR" ]; then
            pkill waybar
            waybar &
        fi
    else
        # Switch to dark theme
        set_gtk_theme "$DARK_GTK_THEME"
        
        # Update state file
        echo "dark" > "$THEME_STATE_FILE"
        
        # Notify user
        notify-send "Theme" "Switched to dark theme"
        
        # Optional: Restart Waybar with dark theme
        if [ -d "$WAYBAR_CONFIG_DIR" ]; then
            pkill waybar
            waybar &
        fi
    fi
}

# Main
toggle_theme

exit 0 