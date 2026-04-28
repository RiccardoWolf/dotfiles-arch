#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

# If no arguments, stow all dotfiles in home/.config
if [[ $# -eq 0 ]]; then
  ensure_path_exists "$REPO_ROOT/home/.config"
  mapfile -t DOTFILES < <(find "$REPO_ROOT/home/.config" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
  log "No dotfiles specified. Stowing all: ${DOTFILES[*]}"
else
  DOTFILES=("$@")
fi

for pkg in "${DOTFILES[@]}"; do
  log "Stowing $pkg to $HOME/.config"
  stow_package "$REPO_ROOT/home/.config" "$HOME/.config" "$pkg"

  if [[ "$pkg" == "hypr" ]] && command -v hyprctl &>/dev/null; then
    run_cmd hyprctl reload
  fi

  log "Stowed $pkg."
done
