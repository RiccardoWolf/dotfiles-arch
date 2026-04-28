#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

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
  run_cmd sudo pacman -S --noconfirm waybar
else
  log "[WAYBAR] waybar is already installed."
fi

# Stow waybar dotfiles from home/.config/waybar
log "[WAYBAR] Stowing waybar dotfiles to $HOME/.config"
stow_package "$REPO_ROOT/home/.config" "$HOME/.config" waybar
log "[WAYBAR] waybar setup complete."

# Optionally install nwg-bar and stow its config
if [[ $INSTALL_NWGBAR -eq 1 ]]; then
  if ! pacman -Qi nwg-bar &>/dev/null; then
    log "[NWGBAR] Installing nwg-bar..."
    run_cmd sudo pacman -S --noconfirm nwg-bar
  else
    log "[NWGBAR] nwg-bar is already installed."
  fi
  log "[NWGBAR] Stowing nwg-bar dotfiles to $HOME/.config"
  stow_package "$REPO_ROOT/home/.config" "$HOME/.config" nwg-bar
  log "[NWGBAR] nwg-bar setup complete."
fi
