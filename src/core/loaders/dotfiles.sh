#!/bin/bash
load_dots() {
  CONFIG_FILE="$PROFILE_DIR/config/apps/dotfiles.yaml"
  APP_CONFIG_DIR="$PROFILE_DIR/dots"
  SCRIPT_NAME=$(basename "$0")
  # Load mappings from the YAML file
  apps=$(yq eval '.applications | keys' "$CONFIG_FILE" -o=json | jq -r '.[]')

  # Copy each app's folder to its mapped path
  for app in $apps; do
    source_path="${APP_CONFIG_DIR}/${app}/"
    # Evaluate $HOME in the target path
    target_path=$(yq eval ".applications.${app}" "$CONFIG_FILE" | envsubst)

    if [[ -d "$source_path" && -n "$target_path" ]]; then
      mkdir -p "$target_path" # Ensure the target directory exists
      cp -r "${source_path}"* "$target_path"
      blog -l info "Copied $app configuration to $target_path" 
    else
      blog -l warn "Missing source folder ($source_path) or target path ($target_path) for $app" 
    fi
  done
}

