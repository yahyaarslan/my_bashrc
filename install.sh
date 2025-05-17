#!/bin/bash

set -e

echo "Installing custom bash configuration files..."

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASHRC="${SCRIPT_DIR}/.bashrc"
BASHRC_CUSTOM="${SCRIPT_DIR}/.bashrc_custom"
TARGET_BASHRC="${HOME}/.bashrc"
TARGET_BASHRC_CUSTOM="${HOME}/.bashrc_custom"

# Create backups of existing files
backup_timestamp=$(date +"%Y%m%d_%H%M%S")
if [ -f "$TARGET_BASHRC" ]; then
    echo "Backing up existing .bashrc to ${TARGET_BASHRC}.backup_${backup_timestamp}"
    cp "$TARGET_BASHRC" "${TARGET_BASHRC}.backup_${backup_timestamp}"
fi

if [ -f "$TARGET_BASHRC_CUSTOM" ]; then
    echo "Backing up existing .bashrc_custom to ${TARGET_BASHRC_CUSTOM}.backup_${backup_timestamp}"
    cp "$TARGET_BASHRC_CUSTOM" "${TARGET_BASHRC_CUSTOM}.backup_${backup_timestamp}"
fi

# Copy files to home directory
echo "Copying .bashrc to $TARGET_BASHRC"
cp "$BASHRC" "$TARGET_BASHRC"

# Only copy .bashrc_custom if it exists
if [ -f "$BASHRC_CUSTOM" ]; then
    echo "Copying .bashrc_custom to $TARGET_BASHRC_CUSTOM"
    cp "$BASHRC_CUSTOM" "$TARGET_BASHRC_CUSTOM"

    # Set proper permissions for .bashrc_custom
    chmod 600 "$TARGET_BASHRC_CUSTOM" # More restrictive since it has sensitive information
else
    echo "No .bashrc_custom found, skipping..."
fi

# Ensure .bashrc sources .bashrc_custom
if ! grep -q "source.*\.bashrc_custom" "$TARGET_BASHRC"; then
    echo "Adding source line for .bashrc_custom to .bashrc"
    echo -e "\n# Source custom settings\n[ -f ~/.bashrc_custom ] && source ~/.bashrc_custom" >>"$TARGET_BASHRC"
else
    echo ".bashrc already includes .bashrc_custom"
fi

# Set proper permissions for .bashrc
chmod 644 "$TARGET_BASHRC"

echo "Installation complete!"
echo "Please run 'source ~/.bashrc' to apply changes to your current session"
