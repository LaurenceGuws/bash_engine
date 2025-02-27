#!/usr/bin/env bash

# Function to display a progress bar
show_progress() {
    local progress=$1
    local total=$2
    local width=50  # Width of the progress bar

    # Calculate the number of filled positions
    local filled=$(( progress * width / total ))
    local empty=$(( width - filled ))

    # Create the bar strings
    local bar_filled=$(printf "%0.s#" $(seq 1 $filled))
    local bar_empty=$(printf "%0.s-" $(seq 1 $empty))

    # Calculate percentage
    local percent=$(( progress * 100 / total ))

    # Print the progress bar
    printf "\rProgress: [%s%s] %d%% (%d/%d)" "$bar_filled" "$bar_empty" "$percent" "$progress" "$total"
}

check_repos() {
    # Use the provided path argument or default to the current directory
    local base_dir="${1:-$(pwd)}"

    # Timeout duration in seconds for each git fetch
    local FETCH_TIMEOUT=10

    # Validate that the base directory exists
    if [[ ! -d "$base_dir" ]]; then
        blog -l error "The provided path '$base_dir' is not a valid directory." 
        return 1
    fi

    # Arrays to track various states
    up_to_date=()
    no_upstream=()
    needs_push=()
    not_git=()
    timed_out=()

    # Gather all directories in the base_dir
    directories=("$base_dir"/*/)
    total=${#directories[@]}
    current=0

    # Log the start of the sync check
    blog -l info "Starting sync check in '$base_dir'. Checking for Git repositories..." 

    # Initialize the progress bar
    show_progress 0 "$total"

    # Iterate through directories in the specified base directory
    for dir in "${directories[@]}"; do
        # Increment the current counter
        ((current++))

        if [ -d "$dir/.git" ]; then
            # Use timeout to limit the duration of git fetch
            if timeout "$FETCH_TIMEOUT" git -C "$dir" fetch &>/dev/null; then
                local LOCAL
                local REMOTE
                LOCAL=$(git -C "$dir" rev-parse @ 2>/dev/null)
                REMOTE=$(git -C "$dir" rev-parse @{u} 2>/dev/null || echo "no-upstream")

                if [ "$REMOTE" == "no-upstream" ]; then
                    no_upstream+=("$(basename "$dir")")
                elif [ "$LOCAL" != "$REMOTE" ]; then
                    needs_push+=("$(basename "$dir")")
                else
                    up_to_date+=("$(basename "$dir")")
                fi
            else
                # If git fetch times out or fails
                timed_out+=("$(basename "$dir")")
                blog -l warning "Timeout or error while fetching '$dir'." 
            fi
        else
            not_git+=("$(basename "$dir")")
        fi

        # Update the progress bar
        show_progress "$current" "$total"
    done

    # Move to the next line after completing the progress bar
    echo ""

    # Build the Sync Check Report
    report="Sync Check Report for '$base_dir':\n"
    report+="----------------------------------------\n\n"

    # Function to append sections to the report
    append_section() {
        local title="$1"
        shift
        local items=("$@")
        local count=${#items[@]}

        report+="$title: $count\n"
        if [ "$count" -gt 0 ]; then
            for dir in "${items[@]}"; do
                report+="  - $dir\n"
            done
        else
            report+="  - None\n"
        fi
        report+="\n"
    }

    # Append each category to the report
    append_section "Repositories up-to-date with remote" "${up_to_date[@]}"
    append_section "Repositories with no upstream set" "${no_upstream[@]}"
    append_section "Repositories needing push" "${needs_push[@]}"
    append_section "Directories not Git repositories" "${not_git[@]}"
    append_section "Repositories timed out" "${timed_out[@]}"

    # Log the consolidated report as a single log entry
    # Using printf to handle newlines correctly
    blog -l info "$(printf "%b" "$report")" 

    # Log the completion of the sync check
    blog -l info "Sync check complete. Summary logged above." 
}

# If this file is run directly, call the function with an optional path argument
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_repos "$@"
fi

