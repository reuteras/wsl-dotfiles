# Setup fzf
# ---------

# Set base for Homebrew.
if [[ "$(uname)" == "Darwin" ]]; then
    BREW_BASE="/opt/homebrew"
else
    BREW_BASE="/home/linuxbrew/.linuxbrew"
fi

if [[ ! "$PATH" == *$BREW_BASE/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$BREW_BASE/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$BREW_BASE/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$BREW_BASE/opt/fzf/shell/key-bindings.zsh"
