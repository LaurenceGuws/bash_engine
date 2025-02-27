#!/bin/bash

# Path to the .env.yaml file
YAML_FILE="$PROFILE_DIR/config/env/env.yaml"

# Function to parse and export environment variables from the YAML file
export_env_variables() {
    # Check if the .env.yaml file exists
    if [ -f "$YAML_FILE" ]; then
        # Use awk to parse the YAML file and export each variable
        eval "$(
            awk -F': ' '
                /^[^#]/ && NF > 1 {
                    # Strip invalid characters from variable names
                    gsub(/[^a-zA-Z0-9_]/, "_", $1)
                    # Quote values to handle spaces and special characters
                    gsub(/"/, "", $2)
                    print "export " $1 "=\"" $2 "\""
                }
            ' "$YAML_FILE"
        )"

        # Check if --debug flag is provided
        if [ "$1" == "--debug" ]; then
            blog -l debug "Running in debug mode:"
            # Loop through and print each exported variable
            awk -F': ' '
                /^[^#]/ && NF > 1 {
                    gsub(/"/, "", $2)
                    gsub(/[^a-zA-Z0-9_]/, "_", $1)
                    print $1 "=" $2
                }
            ' "$YAML_FILE" | while read -r line; do
                blog -l debug "Set $line"
            done
        fi
    else
        blog -l error "$YAML_FILE not found."
    fi
}

# Call the function with the provided argument
export_env_variables "$1"

