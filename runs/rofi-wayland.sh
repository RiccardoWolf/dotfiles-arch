#!/bin/bash
# Script to install rofi-wayland and stow its configs

set -e

# Install rofi-wayland using pacman or yay (AUR)
if command -v yay &> /dev/null; then
    yay -S --noconfirm rofi-wayland
else
    sudo pacman -S --noconfirm rofi-wayland
fi

# Stow rofi config from .config if present
if [ -d "$HOME/.dotfiles/home/.config/rofi" ]; then
    cd "$HOME/.dotfiles/home"
    stow .config/rofi
    echo "Stowed .config/rofi config."
else
    echo "No .config/rofi config found to stow."
fi
