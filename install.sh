#!/bin/bash

set -e

echo "Installing custom bash configuration files..."

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASHRC="${SCRIPT_DIR}/.bashrc"
BASHRC_CUSTOM="${SCRIPT_DIR}/.bashrc_custom"
backup_timestamp=$(date +"%Y%m%d_%H%M%S")

# Function to install bashrc for a specific user
install_for_user() {
    local user_home="$1"
    local user_type="$2"

    local target_bashrc="${user_home}/.bashrc"
    local target_bashrc_custom="${user_home}/.bashrc_custom"

    echo "Installing bash configuration for ${user_type} user..."

    # Create backups of existing files
    if [ -f "$target_bashrc" ]; then
        echo "Backing up existing ${user_type} .bashrc to ${target_bashrc}.backup_${backup_timestamp}"
        cp "$target_bashrc" "${target_bashrc}.backup_${backup_timestamp}"
    fi

    if [ -f "$target_bashrc_custom" ]; then
        echo "Backing up existing ${user_type} .bashrc_custom to ${target_bashrc_custom}.backup_${backup_timestamp}"
        cp "$target_bashrc_custom" "${target_bashrc_custom}.backup_${backup_timestamp}"
    fi

    # Copy files to home directory
    echo "Copying .bashrc to $target_bashrc"
    cp "$BASHRC" "$target_bashrc"

    # Only copy .bashrc_custom if it exists
    if [ -f "$BASHRC_CUSTOM" ]; then
        echo "Copying .bashrc_custom to $target_bashrc_custom"
        cp "$BASHRC_CUSTOM" "$target_bashrc_custom"

        # Set proper permissions for .bashrc_custom
        chmod 600 "$target_bashrc_custom" # More restrictive since it has sensitive information
    else
        echo "No .bashrc_custom found, skipping..."
    fi

    # Ensure .bashrc sources .bashrc_custom
    if ! grep -q "source.*\.bashrc_custom" "$target_bashrc"; then
        echo "Adding source line for .bashrc_custom to ${user_type}'s .bashrc"
        echo -e "\n# Source custom settings\n[ -f ~/.bashrc_custom ] && source ~/.bashrc_custom" >>"$target_bashrc"
    else
        echo "${user_type}'s .bashrc already includes .bashrc_custom"
    fi

    # Set proper permissions for .bashrc
    chmod 644 "$target_bashrc"
}

# Install for current user
install_for_user "$HOME" "current"

# Install for root user (if running with sudo)
if [ $EUID -eq 0 ]; then
    install_for_user "/root" "root"
else
    echo "To install for root user, run this script with sudo"
fi

echo "Installation complete!"
echo "Please run 'source ~/.bashrc' to apply changes to your current session"
