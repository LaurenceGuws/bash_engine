#!/bin/bash
#
# dependencies.sh
#
# Description:
# - This script ensures that all necessary dependencies are installed.
# - It verifies if the script is run as root and ensures that `yq` is installed before proceeding.
# - Reads the list of dependencies from `dependencies.yaml` and installs each missing dependency using their respective installer scripts.

# =============================
# Privilege Check
# =============================

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    # echo "This script must be run as root. Exiting."
    return 0
fi

# =============================
# Ensure yq is Installed
# =============================

# Ensure yq is installed before proceeding
echo "Ensuring yq is installed..."
"$PROFILE_DIR/init/installers/install_yq.sh"

# =============================
# Functions
# =============================

# Function to check and install each dependency
# Arguments:
#   $1 - Name of the dependency
check_and_install() {
    local name="$1"
    local current_user
    current_user=$(whoami)
    local installer

    # Determine the installer script based on the current user
    if [ "$current_user" = "root" ]; then
        installer="$PROFILE_DIR/init/installers/install_${name}.sh"
    else
        # Uncomment the following line if you want to use sudo for non-root users
        # installer="sudo $PROFILE_DIR/init/installers/install_${name}.sh"
        echo "Non-root user detected. Skipping installation for $name."
        return 0
    fi

    # Check if the dependency is already installed
    if ! command -v "$name" &> /dev/null; then
        echo "$name is not installed. Installing..."
        if [ -f "$installer" ]; then
            "$installer"  # Run the installer script
            echo "$name installation script executed."
        else
            echo "Installer script for $name not found at $installer."
        fi
    else
        echo "$name is already installed. Skipping."
    fi
}

# =============================
# Main Execution
# =============================

# Read dependencies.yaml and install each dependency if missing
echo "Reading dependencies from $PROFILE_DIR/config/dependencies.yaml..."
dependencies=$(yq e '.dependencies[]' "$PROFILE_DIR/config/dependencies.yaml")

# Loop through each dependency entry and check/install
echo "Processing dependencies..."
for name in $dependencies; do
    check_and_install "$name"
done

# =============================
# Cleanup (Optional)
# =============================

# If there are any cleanup steps, add them here
# Example:
# echo "Performing cleanup..."
# rm -f /path/to/temp/files

echo "All dependencies have been processed."
