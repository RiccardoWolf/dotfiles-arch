#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Install dependencies
pkgs=(qt6-svg qt6-declarative qt5-quickcontrols2)
missing_pkgs=()
for pkg in "${pkgs[@]}"; do
  if pacman -Qi "$pkg" &>/dev/null; then
    log "$pkg already installed."
  else
    log "$pkg missing. Will install."
    missing_pkgs+=("$pkg")
  fi
done
if [[ ${#missing_pkgs[@]} -gt 0 ]]; then
  log "Installing missing dependencies: ${missing_pkgs[*]}"
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sudo pacman -Sy --needed --noconfirm "${missing_pkgs[@]}"
  fi
else
  log "All dependencies already installed."
fi

# Install Catppuccin SDDM theme
THEME_SRC="$(dirname "$0")/../themes/catppuccin-macchiato-sddm"
THEME_DEST="/usr/share/sddm/themes/catppuccin-macchiato"
if [[ ! -d "$THEME_DEST" ]]; then
  log "Copying Catppuccin SDDM theme to $THEME_DEST..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sudo mkdir -p "$THEME_DEST"
    sudo cp -r "$THEME_SRC"/* "$THEME_DEST/"
  fi
else
  log "Catppuccin SDDM theme already present."
fi

# Set SDDM theme in /etc/sddm.conf.d/catppuccin.conf
CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="$CONF_DIR/catppuccin.conf"
log "Setting SDDM theme in $CONF_FILE..."
if [[ "${DRY_RUN:-0}" != "1" ]]; then
  sudo mkdir -p "$CONF_DIR"
  echo -e "[Theme]\nCurrent=catppuccin-macchiato" | sudo tee "$CONF_FILE" > /dev/null
fi
log "SDDM Catppuccin theme setup complete."
