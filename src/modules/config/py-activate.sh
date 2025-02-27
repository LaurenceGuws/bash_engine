#!/bin/bash

# Function to manage Python virtual environments in ~/.config/venv
activate() {
    VENV_DIR="${HOME}/.config/venv"
    DEFAULT_ENV_NAME="default"

    # Create the directory if it doesn't exist
    if [ ! -d "${VENV_DIR}" ]; then
        mkdir -p "${VENV_DIR}"
        echo "Created directory: ${VENV_DIR}"
    fi

    # Check if the user provided an argument (environment name)
    if [ "$1" ]; then
        ENV_NAME="$1"
    else
        ENV_NAME="${DEFAULT_ENV_NAME}"
    fi

    ENV_PATH="${VENV_DIR}/${ENV_NAME}"

    # If the virtual environment doesn't exist, create it
    if [ ! -d "${ENV_PATH}" ]; then
        echo "Creating virtual environment: ${ENV_NAME}..."
        python3 -m venv "${ENV_PATH}"
    fi

    # Activate the virtual environment
    if [ -f "${ENV_PATH}/bin/activate" ]; then
        echo "Activating virtual environment: ${ENV_NAME}"
        source "${ENV_PATH}/bin/activate"
    else
        echo "Error: Failed to activate ${ENV_NAME}. Virtual environment might be corrupted."
    fi
}

