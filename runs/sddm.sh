#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Install dependencies for catppuccin SDDM theme
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

# Install Catppuccin SDDM theme from GitHub releases
THEME_NAME="catppuccin-macchiato"
THEME_DEST="/usr/share/sddm/themes/$THEME_NAME"
GITHUB_REPO="catppuccin/sddm"
TMP_DIR="/tmp/catppuccin-sddm-theme"

if [[ ! -d "$THEME_DEST" ]]; then
  log "Fetching latest Catppuccin SDDM theme release from GitHub..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"
    # Get latest release download URL for the theme zip
    RELEASE_URL=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep browser_download_url | grep -E 'zip|tar.gz' | grep -i macchiato | cut -d '"' -f4 | head -n1)
    if [[ -z "$RELEASE_URL" ]]; then
      echo "Could not find Catppuccin Macchiato SDDM theme release URL." >&2
      exit 1
    fi
    log "Downloading $RELEASE_URL..."
    cd "$TMP_DIR"
    if [[ "$RELEASE_URL" == *.zip ]]; then
      curl -L -o theme.zip "$RELEASE_URL"
      unzip theme.zip
    else
      curl -L -o theme.tar.gz "$RELEASE_URL"
      tar -xzf theme.tar.gz
    fi
    # Find the extracted theme directory
    EXTRACTED_DIR=$(find . -type d -name "$THEME_NAME" | head -n1)
    if [[ -z "$EXTRACTED_DIR" ]]; then
      echo "Could not find extracted theme directory." >&2
      exit 1
    fi
    sudo mkdir -p "$THEME_DEST"
    sudo cp -r "$EXTRACTED_DIR"/* "$THEME_DEST/"
    cd - >/dev/null
    rm -rf "$TMP_DIR"
  fi
  log "Catppuccin SDDM theme installed to $THEME_DEST."
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
