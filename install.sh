#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

echo "Dotfiles installed."
