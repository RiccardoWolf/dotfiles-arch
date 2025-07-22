#!/usr/bin/env bash
set -euo pipefail

CATEGORY="${1:-base}"

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Function to extract packages by category (e solo quelli fuori da ogni categoria, cioè solo quelli PRIMA della prima sezione)
extract_pkgs() {
  local file="$1"
  local category="$2"
  if [[ -z "$category" ]]; then
    # Nessuna categoria: estrai solo i pacchetti prima della prima sezione
    awk '/^# / {exit} NF && $1 !~ /^#/ {print $1}' "$file"
  else
    awk -v cat="$category" '
      BEGIN {in_cat=0; cat_tol=tolower(cat)}
      # Sezione di categoria
      /^# / {
        if (tolower($0) ~ "#.*"cat_tol) {in_cat=1; next} else {in_cat=0; next}
      }
      in_cat && NF && $1 !~ /^#/ {print $1}
    ' "$file"
  fi
}

# Funzione per unire e deduplicare pacchetti
join_and_dedupe() {
  awk '!seen[$0]++' <(printf "%s\n" "$@")
}

PACMAN_FILE="$(dirname "$0")/../packages/pacman.txt"
AUR_FILE="$(dirname "$0")/../packages/aur.txt"

# Parse pacman packages
if [[ -f "$PACMAN_FILE" ]]; then
  always_pkgs=$(extract_pkgs "$PACMAN_FILE" "ALWAYS INSTALL")
  category_pkgs=$(extract_pkgs "$PACMAN_FILE" "$CATEGORY")
  pacman_pkgs=$(join_and_dedupe $always_pkgs $category_pkgs)
else
  pacman_pkgs=""
fi

if [[ -z "$pacman_pkgs" ]]; then
  log "No pacman packages found for category '$CATEGORY'."
else
  missing_pacman_pkgs=()
  for pkg in $pacman_pkgs; do
    if pacman -Qi "$pkg" &>/dev/null; then
      log "[PACMAN] $pkg is already installed."
    else
      log "[PACMAN] $pkg is missing. Will install."
      missing_pacman_pkgs+=("$pkg")
    fi
  done
  if [[ ${#missing_pacman_pkgs[@]} -gt 0 ]]; then
    log "Installing missing pacman packages: ${missing_pacman_pkgs[*]}"
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      sudo pacman -Sy --needed --noconfirm "${missing_pacman_pkgs[@]}"
    fi
    log "Pacman packages installation complete."
  else
    log "All pacman packages are already installed."
  fi
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

# Parse AUR packages
if [[ -f "$AUR_FILE" && -s "$AUR_FILE" ]]; then
  always_aur_pkgs=$(extract_pkgs "$AUR_FILE" "ALWAYS INSTALL")
  category_aur_pkgs=$(extract_pkgs "$AUR_FILE" "$CATEGORY")
  aur_pkgs=$(join_and_dedupe $always_aur_pkgs $category_aur_pkgs)
else
  aur_pkgs=""
fi

if [[ -z "$aur_pkgs" ]]; then
  log "No AUR packages found for category '$CATEGORY'."
else
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
fi
