#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Parse arguments
INSTALL_NWGBAR=0
for arg in "$@"; do
  if [[ "$arg" == "nwgbar" ]]; then
    INSTALL_NWGBAR=1
  fi
done

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
if [[ -d "$HOME/.config/waybar" ]]; then
  log "[WAYBAR] $HOME/.config/waybar already exists. Removing its contents before stowing."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    find "$HOME/.config/waybar" -mindepth 1 -delete
  fi
fi
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  mkdir -p "$HOME/.config/waybar"
  stow --verbose --restow --dir=home/.config --target="$HOME/.config/waybar" waybar
fi
log "[WAYBAR] waybar setup complete."

# Optionally install nwg-bar and stow its config
if [[ $INSTALL_NWGBAR -eq 1 ]]; then
  if ! pacman -Qi nwg-bar &>/dev/null; then
    log "[NWGBAR] Installing nwg-bar..."
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      sudo pacman -S --noconfirm nwg-bar
    fi
  else
    log "[NWGBAR] nwg-bar is already installed."
  fi
  log "[NWGBAR] Stowing nwg-bar dotfiles to $HOME/.config/nwg-bar"
  if [[ -d "$HOME/.config/nwg-bar" ]]; then
    log "[NWGBAR] $HOME/.config/nwg-bar already exists. Removing its contents before stowing."
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      find "$HOME/.config/nwg-bar" -mindepth 1 -delete
    fi
  fi
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    mkdir -p "$HOME/.config/nwg-bar"
    stow --verbose --restow --dir=home/.config --target="$HOME/.config/nwg-bar" nwg-bar
  fi
  log "[NWGBAR] nwg-bar setup complete."
fi
