#!/bin/bash

# Define the path to the YAML file
yaml_file="$PROFILE_DIR/config/path.yaml"

# Ensure the YAML file exists
if [[ ! -f $yaml_file ]]; then
  echo "YAML file not found: $yaml_file"
  exit 1
fi

# Use yq to extract values from the YAML file
values=$(yq e '.[]' "$yaml_file")

# Iterate over each value and append to PATH if not already present
for value in $values; do
  # Expand variables like ${HOME} or ${PROFILE_DIR}
  expanded_value=$(eval echo "$value")
  
  # Check if the expanded value is already in PATH
  if [[ ":$PATH:" != *":$expanded_value:"* ]]; then
    export PATH="$PATH:$expanded_value"
  fi
done

# Optionally verify by logging the updated PATH
# blog -l info "Updated PATH: $PATH" 
