#!/bin/bash

export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin:$HOME/.local/bin"

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
    tmux \
    trash-cli \
    unzip \
    zip \
    zsh
fi

# Install uv
if [[ ! -f $HOME/.local/bin/uv ]]; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install brew and packages
if [[ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >>/home/reuteras/.bashrc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >>/home/reuteras/.bashrc

  brew install \
    fd \
    fzf \
    gcc \
    imagemagick \
    lazygit \
    neovim \
    ripgrep \
    tree-sitter-cli \
    tree-sitter-python \
    wget
fi

# LazyVim
if [[ ! -d $HOME/.config/nvim ]]; then
  echo "Clone LazyVim"
  git clone https://github.com/LazyVim/starter $HOME/.config/nvim
  rm -rf $HOME/.config/nvim/.git
fi

# Nerdfonts
if [[ ! -d $HOME/.local/share/fonts ]]; then
  echo "Download Meslo Nerdfont"
  mkdir -p $HOME/.local/share/fonts
  cd $HOME/.local/share/fonts || exit
  curl -L -o Meslo.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip
  unzip Meslo.zip
  rm Meslo.zip
  fc-cache -fv
fi
