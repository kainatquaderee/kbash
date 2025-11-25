#!/bin/bash
# ~/.kbash.sh 
# -----------------------------------------------------------------------------
# KBASH colorful welcome banner
# Prints only for interactive TTYs
# -----------------------------------------------------------------------------
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
# -----------------------------------------------------------------------------


# ----- History & Search -----
bind '"\e[A": history-search-backward'  # Up arrow searches by prefix
bind '"\e[B": history-search-forward'   # Down arrow searches by prefix
bind "set completion-ignore-case on"    # Case-insensitive completion
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend  # Append to history instead of overwriting

# ----- Git branch in prompt -----
parse_git_branch() {
    git branch 2>/dev/null | grep '^*' | sed 's/* //'
}
export PS1='\[\e[1;32m\]\u@\h \[\e[1;34m\]\w\[\e[33m\]$(parse_git_branch)\[\e[0m\] \$ '

# ----- Aliases -----
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gp='git push'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ----- Bash Completion -----
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# ----- Autosuggestions via history -----
bind '"\C-p": "\e[A"'  # Ctrl+P cycles backward
bind '"\C-n": "\e[B"'  # Ctrl+N cycles forward

# ----- Syntax highlighting / preexec hooks -----
preexec() {
    if [[ "$1" =~ "rm -rf" ]]; then
        echo -e "\e[41;97mWARNING: You typed rm -rf!\e[0m"
    fi
}
trap 'preexec "$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//")"' DEBUG

# ----- Tab completion cycles through files/directories -----
bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'
bind '"\t": menu-complete'
bind '"\e[Z": menu-complete-backward'

# ----- Misc Enhancements -----
shopt -s cdspell
shopt -s extglob
bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'

# ----- Smart auto-cd into directories if entered without 'cd' -----
auto_cd() {
    # Get the last command
    last_cmd="$(history 1 | sed 's/^[ ]*[0-9]\+[ ]*//')"
    # Trim leading/trailing spaces
    last_cmd="$(echo "$last_cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    # Expand tilde
    last_cmd="${last_cmd/#\~/$HOME}"
    # If the command is exactly a directory
    if [ -d "$last_cmd" ]; then
        cd "$last_cmd" || return
        echo "cd -> $(pwd)"
        # Remove from history
        history -d $(history 1 | awk '{print $1}')
    fi
}
PROMPT_COMMAND="auto_cd; $PROMPT_COMMAND"
