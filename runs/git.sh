#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Set up git config
read -rp "Enter your git username: " git_user
read -rp "Enter your git email: " git_email

log "Configuring git with username '$git_user' and email '$git_email'"
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  git config --global user.name "$git_user"
  git config --global user.email "$git_email"
fi

# Generate SSH key if not present
if [[ ! -f "$HOME/.ssh/gitssh" ]]; then
  log "Generating new SSH key..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/gitssh" -N ""
  fi
else
  log "SSH key already exists."
fi

# Add SSH key to agent
log "Adding SSH key to ssh-agent."
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/gitssh"
fi
log "Git and SSH setup complete."
