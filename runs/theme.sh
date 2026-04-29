#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

THEME_BIN_DIR="$REPO_ROOT/home/bin/theme-switch"
THEME_SWITCH="$THEME_BIN_DIR/theme-switch"
DARK_SCRIPT="$THEME_BIN_DIR/dark.sh"
LIGHT_SCRIPT="$THEME_BIN_DIR/light.sh"

ensure_path_exists "$THEME_SWITCH"
ensure_path_exists "$DARK_SCRIPT"
ensure_path_exists "$LIGHT_SCRIPT"
ensure_path_exists "$REPO_ROOT/home/.config/dotfiles-arch/themes"

install_pacman_packages \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  libnotify \
  dunst

log "[THEME] Stowing theme-switch scripts to $HOME/bin"
stow_package "$REPO_ROOT/home/bin" "$HOME/bin" theme-switch
run_cmd "$HOME/bin/theme-switch/theme-switch" prepare dark

for pkg in kitty waybar nwg-bar rofi; do
  log "[THEME] Stowing $pkg dotfiles to $HOME/.config"
  stow_package "$REPO_ROOT/home/.config" "$HOME/.config" "$pkg"
done

run_cmd "$HOME/bin/theme-switch/theme-switch" apply dark

log "[THEME] Theme management setup complete."
