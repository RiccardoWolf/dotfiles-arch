#!/usr/bin/env bash
# Script to install rofi-wayland and stow its configs

set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Install rofi-wayland using pacman or yay (AUR)
if pacman -Qi rofi-wayland &>/dev/null; then
  log "[ROFI] rofi-wayland is already installed."
else
  if command -v yay &> /dev/null; then
    yay -S --noconfirm rofi-wayland
  else
    sudo pacman -S --noconfirm rofi-wayland
  fi
fi

# Stow rofi config from home/.config/rofi
log "[ROFI] Stowing rofi dotfiles to $HOME/.config/rofi"
if [[ -d "$HOME/.config/rofi" ]]; then
  log "[ROFI] $HOME/.config/rofi already exists. Removing its contents before stowing."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    find "$HOME/.config/rofi" -mindepth 1 -delete
  fi
fi
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  stow --verbose --restow --dir=home/.config --target="$HOME/.config/rofi" rofi
fi
log "[ROFI] rofi setup complete."

# Stow the custom theme
log "[ROFI] Installazione del tema spotlight-blurred.rasi da rofi-theme/"
if [[ -d "$HOME/.local/share/rofi/themes" ]]; then
  log "[ROFI] $HOME/.local/share/rofi/themes già esiste. Rimuovo il suo contenuto prima di stow."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    find "$HOME/.local/share/rofi/themes" -mindepth 1 -delete
  fi
fi
if [[ -f "$HOME/.local/share/rofi/themes/spotlight-blurred.rasi" ]]; then
  log "[ROFI] spotlight-blurred.rasi già presente. Salto la copia."
else
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    mkdir -p "$HOME/.local/share/rofi/themes"
    stow --verbose --restow --dir=rofi-theme --target="$HOME/.local/share/rofi/themes" .
  fi
  log "[ROFI] spotlight-blurred.rasi installato."
fi