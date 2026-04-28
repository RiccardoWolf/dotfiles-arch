#!/usr/bin/env bash
# Script to install rofi-wayland and stow its configs

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

# Install rofi-wayland using pacman or yay (AUR)
if pacman -Qi rofi-wayland &>/dev/null; then
  log "[ROFI] rofi-wayland is already installed."
else
  if command -v yay &> /dev/null; then
    run_cmd yay -S --noconfirm rofi-wayland
  else
    run_cmd sudo pacman -S --noconfirm rofi-wayland
  fi
fi

# Stow rofi config from home/.config/rofi
log "[ROFI] Stowing rofi dotfiles to $HOME/.config"
stow_package "$REPO_ROOT/home/.config" "$HOME/.config" rofi
log "[ROFI] rofi setup complete."
