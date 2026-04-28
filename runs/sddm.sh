#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

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
  run_cmd sudo pacman -Sy --needed --noconfirm "${missing_pkgs[@]}"
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
  run_cmd rm -rf "$TMP_DIR"
  run_cmd mkdir -p "$TMP_DIR"
  if ! is_dry_run; then
    # Get latest release download URL for the theme zip
    RELEASE_URL=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep browser_download_url | grep -E 'zip|tar.gz' | grep -i macchiato | cut -d '"' -f4 | head -n1 || true)
    if [[ -z "$RELEASE_URL" ]]; then
      echo "Could not find Catppuccin Macchiato SDDM theme release URL." >&2
      exit 1
    fi
    log "Downloading $RELEASE_URL..."
    if [[ "$RELEASE_URL" == *.zip ]]; then
      curl -L -o "$TMP_DIR/theme.zip" "$RELEASE_URL"
      unzip "$TMP_DIR/theme.zip" -d "$TMP_DIR"
    else
      curl -L -o "$TMP_DIR/theme.tar.gz" "$RELEASE_URL"
      tar -xzf "$TMP_DIR/theme.tar.gz" -C "$TMP_DIR"
    fi
    EXTRACTED_DIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 2 -type f -name theme.conf -printf '%h\n' | grep -i macchiato | head -n1 || true)
    if [[ -z "$EXTRACTED_DIR" || ! -d "$EXTRACTED_DIR" ]]; then
      echo "Could not find extracted theme directory." >&2
      exit 1
    fi
    run_cmd sudo mkdir -p "$THEME_DEST"
    run_cmd sudo cp -r "$EXTRACTED_DIR"/. "$THEME_DEST/"
  fi
  run_cmd rm -rf "$TMP_DIR"
  log "Catppuccin SDDM theme installed to $THEME_DEST."
else
  log "Catppuccin SDDM theme already present."
fi

# Set SDDM theme in /etc/sddm.conf.d/catppuccin.conf
CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="$CONF_DIR/catppuccin.conf"
CONF_CONTENT=$'[Theme]\nCurrent=catppuccin-macchiato\n'
if is_dry_run; then
  log "Would ensure SDDM theme is configured in $CONF_FILE."
elif [[ -f "$CONF_FILE" ]] && [[ "$(sudo cat "$CONF_FILE")"$'\n' == "$CONF_CONTENT" ]]; then
  log "SDDM theme is already configured in $CONF_FILE."
else
  log "Setting SDDM theme in $CONF_FILE..."
  run_cmd sudo mkdir -p "$CONF_DIR"
  printf '%s' "$CONF_CONTENT" | sudo tee "$CONF_FILE" > /dev/null
fi
log "SDDM Catppuccin theme setup complete."
