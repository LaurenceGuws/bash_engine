#!/bin/bash
# dependencies.sh
#
# Description:
# - This script checks if kubectl is installed and installs it if not.
# - It dynamically detects the system architecture to download the appropriate kubectl binary.
# - Ensures nala and wget are installed before attempting to download kubectl.

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

# Function to install wget using nala
install_wget() {
    echo "wget is not installed. Attempting to install wget."
    
    # Update package lists and install wget
    if ! WGET_INSTALL_OUTPUT=$(nala update && nala install -y wget 2>&1); then
        echo "Failed to install wget. Output: $WGET_INSTALL_OUTPUT"
        return 0
    fi
    
    echo "wget installed successfully."
}

# Function to install nala if not present (optional)
install_nala() {
    echo "nala is not installed. Attempting to install nala."
    
    # Update package lists and install nala
    if ! WGET_INSTALL_OUTPUT=$(sudo apt update && sudo apt install -y nala 2>&1); then
        echo "Failed to install nala. Output: $WGET_INSTALL_OUTPUT"
        return 0
    fi
    
    echo "nala installed successfully."
}

# Function to install kubectl
install_kubectl() {
    echo "Attempting to install kubectl."

    # Determine system architecture and OS
    ARCH=$(get_architecture)
    OS=$(get_os)

    # Check if architecture is supported
    if [ "$ARCH" == "unsupported" ]; then
        echo "Unsupported architecture: $(uname -m). Cannot install kubectl."
        return 0
    fi

    # Construct the kubectl download URL
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    KUBECTL_BINARY="kubectl_${KUBECTL_VERSION}_linux_${ARCH}"
    KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"

    echo "Downloading kubectl from $KUBECTL_URL"

    # Download kubectl
    if ! curl -LO "$KUBECTL_URL"; then
        echo "kubectl installation failed during download."
        return 0
    fi

    # Make kubectl executable
    chmod +x ./kubectl

    # Move kubectl to /usr/local/bin
    if ! sudo mv ./kubectl /usr/local/bin/kubectl; then
        echo "Failed to move kubectl to /usr/local/bin."
        return 0
    fi

    echo "kubectl installed successfully to /usr/local/bin/kubectl."
}

# Check if kubectl is installed
if ! command -v kubectl > /dev/null; then
    echo "kubectl is not installed. Attempting to install kubectl."

    # Check if nala is installed
    if ! command -v nala > /dev/null; then
        install_nala
    fi

    # Check if wget is installed
    if ! command -v wget > /dev/null; then
        install_wget
    fi

    # Install kubectl
    install_kubectl
else
    echo "kubectl is already installed."
fi
