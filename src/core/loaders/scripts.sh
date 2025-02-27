#!/usr/bin/bash

# Load completion files
load_completions() {
    # Source all *_completion files in the home directory
    for file in ~/.config/bash_completion/*_completion; do
        [ -e "$file" ] && source "$file"
        blog -l info "Sourced: $file"
    done
}

# Load scripts from yaml configuration
load_scripts() {
    if [[ ! -f "$SCRIPTS" ]]; then
        blog -l error "scripts.yaml not found at $SCRIPTS"
        return 1
    fi

    # Read scripts from scripts.yaml using yq
    script_paths=$(yq e '.scripts[]' "$SCRIPTS" 2>/dev/null)

    # Check if yq command was successful
    if [[ $? -ne 0 ]]; then
        blog -l error "Failed to parse $SCRIPTS using yq."
        return 1
    fi

    # Source each script
    for script_path in $script_paths; do
        script_path=$(echo "$script_path" | tr -d '"')
        full_script_path="$PROFILE_DIR/$script_path"
        
        if [[ -f "$full_script_path" ]]; then
            source "$full_script_path"
            blog -l info "Sourced script: $full_script_path"
        else
            blog -l error "Script not found: $full_script_path"
        fi
    done
}

# Main profile loading function
load_profile() {
    load_scripts
    load_completions
    banner
} 