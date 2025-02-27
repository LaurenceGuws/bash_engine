#!/bin/bash

get_terminal_emulator_name() {
    # Get the Session ID (SID) of the current shell
    local sid
    sid=$(ps -o sid= -p $$)
    sid=$(echo "$sid" | tr -d ' ')  # Remove any whitespace

    # Get the Parent Process ID (PPID) of the Session Leader
    local session_leader_ppid
    session_leader_ppid=$(ps -o ppid= -p "$sid")
    session_leader_ppid=$(echo "$session_leader_ppid" | tr -d ' ')

    # Get the Command Name of the Parent Process (Terminal Emulator)
    local terminal_emulator
    terminal_emulator=$(ps -o comm= -p "$session_leader_ppid")
    terminal_emulator=$(echo "$terminal_emulator" | tr -d ' ')

    # Handle cases where the terminal emulator might be 'login' or 'sshd'
    if [[ "$terminal_emulator" == "login" ]] || [[ "$terminal_emulator" == "sshd" ]]; then
        # Try to get the grandparent process (for remote sessions)
        local grandparent_pid
        grandparent_pid=$(ps -o ppid= -p "$session_leader_ppid")
        grandparent_pid=$(echo "$grandparent_pid" | tr -d ' ')
        terminal_emulator=$(ps -o comm= -p "$grandparent_pid")
        terminal_emulator=$(echo "$terminal_emulator" | tr -d ' ')
    fi

    # Return the Terminal Emulator Name
    echo "$terminal_emulator"
}

display_random_image() {
    # Get the terminal emulator name
    local terminal_emulator
    terminal_emulator=$(get_terminal_emulator_name)

    # Set the image directory (modify this path as needed)
    local image_dir="${1:-$HOME/Pictures}"

    # Check if the directory exists
    if [ ! -d "$image_dir" ]; then
        echo "Error: Directory '$image_dir' does not exist."
        return 1
    fi

    # Find image files with supported extensions
    local images=()
    while IFS= read -r -d $'\0' file; do
        images+=("$file")
    done < <(find "$image_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)

    # Check if any images were found
    if [ "${#images[@]}" -eq 0 ]; then
        echo "Error: No images found in '$image_dir'."
        return 1
    fi

    # Select a random image
    local random_image="${images[RANDOM % ${#images[@]}]}"

    # Display the image based on the terminal emulator
    if [[ "$terminal_emulator" == "kitty" ]]; then
        # Use Kitty's icat
        if command -v kitty >/dev/null 2>&1; then
            kitty +kitten icat "$random_image"
        else
            echo "Error: 'kitty' command not found."
            return 1
        fi
    else
        # Use catimg
        if command -v catimg >/dev/null 2>&1; then
            catimg "$random_image"
        else
            echo "Error: 'catimg' command not found."
            return 1
        fi
    fi
}

# Uncomment the line below to run the function when the script is executed
# display_random_image "$1"
