#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Parse base packages from packages/pacman.txt
base_pkgs=$(awk '/# BASE/{flag=1;next}/^#/{flag=0}flag && NF && $1 !~ /^#/{print $1}' "$(dirname "$0")/../packages/pacman.txt")

if [[ -z "$base_pkgs" ]]; then
  log "No base packages found."
  exit 1
fi

missing_base_pkgs=()
for pkg in $base_pkgs; do
  if pacman -Qi "$pkg" &>/dev/null; then
    log "[BASE] $pkg is already installed."
  else
    log "[BASE] $pkg is missing. Will install."
    missing_base_pkgs+=("$pkg")
  fi
done

if [[ ${#missing_base_pkgs[@]} -gt 0 ]]; then
  log "Installing missing base packages: ${missing_base_pkgs[*]}"
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sudo pacman -Sy --needed --noconfirm "${missing_base_pkgs[@]}"
  fi
  log "Base packages installation complete."
else
  log "All base packages are already installed."
fi

# Ensure yay is installed
if ! command -v yay &>/dev/null; then
  log "yay not found. Installing yay from AUR."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
  fi
  log "yay installation complete."
else
  log "yay is already installed."
fi

# Install AUR packages from packages/aur.txt
AUR_FILE="$(dirname "$0")/../packages/aur.txt"
if [[ -s "$AUR_FILE" ]]; then
  aur_pkgs=$(awk 'NF && $1 !~ /^#/{print $1}' "$AUR_FILE")
  missing_aur_pkgs=()
  for pkg in $aur_pkgs; do
    if yay -Qi "$pkg" &>/dev/null; then
      log "[AUR] $pkg is already installed."
    else
      log "[AUR] $pkg is missing. Will install."
      missing_aur_pkgs+=("$pkg")
    fi
  done
  if [[ ${#missing_aur_pkgs[@]} -gt 0 ]]; then
    log "Installing missing AUR packages: ${missing_aur_pkgs[*]}"
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      yay -S --needed --noconfirm "${missing_aur_pkgs[@]}"
    fi
    log "AUR packages installation complete."
  else
    log "All AUR packages are already installed."
  fi
else
  log "AUR package list file not found or empty."
fi
