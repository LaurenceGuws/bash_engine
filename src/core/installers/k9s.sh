#!/bin/bash
# dependencies.sh
#
# Description:
# - This script checks if k9s is installed and installs it if not.
# - It dynamically detects the system architecture to download the appropriate k9s binary.
# - Ensures nala and wget are installed before attempting to download k9s.

# Exit immediately if a command exits with a non-zero status
set -e

# Function to determine the system architecture
get_architecture() {
    arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "amd64"
            ;;
        aarch64 | arm64)
            echo "arm64"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Function to determine the operating system
get_os() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    echo "$os"
}

# Function to install nala
install_nala() {
    echo "nala is not installed. Attempting to install nala."

    # Update package lists and install nala
    if ! INSTALL_NALA_OUTPUT=$(apt update && apt install -y nala 2>&1); then
        echo "Failed to install nala. Output: $INSTALL_NALA_OUTPUT"
        return 0
    fi

    echo "nala installed successfully."
}

# Function to install wget
install_wget() {
    echo "wget is not installed. Attempting to install wget."

    # Update package lists and install wget
    if ! INSTALL_WGET_OUTPUT=$(nala update && nala install -y wget 2>&1); then
        echo "Failed to install wget. Output: $INSTALL_WGET_OUTPUT"
        return 0
    fi

    echo "wget installed successfully."
}

# Function to install k9s
install_k9s() {
    echo "Attempting to install k9s."

    # Determine system architecture and OS
    ARCH=$(get_architecture)
    OS=$(get_os)

    # Check if architecture is supported
    if [ "$ARCH" == "unsupported" ]; then
        echo "Unsupported architecture: $(uname -m). Cannot install k9s."
        return 0
    fi

    # Define k9s version
    K9S_VERSION="v0.32.7"

    # Construct the k9s download URL
    K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_${OS}_${ARCH}.deb"

    echo "Downloading k9s from $K9S_URL"

    # Download k9s .deb package
    if ! wget "$K9S_URL" -O k9s.deb; then
        echo "k9s installation failed during download."
        return 0
    fi

    # Install k9s using nala
    if ! INSTALL_K9S_OUTPUT=$(nala install ./k9s.deb --assume-yes 2>&1); then
        echo "k9s installation failed. Output: $INSTALL_K9S_OUTPUT"
        rm -f k9s.deb
        return 0
    fi

    # Remove the downloaded .deb file
    rm -f k9s.deb

    echo "k9s installed successfully."
}

# Check if k9s is installed
if ! command -v k9s > /dev/null; then
    echo "k9s is not installed. Attempting to install k9s."

    # Check if nala is installed
    if ! command -v nala > /dev/null; then
        install_nala
    fi

    # Check if wget is installed
    if ! command -v wget > /dev/null; then
        install_wget
    fi

    # Install k9s
    install_k9s
else
    echo "k9s is already installed."
fi
