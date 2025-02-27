#!/usr/bin/bash
source_competion(){
    # Source all *_completion files in the home directory
    for file in ~/.config/bash_completion/*_completion; do
        [ -e "$file" ] && source "$file"
        blog -l info "Sourced: $file" 
    done
}
source_scripts() {
    if [[ -f "$SCRIPTS" ]]; then

        # Read scripts from scripts.yaml using yq
        # Assumes that scripts.yaml has a list under the 'scripts' key
        script_paths=$(yq e '.scripts[]' "$SCRIPTS" 2>/dev/null)

        # Check if yq command was successful
        if [[ $? -ne 0 ]]; then
            blog -l error "Failed to parse $SCRIPTS using yq." 
            return 1
        fi

        for script_path in $script_paths; do
            # Remove any surrounding quotes from the script path
            script_path=$(echo "$script_path" | tr -d '"')
            full_script_path="$PROFILE_DIR/$script_path"
            if [[ -f "$full_script_path" ]]; then
                # script_name=$(basename "$full_script_path")  # Get only the filename
                source "$full_script_path"
                blog -l info "Sourced script: $full_script_path" 
            else
                blog -l error "Script not found: $full_script_path" 
            fi
        done
    else
        blog -l error "scripts.yaml not found at $SCRIPTS" 
    fi
}
