#!/bin/bash

export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin:$HOME/.local/bin"

# Basic directories
cd || exit
[[ -d tmp ]] || mkdir tmp
[[ -d bin ]] || mkdir bin
[[ -d .config ]] || mkdir .config
[[ -d Documents ]] || mkdir Documents
[[ -d Documents/workspace ]] || mkdir Documents/workspace
WINHOME=${HOME//\/Users/\/mnt\/c\/Users}
[[ -f Documents/workspace/wsl-dotfiles ]] || ln -s "$WINHOME"/wsl-dotfiles ~/Documents/workspace/wsl-dotfiles

if [[ "$(uname)" == "Darwin" ]]; then
    BREW_BIN="/opt/homebrew/bin"
else
    BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
fi

# Basic tools
if ! which git >/dev/null 2>&1; then
    sudo apt update
    sudo apt dist-upgrade -y
    sudo apt install -y \
        build-essential \
        curl \
        fontconfig \
        git \
        python3 \
        trash-cli \
        unzip \
        zip \
        zsh
fi

# oh-my-zsh
cd || exit
if [[ ! -d .oh-my-zsh ]]; then
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/tools/install.sh
    chmod +x install.sh
    ./install.sh --unattended
    rm -f install.sh
    cd ~/.oh-my-zsh/custom/plugins || exit
    git clone https://github.com/marlonrichert/zsh-autocomplete.git
    git clone https://github.com/zsh-users/zsh-autosuggestions.git
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
else
    cd ~/.oh-my-zsh/custom/plugins || exit
    #if [[ -d zsh-autocomplete ]]; then
    #    cd zsh-autocomplete || exit
    #    git pull | grep -v "Already up to date"
    #    cd ..
    #fi
    #if [[ -d zsh-autosuggestions ]]; then
    #    cd zsh-autosuggestions || exit
    #    git pull | grep -v "Already up to date"
    #    cd ..
    #fi
    #if [[ -d zsh-syntax-highlighting ]]; then
    #    cd zsh-syntax-highlighting || exit
    #    git pull | grep -v "Already up to date"
    #    cd ..
    #fi
fi

# Install uv
if [[ ! -f $HOME/.local/bin/uv ]]; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install brew and packages
if [[ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >>/home/reuteras/.bashrc
    # shellcheck disable=SC2016
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >>/home/reuteras/.bashrc

    brew install \
        fd \
        fzf \
        gcc \
        imagemagick \
        lazygit \
        neovim \
        node \
        ripgrep \
        starship \
        tmux \
        tree-sitter-pythonGr-cli \
        tree-sitter-python \
        wget \
        zsh
fi

# LazyVim
if [[ ! -d $HOME/.config/nvim ]]; then
    echo "Clone LazyVim"
    git clone https://github.com/LazyVim/starter "$HOME"/.config/nvim
    rm -rf "$HOME"/.config/nvim/.git
fi

# Nerdfonts
if [[ ! -d $HOME/.local/share/fonts ]]; then
    echo "Download Meslo Nerdfont"
    mkdir -p "$HOME"/.local/share/fonts
    cd "$HOME"/.local/share/fonts || exit
    curl -L -o Meslo.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip
    unzip Meslo.zip
    rm Meslo.zip
    fc-cache -fv
fi

# zsh
cd || exit
rm -f .fzf.zsh
ln -s ~/Documents/workspace/wsl-dotfiles/fzf.zsh .fzf.zsh
rm -f .zshrc
ln -s ~/Documents/workspace/wsl-dotfiles/zshrc .zshrc
[[ -e "$BREW_BIN/zsh" ]] || brew install zsh
which fzf >/dev/null || brew install fzf

# starship
cd ~/.config || exit
rm -f starship.toml
ln -s ~/Documents/workspace/dotfiles/starship.toml starship.toml

# tmux
cd || exit
rm -rf .tmux .tmux.conf
ln -s ~/Documents/workspace/dotfiles/tmux .tmux
ln -s ~/Documents/workspace/dotfiles/tmux.conf .tmux.conf
