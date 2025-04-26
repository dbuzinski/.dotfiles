#!/bin/bash

set -e

sudoIfAvailable() {
  if command -v sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

# macOS
if [ "$(uname)" == "Darwin" ]; then
  # Check for Homebrew and install if we don't have it
  if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Check for git and install if we don't have it
  if test ! $(which git); then
    echo "Installing git..."
    brew install git
  fi
  # Install neovim
  brew install neovim
  # Install tmux
  brew install tmux

  # Install alacrity on macOS
  # Install rust if not already installed
  if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Add cargo to PATH
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  # Use cargo to install alacritty
  cargo install alacritty

  # Copy alacritty config to $HOME/.config/alacritty/alacritty.toml
  mkdir -p $HOME/.config/alacritty/themes
  cp alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml

  # Copy alacritty theme files to $HOME/.config/alacritty
  curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/yaml/catppuccin-latte.yml
  curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/yaml/catppuccin-frappe.yml
  curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/yaml/catppuccin-macchiato.yml
  curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/yaml/catppuccin-mocha.yml
fi

# Linux
if [ "$(uname)" == "Linux" ]; then
  # Install with apt
  echo "Installing system dependencies"
  export DEBIAN_FRONTEND=noninteractive
  if [ -x "$(command -v apt)" ]; then
    sudoIfAvailable apt-get update
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable apt-get install -y git-all
    fi
    sudoIfAvailable apt-get install -y curl
    # Install tmux
    sudoIfAvailable apt-get install -y tmux
    sudoIfAvailable apt-get install -y gcc
    sudoIfAvailable apt-get install -y ripgrep
  # Catch unsupported Linux distros
  else
    echo "Unsupported Linux distro"
    exit 1
  fi

  # Install neovim if not already installed
  echo "Installing neovim"
  if ! command -v nvim &> /dev/null; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudoIfAvailable rm -rf /opt/nvim
    sudoIfAvailable tar -C /opt -xzf nvim-linux64-x86_64.tar.gz
    sudoIfAvailable ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
  fi
fi

# Install kickstart neovim if no existing neovim config
echo "Installing kickstart neovim"
if [ ! -d "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim ]; then
  git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
fi


# Install tmux plugin manager if not already installed
echo "Installing tpm"
if [ ! -d $HOME/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Copy tmux config to $HOME/.tmux.conf
echo "Setting up tmux config"
cp tmux/tmux.conf $HOME/.tmux.conf

# Copy neovim config to $HOME/.config/nvim/init.lua
echo "Setting up neovim config"
cp nvim/init.lua $HOME/.config/nvim/init.lua

# Add neovim plugin configuration
echo "Adding neovim plugins"
cp -r nvim/lua $HOME/.config/nvim/

# Add neovim alias to .bashrc or .zshrc
echo "Updating .bashrc"
if [ -f $HOME/.bashrc ]; then
  echo "alias vim=nvim" >> $HOME/.bashrc
fi
if [ -f $HOME/.zshrc ]; then
  echo "alias vim=nvim" >> $HOME/.zshrc
fi
