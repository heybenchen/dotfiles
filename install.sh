#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"

echo "Dotfiles installed."
