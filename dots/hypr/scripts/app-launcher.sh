#!/bin/bash
set -euo pipefail

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$UTILS_PATH"
fi

SCRIPT_PATH="$0"
if command -v realpath >/dev/null 2>&1; then
    SCRIPT_PATH="$(realpath "$SCRIPT_PATH")"
elif command -v readlink >/dev/null 2>&1; then
    SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi

# App Launcher - A floating kitty terminal popup with fzf for selection for desktop applications
# Scan all desktop applications in /usr/share/applications/ and /usr/local/share/applications/
# Parse the .desktop files and list the applications in a kitty terminal popup with fzf for selection

# Function to parse .desktop files and extract application information (optimized)
parse_desktop_files() {
    local app_dirs=(
        "/usr/share/applications"
        "/usr/local/share/applications"
        "$HOME/.local/share/applications"
    )
    
    # Use fd to get all desktop files at once (more efficient)
    local desktop_files=()
    for app_dir in "${app_dirs[@]}"; do
        if [[ -d "$app_dir" ]]; then
            mapfile -t -O ${#desktop_files[@]} desktop_files < <(fd -e desktop . "$app_dir" --max-depth 1 2>/dev/null)
        fi
    done
    
    # Process all files in parallel using xargs
    printf '%s\n' "${desktop_files[@]}" | xargs -I {} -P "$(nproc)" bash -c '
        desktop_file="$1"
        [[ "$(basename "$desktop_file")" =~ ^\. ]] && exit
        
        # Check if this is a valid application (not a directory or action)
        if ! rg -q "^Type=Application" "$desktop_file" 2>/dev/null && rg -q "^Type=" "$desktop_file" 2>/dev/null; then
            exit  # Skip non-application desktop files
        fi
        
        # Skip if NoDisplay or Hidden is true
        if rg -q "^NoDisplay=true" "$desktop_file" 2>/dev/null || rg -q "^Hidden=true" "$desktop_file" 2>/dev/null; then
            exit
        fi
        
        # Get all Name and Exec entries
        names=()
        execs=()
        comments=()
        icons=()
        
        # Extract all Name entries
        while IFS="=" read -r key value; do
            names+=("$value")
        done < <(rg "^Name=" "$desktop_file" 2>/dev/null)
        
        # Extract all Exec entries
        while IFS="=" read -r key value; do
            execs+=("$value")
        done < <(rg "^Exec=" "$desktop_file" 2>/dev/null)
        
        # Extract Comment (usually only one)
        comment=$(rg "^Comment=" "$desktop_file" 2>/dev/null | head -1 | cut -d= -f2-)
        
        # Extract Icon (usually only one)
        icon=$(rg "^Icon=" "$desktop_file" 2>/dev/null | head -1 | cut -d= -f2-)
        
        # Skip if no names or execs found
        [[ ${#names[@]} -eq 0 || ${#execs[@]} -eq 0 ]] && exit
        
        # Find icon path (optimized)
        icon_path=""
        if [[ -n "$icon" ]]; then
            # If icon is already a full path, use it
            if [[ -f "$icon" ]]; then
                icon_path="$icon"
            else
                # Use fd or find with limited depth for faster icon search
                icon_path=$(find /usr/share/icons/hicolor/48x48/apps /usr/share/icons/hicolor/32x32/apps /usr/share/pixmaps -maxdepth 1 -name "$icon.*" -type f 2>/dev/null | head -1)
                
                # Fallback to broader search only if needed
                if [[ -z "$icon_path" ]]; then
                    icon_path=$(find /usr/share/icons /usr/share/pixmaps -name "$icon.*" -type f 2>/dev/null | head -1)
                fi
            fi
        fi
        
        # Output each name-exec combination
        for i in "${!names[@]}"; do
            name="${names[$i]}"
            exec_cmd="${execs[$i]}"
            
            # Skip if name or exec is empty
            [[ -z "$name" || -z "$exec_cmd" ]] && continue
            
            # Clean up exec command
            exec_cmd=$(echo "$exec_cmd" | sed "s/%[UuFf]//g" | sed "s/^[[:space:]]*//" | sed "s/[[:space:]]*$//")
            
            # Output format: "Name|Exec|Comment|IconPath"
            echo "$name|$exec_cmd|$comment|$icon_path"
        done
    ' _ {}
}

# Function to launch the app launcher
launch_app_launcher() {
    echo "Starting launch_app_launcher function" >> /tmp/app_launcher_debug.log
    local cache_file="/tmp/app-launcher-cache-$$"
    local cache_age_limit=300  # 5 minutes
    
    # Generate or use cached data
    local app_data
    if [[ -f "$cache_file" && $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age_limit ]]; then
        app_data=$(cat "$cache_file")
    else
        # Generate fresh data and cache it
        app_data=$(parse_desktop_files | sort -u | tee "$cache_file")
    fi
    
    # Create a lookup file for selected apps
    local lookup_file="/tmp/app-launcher-lookup-$$"
    echo "$app_data" > "$lookup_file"
    
    # Show only names in fzf, but keep full data for lookup
    selected_name=$(echo "$app_data" | cut -d'|' -f1 | \
    fzf \
        --height=100% \
        --layout=reverse \
        --border \
        --prompt="󰀻 " \
        --header="Select an application to launch" \
        --preview="grep '^{}|' '$lookup_file' | head -1 | awk -F'|' '{print \"󰀻 Name: \" \$1; print \"󰍦 Description: \" \$3; print \"󰅴 Command: \" \$2; if (\$4 != \"\" && system(\"test -f \" \$4) == 0) system(\"kitty icat --clear --transfer-mode=memory --stdin=no --place=48x48@0x4 \" \$4); else print \"󰀦 No icon available\"}'" \
        --preview-window=right:70%:wrap \
        --bind="ctrl-c:abort" \
        --bind="esc:abort" \
        --bind="ctrl-r:reload(rm -f $cache_file; parse_desktop_files | sort -u | tee $cache_file | cut -d'|' -f1)")
    
    # Debug: Log the selected name
    echo "Selected name: '$selected_name'" >> /tmp/app_launcher_debug.log
    
    # If a name was selected, find the corresponding exec command
    if [[ -n "$selected_name" ]]; then
        exec_cmd=$(grep "^$selected_name|" "$lookup_file" | cut -d'|' -f2 | head -1)
        if [[ -n "$exec_cmd" ]]; then
            # Log the command for debugging
            echo "Launching: $exec_cmd" > /tmp/app_launcher_debug.log
            
            # Launch the application using hyprctl to ensure it's detached
            # This ensures it's completely detached from this process
            
            # Check if this is a terminal application that needs to run in a terminal
            if [[ "$exec_cmd" =~ ^(htop|btop|top|vim|nano|emacs|less|more|man|info|ssh|telnet|nc|netcat)$ ]]; then
                # Run terminal applications in kitty
                echo "Running terminal app: kitty -e $exec_cmd" >> /tmp/app_launcher_debug.log
                hyprctl dispatch exec "kitty -e $exec_cmd"
            else
                # Run GUI applications directly
                echo "Running GUI app: $exec_cmd" >> /tmp/app_launcher_debug.log
                hyprctl dispatch exec "$exec_cmd"
            fi
            
            # Log success
            echo "Launched app: $exec_cmd" >> /tmp/app_launcher_debug.log
        else
            echo "No exec command found for: $selected_name" >> /tmp/app_launcher_debug.log
        fi
    else
        echo "No app selected" >> /tmp/app_launcher_debug.log
    fi
    
    # Clean up temporary files
    rm -f "$lookup_file"
    
    # Clean up cache on exit
    trap "rm -f '$cache_file'" EXIT
}

main() {
    # Check if required tools are available (optimized)
    local missing_tools=()
    for tool in fzf kitty hyprctl rg; do
        command -v "$tool" &>/dev/null || missing_tools+=("$tool")
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "Error: Missing required tools: ${missing_tools[*]}" >&2
        echo "Install with: sudo pacman -S fzf kitty hyprland ripgrep" >&2
        exit 1
    fi
    
    # Launch the app launcher
    launch_app_launcher
}

run_app_launcher() {
    main "$@"
}

hypr_popup_run "APP_LAUNCHER_RUNNING" "app-launcher-popup" "App Launcher" \
    "kitty --class app-launcher-popup --title 'App Launcher' bash -lc 'APP_LAUNCHER_RUNNING=1 \"${SCRIPT_PATH}\"'" \
    run_app_launcher \
    br
