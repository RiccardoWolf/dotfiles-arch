log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Stow kitty config
log "Stowing kitty config to $HOME/.config/kitty"
if [[ -d "$HOME/.config/kitty" ]]; then
  log "$HOME/.config/kitty already exists. Removing its contents before stowing."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    find "$HOME/.config/kitty" -mindepth 1 -delete
  fi
fi
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  stow --verbose --restow --dir=home/.config --target="$HOME/.config/kitty" kitty
fi
log "Stowed kitty config."
