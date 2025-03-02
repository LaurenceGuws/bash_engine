#!/bin/bash

1env() {
  while [[ -z "$OP_SERVICE_ACCOUNT_TOKEN" ]]; do
    # Prompt user for hidden input
    echo -n "Enter your OP_SERVICE_ACCOUNT_TOKEN: "
    read -s op_token # -s hides input as the user types
    echo

    # Validate the input
    if [[ -z "$op_token" ]]; then
      echo "Error: OP_SERVICE_ACCOUNT_TOKEN cannot be empty. Please try again." >&2
    else
      # Export the token for the current session
      export OP_SERVICE_ACCOUNT_TOKEN="$op_token"
      echo "OP_SERVICE_ACCOUNT_TOKEN has been set for this session."
    fi
  done

  # Call the main function once the token is set
  main
}

# Function to list all vaults and return the selected one
select_vault() {
    op vault ls | awk 'NR > 1 { print $2 }' | fzf --prompt="Select a vault: " --header="Available Vaults"
}

# Function to list all items in a selected vault and return the selected item ID
select_item() {
    local vault="$1"
    items=$(op item ls --vault "$vault")
    if [[ -z "$items" ]]; then
        echo "No items found in vault '$vault'." >&2
        return 1
    fi
    # Show titles for user selection
    selected_title=$(echo "$items" | awk 'NR > 1 { print $2 }' | fzf --prompt="Select an item: " --header="Items in vault: $vault")
    # Find the corresponding item ID
    echo "$items" | awk -v title="$selected_title" '$2 == title { print $1 }'
}

# Function to list all fields in a selected item and return the selected field's name
select_field() {
    local item_id="$1"
    local vault="$2"

    fields=$(op item get "$item_id" --vault "$vault" | awk '/Fields:/{flag=1; next} /^$/{flag=0} flag' | awk -F: '{print $1}' | sed 's/^[ \t]*//;s/[ \t]*$//')

    selected_field=$(echo "$fields" | fzf --prompt="Select a field: " --header="Fields in item ID: $item_id")

    if [[ -n "$selected_field" ]]; then
        echo "$selected_field"
    else
        echo "No field selected."
        return 1
    fi
}

# Function to reveal the selected field's value
reveal_field() {
    local item_id="$1"
    local vault="$2"
    local field="$3"

    # Reveal and return the field's value
    op item get "$item_id" --vault "$vault" --field "$field" --reveal
}

# Function to ask for an environment variable name and export it
export_env_var() {
    local field_value="$1"

    # Ask the user to specify the environment variable name
    echo -n "Enter the name of the environment variable: "
    read -r env_var_name

    # Check if the variable name is valid
    if [[ -z "$env_var_name" ]]; then
        echo "Environment variable name cannot be empty. Exiting." >&2
        return 1
    fi

    # Export the variable for the current session
    export "$env_var_name=$field_value"
    echo "Exported $env_var_name"
    echo "Run 'echo \$$env_var_name' to confirm."
}

# Main function to handle the flow
main() {
    selected_vault=$(select_vault)
    if [[ -z "$selected_vault" ]]; then
        echo "No vault selected. Exiting." >&2
        exit 1
    fi

    selected_item_id=$(select_item "$selected_vault")
    if [[ -z "$selected_item_id" ]]; then
        echo "No item selected. Exiting." >&2
        exit 1
    fi

    selected_field=$(select_field "$selected_item_id" "$selected_vault")
    if [[ -z "$selected_field" ]]; then
        echo "No field selected. Exiting." >&2
        exit 1
    fi

    revealed_value=$(reveal_field "$selected_item_id" "$selected_vault" "$selected_field")
    export_env_var "$revealed_value"
}

# Execute the main function
# 1env

