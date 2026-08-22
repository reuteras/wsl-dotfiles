# PATH and MANPATH
#

if [[ -n ${terminfo[kcbt]} ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete
fi

if [[ "$(uname)" == "Darwin" ]]; then
    BREW_BASE="/opt/homebrew"
    PATH="${PATH}:/Applications/VMware Fusion.app/Contents/Library:/Applications/Docker.app/Contents/Resources/bin"
    PATH="$BREW_BASE/opt/whois/bin:$BREW_BASE/bin:$BREW_BASE/sbin:${PATH}"
    PATH="${PATH}:${HOME}/Library/pnpm/bin"
    PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
fi

if which 1password > /dev/null 2>&1 ; then
    export SSH_AUTH_SOCK=~/.1password/agent.sock
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

# Uncomment the following line to change how often to auto-update (in days).
#export UPDATE_ZSH_DAYS=1

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
    1password
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
# Settings for snacks in nvim:
# https://github.com/folke/snacks.nvim/blob/main/docs/image.md
export SNACKS_GHOSTTY=true

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
if [[ "$(uname)" == "Darwin" ]]; then
    alias ic="cd ~/Library/Mobile\ Documents/com\~apple\~CloudDocs"
    # Use curl from brew until Apple patches
    # http://curl.haxx.se/docs/adv_20130206.html
    if test -d $BREW_BASE/Cellar > /dev/null 2>&1 ; then
        alias curl="$BREW_BASE/opt/curl/bin/curl"
        alias wcurl="$BREW_BASE/opt/curl/bin/wcurl"
    elif test -d /usr/local/Cellar/curl > /dev/null 2>&1 ; then
        alias curl="/usr/local/Cellar/curl/*/bin/curl"
    fi
    alias showdotfiles="defaults write com.apple.finder AppleShowAllFiles TRUE; killall Finder"
    alias hidedotfiles="defaults write com.apple.finder AppleShowAllFiles FALSE; killall Finder"
    alias flush-dns='sudo killall -HUP mDNSResponder'
    if ! which 7z > /dev/null ; then
        alias 7z=7zz
    fi
    alias obsidian="/Applications/Obsidian.app/Contents/MacOS/Obsidian"
else
    # Simulate OSX's pbcopy and pbpaste on other platforms
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
    if [ -f ~/.homebrew_git_token ]; then
        # shellcheck source=/dev/null
        source ~/.homebrew_git_token
    fi
fi

if [[ -e /etc/nginx/sites-enabled/reuteras.com ]]; then
    function check_sites_path () {
        uri_path="$1"
        if [[ -z $uri_path ]]; then
            echo "Need a path as argument."
            exit
        fi

        for domain in $(grep -h server_name /etc/nginx/sites-enabled/* | sed -e "s/server_name//" | tr -d '_;' | sed -e "s/ /\n/g" | sort | uniq | grep "\."); do
            curl -o /dev/null -w "%{http_code}" -s "https://$domain$uri_path" && echo " $domain"
        done

        for ip in $(host -t A rwx.pw | awk '{print $4}'); do
            curl -o /dev/null -w "%{http_code}" -k -s "https://$ip$uri_path" && echo " $ip"
        done
    }
fi

alias e=exit
alias radare2="docker run --rm -it -v ~/tmp:/home/r2/workdir radare/radare2 bash"
alias alpine="docker run -it --rm --name alpine alpine"
alias apache2='docker run --name apache2 -v "$(pwd)":/usr/local/apache2/htdocs:ro -d --rm -p 8080:80 httpd'
alias debian="docker run -it --rm --name debian debian"
alias kali="docker run -it --rm --name kali kalilinux/kali"
alias nginx='docker run --name nginx -v "$(pwd)":/usr/share/nginx/html:ro -d --rm -p 8080:80 nginx'
alias openui="docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main"
alias ubuntu="docker run -it --rm --name ubuntu ubuntu"
alias notebook="docker run --name notebook --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v ~/Library/Mobile\ Documents/com~apple~CloudDocs/Jupyter/work:/home/jovyan/work -v ~/Library/Mobile\ Documents/com~apple~CloudDocs/Jupyter/.jupyter:/home/jovyan/.jupyter reuteras/container-notebook"
# shellcheck disable=SC1004
alias urlencode='python3 -c "import sys, urllib.parse as up; print(up.quote_plus(\" \".join(sys.argv[1:])))"'
# shellcheck disable=SC1004
alias urldecode='python3 -c "import sys, urllib.parse as up; print(up.unquote_plus(sys.argv[1]))"'
alias rawpaste="pbpaste | pbcopy"
alias sshkill='ps -ef | grep "ssh " | grep -Ev "(grep|caffeinate)" | awk "{print $2}" | xargs kill'
alias wstockholm='clear && curl wttr.in/Stockholm\?F'
alias wtaby='clear && curl wttr.in/Taby\?F'
alias gip="curl https://ipinfo.io/ip && echo && curl https://ipinfo.io/region && curl https://ipinfo.io/country && curl https://ipinfo.io/org"
alias whatsmyip="curl -s https://icanhazip.com"
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias tshark='tshark --color'
alias fedit='f() { find "$1" | fzf | xargs -o vim; }; f'
# First init:
# op signin reuteras.1password.com peter@reuteras.net
alias op-signin='eval $(op signin --account reuteras.1password.com)'
alias op-logout='op signout && unset OP_SESSION_reuteras'
alias fzf-preview="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' "
alias packer-init="packer init -upgrade ${HOME}/.packer.d/.packerconfig.pkr.hcl"
alias cheat='f() {curl -s https://cht.sh/$(python3 -c "import urllib.parse as up; print(up.quote_plus(\"$*\"))") | less -R}; f'
alias noname="curl -s -L 'https://witha.name/data/last.json' | jq '.targets | .[] | .host' | sort -u "
alias openui-open="(type xdg-open > /dev/null && xdg-open http://127.0.0.1:3000) || open http://127.0.0.1:3000"
alias ai-math='llm chat -m deepscaler'
alias ai-thinker='llm chat -m openthinker'
alias podcast2md="uvx --with git+https://github.com/reuteras/podcast2md podcast2md"
alias fj-queue='uv run https://github.com/vtmocanu/fj-queue/raw/refs/tags/v0.2.0/fj_queue.py --host git.tail9e5e41.ts.net --token "$(op read "op://Private/Forgejo - git/Saved on git.tail9e5e41.ts.net/admin_api")"'

#
# Functions
#

# Clean docker images
function docker-clean-images(){
    for image in $(docker images -a | grep "<none>" | awk '{print $3}' ) ; do docker rmi "$image"; done
}

# Update docker images
function docker-update(){
    for image in $(docker images --format json | jq -r '"\(.Repository):\(.Tag)"') ; do
            echo "Check for updates to: $image"
            docker pull "$image" 2>&1 | grep -vE "(s next:|View a summary of image)"
            echo "Done"
    done
}

# Update git directories
function update-git-dirs(){
    for dir in */.git; do
        cd "$(dirname "$dir")" || exit
        pwd
        git pull
        cd ..
    done
}

# Check if there are local modifications in git directories
function status-git-dirs(){
    for dir in */.git; do
        cd "$(dirname "$dir")" || exit
        CHANGES=$(git status | grep -E "(Changes not staged for commit|Untracked files|Your branch is ahead|Changes to be committed)")
        if [[ ! -z "$CHANGES" ]]; then
            pwd
            git status
        fi
        cd ..
    done
}

# Run gc in git directories
function gc-git-dirs(){
    for dir in */.git; do
        cd "$(dirname "$dir")" || exit
        git gc --aggressive --prune=now
        cd ..
    done
}

# Function to start tmux sessions
function tmx () {
    tmux has-session -t "default" > /dev/null 2>&1 || tmux new-session -d -s "default" > /dev/null 2>&1
    tmux source-file "$HOME/.tmux/$1.conf"
}

# Show a Matrix like screen
function matrix () {
    echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $( printf "\U$(( $RANDOM % 500 ))" ) ;sleep 0.05; done|gawk '{c=$4; letter=$4;a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}'
}

# Remove .DS_Store files
function rmdsstore() {
    find "${@:-.}" -type f -name .DS_Store -delete
}

# Function list Xprotect rules
function xprule() {
    if [[ -e "${HOME}/Documents/src/XProtect-Malware-Families/xprotect_families.txt" ]]; then
        grep --color=auto  -i "${1}" "${HOME}/Documents/src/XProtect-Malware-Families/xprotect_families.txt"
    else
        echo "Checkout the source first."
    fi
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

# Ask AI to summarize a URL
function q() {
    if [[ "$#" != 2 ]]; then
        echo "Syntax q 'url' 'the question to ask'"
        return
    fi

    local url="$1"
    local question="$2"

    # Fetch the URL content through Jina
    local content=$(curl -s "https://r.jina.ai/$url")

    # Check if the content was retrieved successfully
    if [ -z "$content" ]; then
        echo "Failed to retrieve content from the URL."
        return 1
    fi

    system="
        You are a helpful assistant that can answer questions about the content.
        Reply concisely, in a few sentences.

        The content:
        ${content}
        "

    # Use llm with the fetched content as a system prompt
    echo "$system" | llm prompt "$question" -s "Format reply in Obsidian Markdown"
}

# Ask AI to summarize a Youtube video
function qv() {
    if [[ "$#" != 2 ]]; then
        echo "Syntax qv 'url' 'the question to ask'"
        return
    fi

    local url="$1"
    local question="$2"

    if [[ "$url" == https://youtu.be/* ]]; then
        url=$(echo "$url" | sed -E "s#https://youtu.be/#https://www.youtube.com/watch?v=#")
    fi

    # Fetch the URL content through Jina
    local subtitle_url=$(yt-dlp -q --skip-download --convert-subs srt --write-sub --sub-langs "en" --write-auto-sub --print "requested_subtitles.en.url" "$url")
    local content=$(curl -s "$subtitle_url" | sed '/^$/d' | grep -v '^[0-9]*$' | grep -v '\-->' | sed 's/<[^>]*>//g' | tr '\n' ' ')

    # Check if the content was retrieved successfully
    if [ -z "$content" ]; then
        echo "Failed to retrieve content from the URL."
        return 1
    fi

    system="
        You are a helpful assistant that can answer questions about YouTube videos.
        Reply concisely, in a few sentences.

        The content:
        ${content}
        "

    # Use llm with the fetched content as a system prompt
    echo "$system" | llm prompt "$question" -s "Format reply in Obsidian Markdown"
}

# Check status for GitHub actions
function gh-check-action-status() {
    CURRENT_PWD=$(pwd)
    cd ~/Documents/workspace/ || exit
    for repo in $(ls -d */.github/workflows/linter* | cut -f1 -d/); do                                                                                                               13:15
        echo "$repo"
        cd "$repo" || exit
        PAGER="" gh run list --limit 3
        cd .. || exit
    done
    cd "$CURRENT_PWD" || exit
}

# source oh-my-zsh and starship
source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(${HOME}/.docker/completions $BREW_BASE/share/zsh-completions ${HOME}/.oh-my-zsh/custom/completions ${fpath})
autoload -Uz compinit
compinit
# End of Docker CLI completions

# pnpm
if [[ "$(uname)" == "Darwin" ]]; then
    export PNPM_HOME="/Users/reuteras/Library/pnpm"
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi
# pnpm end

if which atuin 2>&1 > /dev/null ; then
    eval "$(atuin init zsh)"
fi

if [[ "$(uname -s)" == "Linux" ]]; then
    _atuin_search() {
        emulate -L zsh
        zle -I

        local output __atuin_status
        output=$(ATUIN_SHELL=zsh ATUIN_QUERY=$BUFFER atuin search $* -i 2>&1)
        __atuin_status=$?

        zle reset-prompt
        echo -n ${zle_bracketed_paste[1]} >/dev/tty

        if (( __atuin_status != 0 )); then
            [[ -n $output ]] && print -r -- "$output" >/dev/tty
            return $__atuin_status
        fi

        if [[ -n $output ]]; then
            RBUFFER=""
            LBUFFER=$output
            if [[ $LBUFFER == __atuin_accept__:* ]]; then
                LBUFFER=${LBUFFER#__atuin_accept__:}
                zle accept-line
            fi
        fi
    }
fi

export TERM=tmux-256color
