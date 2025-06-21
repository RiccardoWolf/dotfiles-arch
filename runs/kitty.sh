# Stow kitty config
log "Stowing kitty config to $HOME/.config/kitty"
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  stow --verbose --restow --dir=home/.config --target="$HOME/.config/kitty" kitty
fi
log "Stowed kitty config."
