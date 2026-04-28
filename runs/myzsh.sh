#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

# Install zsh if not present
if ! command -v zsh &>/dev/null; then
  log "Installing zsh..."
  run_cmd sudo pacman -Sy --needed --noconfirm zsh
else
  log "zsh is already installed."
fi

# Install oh-my-zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh..."
  if is_dry_run; then
    log "Would download and run oh-my-zsh installer."
  else
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
    run_cmd git clone --depth=1 "${plugins[$name]}" "$plugin_dir"
  else
    log "Plugin $name already installed."
  fi
done

# Stow new .zshrc from repo (assuming it is in home/)
rc="zshrc"
log "Stowing $rc from repo to $HOME"
stow_package "$REPO_ROOT/home" "$HOME" "$rc" "$HOME/.zshrc"
log "Stowed $rc."

# Set zsh as the default shell
if command -v zsh &>/dev/null && [[ "$SHELL" != "$(command -v zsh)" ]]; then
  log "Setting zsh as the default shell with chsh."
  run_cmd chsh -s "$(command -v zsh)"
else
  log "zsh is already the default shell or is not available yet."
fi
