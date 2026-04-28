#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

# Set up git config
read -rp "Enter your git username: " git_user
read -rp "Enter your git email: " git_email

log "Configuring git with username '$git_user' and email '$git_email'"
run_cmd git config --global user.name "$git_user"
run_cmd git config --global user.email "$git_email"

# Generate SSH key if not present
if [[ ! -f "$HOME/.ssh/gitssh" ]]; then
  log "Generating new SSH key..."
  run_cmd mkdir -p "$HOME/.ssh"
  run_cmd ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/gitssh" -N ""
  if ! is_dry_run; then
    xclip -selection clipboard < "$HOME/.ssh/gitssh.pub"
    log "SSH key generated and copied to clipboard. Please add it to your GitHub account."
  fi
else
  run_cmd xclip -selection clipboard "$HOME/.ssh/gitssh.pub"
  log "SSH key already exists and copied to clipboard. Please ensure it is added to your GitHub account."
fi

# Add SSH key to agent
log "Adding SSH key to ssh-agent."
if ! is_dry_run; then
  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/gitssh"
else
  log "Would start ssh-agent and add $HOME/.ssh/gitssh."
fi
log "Git and SSH setup complete."
