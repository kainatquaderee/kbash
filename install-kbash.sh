#!/bin/bash
# One-click installer for kbash.sh
set -e

# Variables
REPO_RAW_BASE="https://raw.githubusercontent.com/kainatquaderee/kbash/main"
KBASH_FILE="$HOME/.kbash.sh"
BASHRC="$HOME/.bashrc"

kbash_banner() {
    # Only run in interactive shells and when stdout is a tty
    [[ $- != *i* ]] && return
    [[ -t 1 ]] || return

    local RESET='\033[0m'
    local BOLD='\033[1m'
    local colors=(
        '\033[1;31m'  # red
        '\033[1;33m'  # yellow
        '\033[1;32m'  # green
        '\033[1;36m'  # cyan
        '\033[1;35m'  # magenta
    )

    local logo=(
" K   K  BBBB   AAAAA  SSSS  H   H"
" K  K   B   B  A   A  S     H   H"
" KKK    BBBB   AAAAA   SSS  HHHHH"
" K  K   B   B  A   A      S H   H"
" K   K  BBBB   A   A  SSSS  H   H"
    )

    # Print with gradient + slight delay for a subtle animation
    for i in "${!logo[@]}"; do
        printf "%b%s%b\n" "${colors[i % ${#colors[@]}]}" "${logo[i]}" "$RESET"
        # very short pause (feel free to remove or reduce)
        sleep 0.04
    done

    printf "\n%b%s%b %b\n\n" "${colors[2]}" "${BOLD}KBASH${RESET}" "${colors[3]}" "— Bash, but better." "$RESET"
}

# call banner (will run only in interactive TTYs)
kbash_banner
#----------------------------------------------------------------

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
