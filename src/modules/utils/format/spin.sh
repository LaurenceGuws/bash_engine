#!/bin/bash

spin() {
    local -a spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local stream_mode=false
    local OPTIND=1

    # Parse options
    while getopts "s" opt; do
        case ${opt} in
            s )
                stream_mode=true
                ;;
        esac
    done
    shift $((OPTIND -1))

    local message="$1"
    local temp_file=$(mktemp)
    local output_file=$(mktemp)
    
    # Set up streaming or buffered input handling
    if [ ! -t 0 ]; then
        if $stream_mode; then
            # Streaming mode: tee input to both files in background
            tee "$temp_file" > "$output_file" & 
        else
            # Buffered mode: just save to temp file
            cat > "$temp_file" &
        fi
        local cat_pid=$!
    fi

    # Hide cursor
    tput civis

    local i=0
    local last_size=0
    while [ -n "$cat_pid" ] && kill -0 "$cat_pid" 2>/dev/null; do
        if $stream_mode; then
            # In streaming mode, show new content immediately
            local current_size=$(wc -c < "$temp_file")
            if [ "$current_size" -gt "$last_size" ]; then
                tput el1
                printf "\n"
                tail -c $((current_size - last_size)) "$temp_file"
                printf "\r${spinner[$i]} %s" "$message"
                last_size=$current_size
            else
                printf "\r${spinner[$i]} %s" "$message"
            fi
        else
            printf "\r${spinner[$i]} %s" "$message"
        fi
        sleep 0.1
        i=$(( (i + 1) % ${#spinner[@]} ))
    done

    # Show cursor
    tput cnorm

    # Final output handling
    if [ -f "$temp_file" ]; then
        printf "\n"
        if ! $stream_mode; then
            # In buffered mode, show all content at the end
            cat "$temp_file"
        fi
        rm "$temp_file"
        [ -f "$output_file" ] && rm "$output_file"
    fi
}

# Example usage:
# Buffered mode (default): long_running_command | spin "Processing"
# Streaming mode: long_running_command | spin -s "Processing"
