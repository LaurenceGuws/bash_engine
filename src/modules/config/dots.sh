#!/bin/bash

# dots_interactive() {
#   CONFIG_FILE="${PROFILE_DIR}/config/dotfiles.yaml"
#   APP_CONFIG_DIR="${PROFILE_DIR}/dots"
#   SCRIPT_NAME=$(basename "$0")

#   # Lighter pastel Catppuccin-inspired palette
#   CTP_LAVENDER="\033[38;5;147m"   # Soft lavender for headers
#   CTP_MINT="\033[38;5;121m"       # Mint green for success
#   CTP_BUTTER="\033[38;5;228m"     # Butter yellow for prompts
#   CTP_ROSE="\033[38;5;210m"       # Soft rose for warnings
#   CTP_SKY="\033[38;5;153m"        # Light sky blue for information
#   CTP_RESET="\033[0m"

#   # Ensure dependencies are installed
#   if ! command -v yq &> /dev/null; then
#     echo -e "${CTP_ROSE}Error: 'yq' is required but not installed. Please install it first.${CTP_RESET}"
#     return
#   fi
#   if ! command -v jq &> /dev/null; then
#     echo -e "${CTP_ROSE}Error: 'jq' is required but not installed. Please install it first.${CTP_RESET}"
#     return
#   fi

#   # Load mappings from the YAML file
#   apps=$(yq eval '.applications | keys' "$CONFIG_FILE" -o=json | jq -r '.[]')

#   # Prompt user for action
#   echo -e "${CTP_SKY}Available applications to configure:${CTP_RESET}"
#   echo -e "${CTP_LAVENDER}-----------------------------------${CTP_RESET}"
#   echo "$apps" | nl -w 2 -s ". "

#   echo -e "${CTP_BUTTER}Enter the number(s) of the application(s) to configure (comma-separated), or type 'all' to configure all:${CTP_RESET}"
#   read -r user_choice

#   # Determine which apps to process
#   selected_apps=()
#   if [[ "$user_choice" == "all" ]]; then
#     selected_apps=($apps)
#   else
#     IFS=',' read -ra indices <<< "$user_choice"
#     for index in "${indices[@]}"; do
#       app=$(echo "$apps" | sed -n "${index}p")
#       if [[ -n "$app" ]]; then
#         selected_apps+=("$app")
#       else
#         echo -e "${CTP_ROSE}Warning: Invalid selection '$index'. Skipping.${CTP_RESET}"
#       fi
#     done
#   fi

#   # Remove duplicates (if any) from selected_apps
#   selected_apps=($(echo "${selected_apps[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

#   # Copy selected apps' configuration
#   for app in "${selected_apps[@]}"; do
#     source_path="${APP_CONFIG_DIR}/${app}/"
#     target_path=$(yq eval ".applications.${app}" "$CONFIG_FILE" | envsubst)

#     if [[ -d "$source_path" && -n "$target_path" ]]; then
#       mkdir -p "$target_path" # Ensure the target directory exists
#       cp -r "${source_path}"* "$target_path"
#       echo -e "${CTP_MINT}Copied ${app} configuration to ${target_path}${CTP_RESET}"
#     else
#       echo -e "${CTP_ROSE}Warning: Missing source folder ($source_path) or target path ($target_path) for ${app}${CTP_RESET}"
#     fi
#   done
# }

dots_fzf() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<'EOF'
Usage: dots_fzf [app1 app2 ...]
  With args: apply specified apps without fzf.
  Without args: open fzf to choose apps interactively.
Subcommands:
  --list                List configured apps and targets
  --get <app>           Show target path for app
  --add <app> <path>    Add or update an app entry
  --rm <app>            Remove an app entry
  --diff <app>          Show differences (repo dots vs target)
EOF
    return 0
  fi

  require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
      echo "Error: '$1' is required but not installed." >&2
      return 1
    fi
  }

  local preselected=("$@")
  CONFIG_FILE="${PROFILE_DIR}/config/dotfiles.yaml"
  APP_CONFIG_DIR="${PROFILE_DIR}/dots"

  # Lighter pastel Catppuccin-inspired palette (reuse from dots_interactive)
  CTP_LAVENDER="\033[38;5;147m"
  CTP_MINT="\033[38;5;121m"
  CTP_BUTTER="\033[38;5;228m"
  CTP_ROSE="\033[38;5;210m"
  CTP_SKY="\033[38;5;153m"
  CTP_RESET="\033[0m"

  # Ensure dependencies are installed
  for dep in yq jq fzf; do
    if ! command -v "$dep" &> /dev/null; then
      echo -e "${CTP_ROSE}Error: '$dep' is required but not installed. Please install it first.${CTP_RESET}"
      return
    fi
  done

  # Load applications list from the YAML config
  apps=$(yq eval '.applications | keys' "$CONFIG_FILE" -o=json | jq -r '.[]')

  if [[ -z "$apps" ]]; then
    echo -e "${CTP_ROSE}No applications found in configuration.${CTP_RESET}"
    return
  fi

  if [[ "${1:-}" == "--list" ]]; then
    require_cmd yq || return 1
    yq eval '.applications | to_entries[] | "\(.key)\t\(.value)"' "$CONFIG_FILE" | column -t -s $'\t'
    return 0
  elif [[ "${1:-}" == "--get" ]]; then
    require_cmd yq || return 1
    local app="${2:-}"
    if [[ -z "$app" ]]; then
      echo "Usage: dots_fzf --get <app>"
      return 1
    fi
    yq eval ".applications.\"${app}\"" "$CONFIG_FILE"
    return 0
  elif [[ "${1:-}" == "--add" ]]; then
    require_cmd yq || return 1
    local app="${2:-}"
    local path="${3:-}"
    if [[ -z "$app" || -z "$path" ]]; then
      echo "Usage: dots_fzf --add <app> <path>"
      return 1
    fi
    yq -i ".applications.\"${app}\" = \"${path}\"" "$CONFIG_FILE"
    echo "Added/updated ${app} -> ${path}"
    return 0
  elif [[ "${1:-}" == "--rm" ]]; then
    require_cmd yq || return 1
    local app="${2:-}"
    if [[ -z "$app" ]]; then
      echo "Usage: dots_fzf --rm <app>"
      return 1
    fi
    yq -i "del(.applications.\"${app}\")" "$CONFIG_FILE"
    echo "Removed ${app}"
    return 0
  elif [[ "${1:-}" == "--diff" ]]; then
    require_cmd yq || return 1
    local app="${2:-}"
    if [[ -z "$app" ]]; then
      echo "Usage: dots_fzf --diff <app>"
      return 1
    fi
    local source_path="${PROFILE_DIR}/dots/${app}/"
    local target_path
    target_path=$(yq eval ".applications.\"${app}\"" "$CONFIG_FILE" | envsubst)
    if [[ -z "$target_path" || "$target_path" == "null" ]]; then
      echo "No target configured for '${app}'"
      return 1
    fi
    if [[ ! -d "$source_path" ]]; then
      echo "Source path missing: $source_path"
      return 1
    fi
    if [[ ! -d "$target_path" ]]; then
      echo "Target path missing: $target_path"
      return 1
    fi
    # AI-friendly: show summary first, then unified diff with consistent paths
    echo "Source: $source_path"
    echo "Target: $target_path"
    echo "Summary (added/removed/changed):"
    diff -rq "$source_path" "$target_path" | sed 's/^/  /'
    echo
    echo "Unified diff:"
    diff -ruN "$source_path" "$target_path" || true
    return 0
  elif [[ ${#preselected[@]} -gt 0 ]]; then
    selected_apps=("${preselected[@]}")
  else
    # Use fzf for multi-select (instructions embedded in header to avoid lingering help text)
    mapfile -t selected_apps < <(echo "$apps" | \
      fzf --multi \
          --prompt="Applications > " \
          --header=$'Select applications to configure | <TAB> multi-select, <ENTER> confirm, <Ctrl-A> toggle all' \
          --border --ansi)
  fi

  if [[ ${#selected_apps[@]} -eq 0 ]]; then
    echo -e "${CTP_ROSE}No applications selected. Exiting.${CTP_RESET}"
    return
  fi

  # Copy selected apps' configuration
  for app in "${selected_apps[@]}"; do
    source_path="${APP_CONFIG_DIR}/${app}/"
    target_path=$(yq eval ".applications.${app}" "$CONFIG_FILE" | envsubst)

    if [[ -d "$source_path" && -n "$target_path" ]]; then
      mkdir -p "$target_path"
      # Enable dotglob to include hidden files, nullglob to handle empty directories
      shopt -s dotglob nullglob
      local files=("${source_path}"*)
      if [[ ${#files[@]} -gt 0 ]]; then
        cp -a "${files[@]}" "$target_path"
        echo -e "${CTP_MINT}Copied ${app} configuration to ${target_path}${CTP_RESET}"
      else
        echo -e "${CTP_BUTTER}No files found in ${source_path} for ${app}${CTP_RESET}"
      fi
      shopt -u dotglob nullglob
    else
      echo -e "${CTP_ROSE}Warning: Missing source folder ($source_path) or target path ($target_path) for ${app}${CTP_RESET}"
    fi
  done
}

# Bash completion for dots_fzf
_dots_fzf_complete() {
  local cur prev
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  local subs="--help --list --get --add --rm --diff"

  # Fast-exit if yq missing
  if ! command -v yq >/dev/null 2>&1; then
    COMPREPLY=($(compgen -W "$subs" -- "$cur"))
    return 0
  fi

  # Load app keys from dotfiles.yaml
  local config_file="${PROFILE_DIR}/config/dotfiles.yaml"
  local apps
  apps=$(yq eval '.applications | keys | .[]' "$config_file" 2>/dev/null | tr '\n' ' ')

  case "$prev" in
    --get|--rm|--diff)
      COMPREPLY=($(compgen -W "$apps" -- "$cur"))
      return 0
      ;;
    --add)
      # first arg after --add is app name
      if (( COMP_CWORD == 2 )); then
        COMPREPLY=($(compgen -W "$apps" -- "$cur"))
      fi
      return 0
      ;;
  esac

  if [[ "$cur" == -* ]]; then
    COMPREPLY=($(compgen -W "$subs" -- "$cur"))
  else
    COMPREPLY=($(compgen -W "$apps" -- "$cur"))
  fi
  return 0
}

complete -F _dots_fzf_complete dots_fzf
