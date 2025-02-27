#!/usr/bin/bash

dots_interactive() {
  CONFIG_FILE="${PROFILE_DIR}/config/apps/dotfiles.yaml"
  APP_CONFIG_DIR="${PROFILE_DIR}/dots"
  SCRIPT_NAME=$(basename "$0")

  # Lighter pastel Catppuccin-inspired palette
  CTP_LAVENDER="\033[38;5;147m"   # Soft lavender for headers
  CTP_MINT="\033[38;5;121m"       # Mint green for success
  CTP_BUTTER="\033[38;5;228m"     # Butter yellow for prompts
  CTP_ROSE="\033[38;5;210m"       # Soft rose for warnings
  CTP_SKY="\033[38;5;153m"        # Light sky blue for information
  CTP_RESET="\033[0m"

  # Ensure dependencies are installed
  if ! command -v yq &> /dev/null; then
    echo -e "${CTP_ROSE}Error: 'yq' is required but not installed. Please install it first.${CTP_RESET}"
    return
  fi
  if ! command -v jq &> /dev/null; then
    echo -e "${CTP_ROSE}Error: 'jq' is required but not installed. Please install it first.${CTP_RESET}"
    return
  fi

  # Load mappings from the YAML file
  apps=$(yq eval '.applications | keys' "$CONFIG_FILE" -o=json | jq -r '.[]')

  # Prompt user for action
  echo -e "${CTP_SKY}Available applications to configure:${CTP_RESET}"
  echo -e "${CTP_LAVENDER}-----------------------------------${CTP_RESET}"
  echo "$apps" | nl -w 2 -s ". "

  echo -e "${CTP_BUTTER}Enter the number(s) of the application(s) to configure (comma-separated), or type 'all' to configure all:${CTP_RESET}"
  read -r user_choice

  # Determine which apps to process
  selected_apps=()
  if [[ "$user_choice" == "all" ]]; then
    selected_apps=($apps)
  else
    IFS=',' read -ra indices <<< "$user_choice"
    for index in "${indices[@]}"; do
      app=$(echo "$apps" | sed -n "${index}p")
      if [[ -n "$app" ]]; then
        selected_apps+=("$app")
      else
        echo -e "${CTP_ROSE}Warning: Invalid selection '$index'. Skipping.${CTP_RESET}"
      fi
    done
  fi

  # Remove duplicates (if any) from selected_apps
  selected_apps=($(echo "${selected_apps[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

  # Copy selected apps' configuration
  for app in "${selected_apps[@]}"; do
    source_path="${APP_CONFIG_DIR}/${app}/"
    target_path=$(yq eval ".applications.${app}" "$CONFIG_FILE" | envsubst)

    if [[ -d "$source_path" && -n "$target_path" ]]; then
      mkdir -p "$target_path" # Ensure the target directory exists
      cp -r "${source_path}"* "$target_path"
      echo -e "${CTP_MINT}Copied ${app} configuration to ${target_path}${CTP_RESET}"
    else
      echo -e "${CTP_ROSE}Warning: Missing source folder ($source_path) or target path ($target_path) for ${app}${CTP_RESET}"
    fi
  done
}

