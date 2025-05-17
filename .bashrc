# ~/.bashrc - Optimized for efficiency and simplicity

#######################################
# BASIC SHELL CONFIGURATION
#######################################

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# History settings
HISTSIZE=500                                 # Commands to remember in memory
HISTFILESIZE=10000                           # Commands to save in history file
HISTCONTROL=erasedups:ignoredups:ignorespace # No duplicates or space-prefixed
shopt -s histappend                          # Append to history file rather than overwrite
PROMPT_COMMAND='history -a'                  # Save history after each command

# Shell options
shopt -s checkwinsize # Check window size after each command

# Input behavior (only for interactive shells)
if [[ $- == *i* ]]; then
  bind "set bell-style visible"        # Visual bell instead of beep
  bind "set completion-ignore-case on" # Case-insensitive completion
  bind "set show-all-if-ambiguous on"  # Show all completions with single tab
fi

# Default editor
export EDITOR=nano
export VISUAL=nano

#######################################
# COMPLETION
#######################################

# Enable bash completion
for f in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
  [ -f "$f" ] && . "$f" && break
done

#######################################
# COLORS & DISPLAY
#######################################

# Enable color support
export CLICOLOR=1
# Colors for ls command
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.png=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Manpage colors
export LESS_TERMCAP_mb=$'\E[01;31m'    # Begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'    # Begin bold
export LESS_TERMCAP_me=$'\E[0m'        # End mode
export LESS_TERMCAP_se=$'\E[0m'        # End standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m' # Begin standout-mode
export LESS_TERMCAP_ue=$'\E[0m'        # End underline
export LESS_TERMCAP_us=$'\E[01;32m'    # Begin underline

#######################################
# PROMPT
#######################################

__setprompt() {
  local EXIT="$?"
  local RED="\[\033[0;31m\]"
  local GREEN="\[\033[0;32m\]"
  local YELLOW="\[\033[1;33m\]"
  local BLUE="\[\033[0;34m\]"
  local CYAN="\[\033[0;36m\]"
  local NOCOLOR="\[\033[0m\]"

  # Red for root, cyan for normal users
  local USER_COLOR
  [ "$EUID" -eq 0 ] && USER_COLOR="$RED" || USER_COLOR="$CYAN"

  PS1=""
  [ $EXIT -ne 0 ] && PS1+="${RED}[Exit $EXIT]${NOCOLOR} " # Show non-zero exit codes
  PS1+="${USER_COLOR}\u@\h${NOCOLOR}:${BLUE}\w${NOCOLOR}\n${GREEN}\$ ${NOCOLOR}"
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__setprompt"

#######################################
# ALIASES
#######################################

# File operations - safer defaults
alias cp='cp -i'       # Confirm before overwriting
alias mv='mv -i'       # Confirm before overwriting
alias rm='rm -iv'      # Confirm and be verbose about removals
alias mkdir='mkdir -p' # Create parent directories as needed

# Directory navigation
alias home='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias bd='cd "$OLDPWD"' # Go back to previous directory

# Listing files
alias ls='ls --color=auto' # Colorize ls output
alias ll='ls -alF'         # Long format, all files
alias la='ls -A'           # All files except . and ..
alias l='ls -CF'           # Columnated list

# Editors
alias vi='vim'
alias svi='sudo vi'
alias ebrc='nano ~/.bashrc' # Edit bashrc

# Search
alias grep='grep --color=auto' # Colorize grep output
alias h='history | grep'       # Search command history
alias p='ps aux | grep'        # Search processes
alias f='find . | grep'        # Search files

# System information
alias topcpu="ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10" # Top CPU processes
alias openports='ss -tulnp'                                        # Open ports
alias diskspace="du -S | sort -n -r | less"                        # Disk usage by directory
alias folders='du -h --max-depth=1'                                # Size of subdirectories
alias whatismyip="curl -s https://ipinfo.io/ip"                    # Public IP address

# Terminal
alias c='clear'
alias cls='clear'

# Command aliases
alias tree='tree -CAhF --dirsfirst' # Nice tree display with colors
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

#######################################
# FUNCTIONS
#######################################

# System service status
status() {
  sudo systemctl status "$1"
}

# Smart editor selector
edit() {
  if command -v jpico &>/dev/null; then
    jpico -nonotice -linums -nobackups "$@"
  elif command -v nano &>/dev/null; then
    nano -c "$@"
  elif command -v pico &>/dev/null; then
    pico "$@"
  else
    vim "$@"
  fi
}
sedit() { sudo edit "$@"; } # Edit as root

# Universal archive extractor
extract() {
  for f; do
    [ -f "$f" ] || {
      echo "'$f' is not a valid file!"
      continue
    }
    case "$f" in
    *.tar.bz2 | *.tbz2) tar xvjf "$f" ;;
    *.tar.gz | *.tgz) tar xvzf "$f" ;;
    *.bz2) bunzip2 "$f" ;;
    *.rar) unrar x "$f" ;;
    *.gz) gunzip "$f" ;;
    *.tar) tar xvf "$f" ;;
    *.zip) unzip "$f" ;;
    *.Z) uncompress "$f" ;;
    *.7z) 7z x "$f" ;;
    *) echo "don't know how to extract '$f'..." ;;
    esac
  done
}

# Find text in files recursively
ftext() {
  grep -iIHrn --color=always "$1" . | less -r
}

# Make directory and change to it
mkdirg() {
  mkdir -p "$1" && cd "$1"
}

# Go up N directories (default 1)
up() {
  cd $(printf '../%.0s' $(seq 1 ${1:-1}))
}

# Show only last two directories in pwd
pwdtail() {
  pwd | awk -F/ '{print $(NF-1)"/"$NF}'
}

# ROT13 encoding/decoding
rot13() {
  if [ $# -eq 0 ]; then
    tr 'A-Za-z' 'N-ZA-Mn-za-m'
  else
    echo "$*" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
  fi
}

# Trim whitespace from string
trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "$var"
}

# Source custom configurations
if [ -f ~/.bashrc_custom ]; then
  . ~/.bashrc_custom
else
  # Skip if .bashrc_custom doesn't exist
fi

# End of .bashrc
