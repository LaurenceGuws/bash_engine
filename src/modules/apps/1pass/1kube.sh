#!/usr/bin/env bash

1kube() {
  # Prompt for Service Account Token (hidden input)
  read -sp "Enter the 1Password Service Account Token: " SERVICE_ACCOUNT_TOKEN
  echo  # Add a newline after hidden input

  if [[ -z "$SERVICE_ACCOUNT_TOKEN" ]]; then
    echo "Error: Service Account Token cannot be empty."
    return 1
  fi
  export OP_SERVICE_ACCOUNT_TOKEN="$SERVICE_ACCOUNT_TOKEN"

  # Prompt for Vault and Document
  read -rp "Enter the 1Password Vault Name: " VAULT_NAME
  read -rp "Enter the 1Password Document Name: " DOC_NAME

  if [[ -z "$VAULT_NAME" || -z "$DOC_NAME" ]]; then
    echo "Error: Vault Name and Document Name cannot be empty."
    return 1
  fi

  # Generate a secure temporary file
  OUTPUT_FILE=$(mktemp "/tmp/${DOC_NAME}-plain.config.XXXXXX")
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create a temporary file."
    return 1
  fi

  # Fetch the document
  echo "Fetching '$DOC_NAME' from vault '$VAULT_NAME'..."
  if ! op document get "$DOC_NAME" --vault "$VAULT_NAME" -o "$OUTPUT_FILE" --force; then
    echo "Error: Failed to fetch document."
    [[ -f "$OUTPUT_FILE" ]] && rm -f "$OUTPUT_FILE"  # Remove file if it exists
    return 1
  fi

  echo "Document saved to: $OUTPUT_FILE"
  export KUBECONFIG="$OUTPUT_FILE"
  echo "Exported KUBECONFIG to session."

  # Unset sensitive environment variables only if they are set
  [[ -n "$OP_SERVICE_ACCOUNT_TOKEN" ]] && unset OP_SERVICE_ACCOUNT_TOKEN

  echo "Done."
}

