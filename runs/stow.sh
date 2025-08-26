#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# If no arguments, stow all dotfiles in home/.config
if [[ $# -eq 0 ]]; then
  mapfile -t DOTFILES < <(ls -1 "$(dirname "$0")/../home/.config" | grep -v '^\.')
  log "No dotfiles specified. Stowing all: ${DOTFILES[*]}"
else
  DOTFILES=("$@")
fi

for pkg in "${DOTFILES[@]}"; do
  target="$HOME/.config/$pkg"
  log "Stowing $pkg to $target"
  if [[ -e "$target" ]]; then
    log "$target already exists. Removing it before stowing."
    if [[ -d "$target" && "$target" != "xdg-open" ]]; then
      if [[ "${DRY_RUN:-0}" != "1" ]]; then
        find "$target" -mindepth 1 -delete
      fi
    else
      if [[ "${DRY_RUN:-0}" != "1" ]]; then
        rm -f "$target"
      fi
    fi
  fi
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    stow --verbose --restow --dir=home/.config --target="$target" "$pkg"
    hyprctl reload
  fi
  log "Stowed $pkg."
done
