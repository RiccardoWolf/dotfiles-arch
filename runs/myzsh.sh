#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Install zsh if not present
if ! command -v zsh &>/dev/null; then
  log "Installing zsh..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sudo pacman -Sy --needed --noconfirm zsh
  fi
else
  log "zsh is already installed."
fi

# Install oh-my-zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
else
  log "oh-my-zsh is already installed."
fi

# Install oh-my-zsh plugins
declare -A plugins=(
  [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for name in "${!plugins[@]}"; do
  plugin_dir="$ZSH_CUSTOM/plugins/$name"
  if [[ ! -d "$plugin_dir" ]]; then
    log "Installing oh-my-zsh plugin: $name"
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      git clone --depth=1 "${plugins[$name]}" "$plugin_dir"
    fi
  else
    log "Plugin $name already installed."
  fi
done

# Stow new .zshrc from repo (assuming it is in home/)
rc="zshrc"
log "Stowing $rc from repo to $HOME/.${rc}"
if [[ -e "$HOME/.${rc}" ]]; then
  log "$HOME/.${rc} already exists. Removing it before stowing."
  if [[ -d "$HOME/.${rc}" ]]; then
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      find "$HOME/.${rc}" -mindepth 1 -delete
    fi
  else
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      rm -f "$HOME/.${rc}"
    fi
  fi
fi
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  stow --verbose --restow --dir=home --target="$HOME" "$rc"
fi
log "Stowed $rc."

# Set zsh as the default shell
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    log "Setting zsh as the default shell with chsh."
    chsh -s "$(command -v zsh)"
  else
    log "zsh is already the default shell."
  fi
else
  log "[DRY_RUN]: Would set zsh as the default shell with chsh."
fi
