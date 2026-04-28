#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

hypr_input_config="$REPO_ROOT/home/.config/hypr/sources/input.conf"
colorpicker_bind='bind = $mainMod SHIFT, C, exec, hyprpicker --f=hex --render-inactive -a -l'

install_pacman_packages hyprpicker wl-clipboard

ensure_path_exists "$hypr_input_config"

if grep -Fxq "$colorpicker_bind" "$hypr_input_config"; then
  log "Hyprland color picker bind is configured: SUPER+SHIFT+C runs hyprpicker."
else
  log "Hyprland input config exists at $hypr_input_config, but the expected bind was not found."
  log "Expected bind: $colorpicker_bind"
fi

log "Color picker setup complete."
