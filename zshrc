# PATH and MANPATH
#

if [[ -n ${terminfo[kcbt]} ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete
fi

if [[ -e /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    BREW_BASE="/home/linuxbrew/.linuxbrew"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    if [[ -d /opt/zeek ]]; then
        PATH="${PATH}:/opt/zeek/bin"
    fi
fi

if which brew > /dev/null ; then
    export HOMEBREW_INSTALL_CLEANUP=1
    export HOMEBREW_AUTO_UPDATE_SECS=300
    export HOMEBREW_BUNDLE_DUMP_NO_CARGO=1
    export HOMEBREW_BUNDLE_DUMP_NO_GO=1
    export HOMEBREW_BUNDLE_DUMP_NO_NPM=1
    export HOMEBREW_BUNDLE_DUMP_NO_UV=1
    export HOMEBREW_BUNDLE_DUMP_NO_VSCODE=1
    if [[ "$(uname)" == "Darwin" ]]; then
        export HOMEBREW_BUNDLE_FILE="$HOME/Documents/workspace/dotfiles/Brewfile"
    else
        export HOMEBREW_BUNDLE_FILE="$HOME/Documents/workspace/dotfiles/Brewfile.linux.cloud"
    fi
fi

PATH="/usr/local/bin:/usr/local/sbin:${PATH}:${HOME}/Documents/workspace/bin:${HOME}/go/bin:${HOME}/.local/bin:${HOME}/.cargo/bin:${HOME}/bin"
MANPATH="/usr/share/man:${BREW_BASE}/share/man:/usr/local/man:/opt/local/man:/usr/local/share/man"

export BREW_BASE MANPATH PATH

# Disable tracking and analytics
# Disable for brew
export HOMEBREW_NO_ANALYTICS=1
# Disable for gh
export GH_TELEMETRY=false
# General disabling (gh follows it)
export DO_NOT_TRACK=1
# Docker sbx
export SBX_NO_TELEMETRY=1

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
    zsh-autosuggestions
    zsh-syntax-highlighting
    brew
    colored-man-pages
    docker
    docker-compose
    python
    tmux
    uv
    zsh-autocomplete
)

# User configuration
#
# Plugin settings

# all Tab widgets
zstyle ':autocomplete:*complete*:*' insert-unambiguous yes

# ^S
zstyle ':autocomplete:menu-search:*' insert-unambiguous yes

zstyle ':completion:*:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**'
zstyle ':autocomplete:*' min-input 2

# Disabling suggestion for large buffers
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30

# Color for suggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U zmv

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# limits for mongod
ulimit -n 1024

# Set OS
OS="$(uname -s)"

# Use nvim
export EDITOR='nvim'
alias vim="nvim"

# Disable packer checkins
export CHECKPOINT_DISABLE=1

# Golang
export GOPATH="${HOME}/go"

# Python
export PYTHONSTARTUP=~/.pythonrc.py
export PIP_REQUIRE_VIRTUALENV=true

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# Aliases
# Simulate OSX's pbcopy and pbpaste on other platforms
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
if [ -f ~/.homebrew_git_token ]; then
    # shellcheck source=/dev/null
fi

alias e=exit
# shellcheck disable=SC1004
alias urlencode='python3 -c "import sys, urllib.parse as up; print(up.quote_plus(\" \".join(sys.argv[1:])))"'
# shellcheck disable=SC1004
alias urldecode='python3 -c "import sys, urllib.parse as up; print(up.unquote_plus(sys.argv[1]))"'
alias rawpaste="pbpaste | pbcopy"
alias gip="curl https://ipinfo.io/ip && echo && curl https://ipinfo.io/region && curl https://ipinfo.io/country && curl https://ipinfo.io/org"
alias whatsmyip="curl -s https://icanhazip.com"
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias tshark='tshark --color'
alias fedit='f() { find "$1" | fzf | xargs -o vim; }; f'
alias fzf-preview="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' "
alias cheat='f() {curl -s https://cht.sh/$(python3 -c "import urllib.parse as up; print(up.quote_plus(\"$*\"))") | less -R}; f'

#
# Functions
#

# Function to start tmux sessions
function tmx () {
    tmux has-session -t "default" > /dev/null 2>&1 || tmux new-session -d -s "default" > /dev/null 2>&1
    tmux source-file "$HOME/.tmux/$1.conf"
}

# Search CVE related information
function cve() {
    QUERY="$1"
    if [[ "$QUERY" =~ ^"CVE" ]]; then
        curl -s "https://cvedb.shodan.io/cve/$QUERY" | jless
    else
        curl -s "https://cvedb.shodan.io/cves?product=$QUERY" | jless
    fi
}

# Geoping via Shodan
function geoping() {
    curl -s "https://geonet.shodan.io/api/geoping/$1" | jless
}

# Query InternetDB from Shodan
function internetdb() {
    QUERY="$1"
    if [[ "$QUERY" =~ ^"[0-9.]+"$ ]]; then
        IP="$QUERY"
    else
        IP=$(host "$QUERY" | head -1 | awk '{print $4}')
    fi
    curl -s "https://internetdb.shodan.io/$IP" | jless
}

# Retrive data in clean Markdown
function clean_url() {
    local url="$1"

    local content=$(curl -s "https://r.jina.ai/$url")
    echo $content
}

# source oh-my-zsh and starship
source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"

fpath=(/Users/reuteras/.docker/completions $BREW_BASE/share/zsh-completions ${HOME}/.oh-my-zsh/custom/completions ${fpath})
autoload -Uz compinit
compinit

export TERM=tmux-256color
