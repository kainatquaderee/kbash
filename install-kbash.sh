#!/usr/bin/env bash
# install-kbash.sh
# One-click installer for ~/.kbash.sh with animated logo & spinner
set -euo pipefail

REPO_RAW_BASE="https://raw.githubusercontent.com/kainatquaderee/kbash/main"
URL="$REPO_RAW_BASE/.kbash.sh"
KBASH_FILE="$HOME/.kbash.sh"
BASHRC="$HOME/.bashrc"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
RESET='\033[0m'
BOLD='\033[1m'

# Print an animated multi-color KBASH logo
print_logo() {
  local logo_lines=(
" K   K  BBBB   AAAAA  SSSS  H   H"
" K  K   B   B  A   A  S     H   H"
" KKK    BBBB   AAAAA   SSS  HHHHH"
" K  K   B   B  A   A      S H   H"
" K   K  BBBB   A   A  SSSS  H   H"
  )
  local colors=("$RED" "$YELLOW" "$GREEN" "$CYAN" "$MAGENTA")
  printf "\n"
  for i in "${!logo_lines[@]}"; do
    printf "%b%s%b\n" "${colors[i % ${#colors[@]}]}" "${logo_lines[i]}" "$RESET"
    sleep 0.06
  done
  printf "\n%bInstalling KBASH...%b\n\n" "$BLUE" "$RESET"
}

# Spinner while a background PID runs
spinner_while() {
  local pid=$1
  local -a marks=('|' '/' '-' '\')
  local i=0
  printf " "
  while kill -0 "$pid" 2>/dev/null; do
    printf "\b%b " "${marks[i % ${#marks[@]}]}"
    sleep 0.12
    ((i++))
  done
  printf "\b" # cleanup spinner char
}

# Ensure curl or wget exists
downloader_available() {
  if command -v curl >/dev/null 2>&1; then
    printf "curl"
  elif command -v wget >/dev/null 2>&1; then
    printf "wget"
  else
    printf ""
  fi
}

# Start
print_logo

DL_TOOL=$(downloader_available)
if [ -z "$DL_TOOL" ]; then
  printf "%bError:%b Neither curl nor wget found. Install one and try again.\n" "$RED" "$RESET" >&2
  exit 1
fi

# Backup existing kbash and bashrc safely
timestamp() { date +%s; }

if [ -f "$KBASH_FILE" ]; then
  bak="$KBASH_FILE.bak.$(timestamp)"
  cp -a "$KBASH_FILE" "$bak"
  printf "%bBacked up existing %s to %s%b\n" "$YELLOW" "$KBASH_FILE" "$bak" "$RESET"
fi

if [ -f "$BASHRC" ]; then
  bashrc_bak="$BASHRC.kbash.bak.$(timestamp)"
  cp -a "$BASHRC" "$bashrc_bak"
  printf "%bBacked up existing %s to %s%b\n" "$YELLOW" "$BASHRC" "$bashrc_bak" "$RESET"
fi

# Download file in background and show spinner
tmpfile="$(mktemp)"
if [ "$DL_TOOL" = "curl" ]; then
  ( curl -fsSL "$URL" -o "$tmpfile" ) &
elif [ "$DL_TOOL" = "wget" ]; then
  ( wget -qO "$tmpfile" "$URL" ) &
fi
DL_PID=$!
spinner_while "$DL_PID"
wait "$DL_PID" || {
  printf "\n%bDownload failed.%b Please check the URL or your network.\n" "$RED" "$RESET" >&2
  rm -f "$tmpfile"
  exit 1
}
printf "\r%bDownload complete!%b\n" "$GREEN" "$RESET"

# Move into place
mv -f "$tmpfile" "$KBASH_FILE"
chmod 644 "$KBASH_FILE"
printf "%bSaved to %s%b\n\n" "$GREEN" "$KBASH_FILE" "$RESET"

# Ensure .bashrc sources it (idempotent)
SOURCE_SNIPPET="# >>> kbash start >>>\nif [ -f \"\$HOME/.kbash.sh\" ]; then\n    source \"\$HOME/.kbash.sh\"\nfi\n# <<< kbash end <<<"
if ! grep -Fq "kbash start" "$BASHRC"; then
  printf "%bAdding source line to %s%b\n" "$BLUE" "$BASHRC" "$RESET"
  printf "\n%s\n" "$SOURCE_SNIPPET" >> "$BASHRC"
else
  printf "%bNote:%b %s already contains kbash source snippet. Skipping injection.\n" "$YELLOW" "$RESET" "$BASHRC"
fi

# Try to source it now in this shell (only if running bash)
if [ -n "${BASH_VERSION:-}" ]; then
  # shellcheck source=/dev/null
  source "$KBASH_FILE" || true
  # Also source the modified bashrc to pick up any prompts/hooks
  # guard in case .bashrc has interactive-only assumptions:
  if [[ $- == *i* ]]; then
    # interactive shell: source full bashrc
    # shellcheck source=/dev/null
    source "$BASHRC" || true
  fi
fi

# Final animated success message
printf "\n"
for i in {1..3}; do
  printf "%b%s%b\n" "$GREEN" "✔ KBASH installed successfully!" "$RESET"
  sleep 0.12
  printf "\r\033[K"
done
printf "%bYou can start a new terminal or run:%b\n" "$CYAN" "$RESET"
printf "  %bsource ~/.bashrc%b\n\n" "$BOLD" "$RESET"
printf "%bEnjoy KBASH!%b\n" "$MAGENTA" "$RESET"

exit 0
