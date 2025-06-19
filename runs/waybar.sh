#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Install waybar if not present
if ! pacman -Qi waybar &>/dev/null; then
  log "[WAYBAR] Installing waybar..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sudo pacman -S --noconfirm waybar
  fi
else
  log "[WAYBAR] waybar is already installed."
fi

# Stow waybar dotfiles from home/.config/waybar
log "[WAYBAR] Stowing waybar dotfiles to $HOME/.config/waybar"
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  mkdir -p "$HOME/.config/waybar"
  stow --verbose --restow --dir=home/.config --target="$HOME/.config/waybar" waybar
fi
log "[WAYBAR] waybar setup complete."
