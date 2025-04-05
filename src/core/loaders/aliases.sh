#!/bin/bash

# Function to parse YAML and set aliases using yq
set_aliases_from_yaml() {
  yaml_file="$PROFILE_DIR/config/aliases.yaml"  # Ensure this path is correct

  # Ensure the YAML file exists
  if [[ ! -f $yaml_file ]]; then
    return 1
  fi

  # Create a temporary script file to store alias commands
  tmp_script="$PROFILE_DIR/aliases_temp.sh"

  # Use yq to parse YAML and write alias commands to the temporary file
  yq e '. | to_entries | .[] | "alias \(.key)=\(.value | @sh)"' "$yaml_file" > "$tmp_script"

  # Source the temporary script to set aliases in the current shell
  source "$tmp_script"
  # cat "$tmp_script"
  # Clean up the temporary script
  rm "$tmp_script"
}

# Execute the function
set_aliases_from_yaml
