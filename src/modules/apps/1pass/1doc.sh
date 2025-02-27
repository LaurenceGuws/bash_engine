#!/usr/bin/env bash

1doc() {
  while [[ -z "$OP_SERVICE_ACCOUNT_TOKEN" ]]; do
    # Prompt user for hidden input
    echo -n "Enter your 1Password Service Account Token: "
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

  # Function to list all vaults and return the selected one
  select_vault() {
      local vault
      vault=$(op vault ls | awk 'NR > 1 { print $2 }' | fzf --prompt="Select a vault: " --header="Available Vaults")
      echo "$vault"
  }

  # Function to list all documents in a selected vault and return the selected document name
  select_document() {
      local vault="$1"
      local documents
      documents=$(op document ls --vault "$vault" | awk 'NR > 1 { print $2 }')
      if [[ -z "$documents" ]]; then
          echo "No documents found in vault '$vault'." >&2
          return 1
      fi
      local document
      document=$(echo "$documents" | fzf --prompt="Select a document: " --header="Available Documents in Vault: $vault")
      echo "$document"
  }

  # Function to fetch the selected document and save it to a temporary file
  fetch_document() {
      local vault="$1"
      local document="$2"

      # Generate a secure temporary file
      local output_file
      output_file=$(mktemp "/tmp/${document}-plain.config.XXXXXX")
      if [[ $? -ne 0 ]]; then
          echo "Error: Failed to create a temporary file." >&2
          return 1
      fi

      # Fetch the document using `op` and save it to the temporary file
      if ! op document get "$document" --vault "$vault" -o "$output_file" --force; then
          echo "Error: Failed to fetch document." >&2
          [[ -f "$output_file" ]] && rm -f "$output_file"
          return 1
      fi

      echo "$output_file"
  }

  # Main function to handle the flow
  main() {
      # Step 1: Select a vault
      selected_vault=$(select_vault)
      if [[ -z "$selected_vault" ]]; then
          echo "No vault selected. Returning." >&2
          return 1
      fi

      # Step 2: Select a document
      selected_document=$(select_document "$selected_vault")
      if [[ -z "$selected_document" ]]; then
          echo "No document selected. Returning." >&2
          return 1
      fi

      # Step 3: Fetch the document
      output_file=$(fetch_document "$selected_vault" "$selected_document")
      if [[ -z "$output_file" ]]; then
          echo "Failed to fetch document. Returning." >&2
          return 1
      fi

      echo "Document saved to:"$output_file""

      # Clear sensitive environment variables
      unset OP_SERVICE_ACCOUNT_TOKEN
  }

  # Execute the main function
  main
}

