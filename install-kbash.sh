#!/bin/bash
# One-click installer for kbash.sh

set -e

# Variables
REPO_RAW_BASE="https://raw.githubusercontent.com/kainatquaderee/kbash/main"
KBASH_FILE="$HOME/.kbash.sh"
BASHRC="$HOME/.bashrc"

echo "Installing kbash.sh..."

# Download .kbash.sh
curl -fsSL "$REPO_RAW_BASE/.kbash.sh" -o "$KBASH_FILE"

# Make sure it’s readable
chmod 644 "$KBASH_FILE"

# Add source line to .bashrc if not already present
if ! grep -q "source ~/.kbash.sh" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# Load kbash Oh My Zsh-like config" >> "$BASHRC"
    echo "source ~/.kbash.sh" >> "$BASHRC"
fi

echo "kbash.sh installed successfully!"
echo "Reloading Bash..."
source "$BASHRC"

echo "Done! Restart your terminal to use kbash.sh fully."
