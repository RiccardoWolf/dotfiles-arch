#!/usr/bin/env bash
set -euo pipefail

log() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# Install os-prober and enable it in grub config
if ! pacman -Qi os-prober &>/dev/null; then
  log "Installing os-prober..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sudo pacman -Sy --needed --noconfirm os-prober
  fi
else
  log "os-prober is already installed."
fi

# Enable os-prober in /etc/default/grub
if grep -q '^#*GRUB_DISABLE_OS_PROBER=' /etc/default/grub; then
  log "Enabling os-prober in /etc/default/grub..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sudo sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
  fi
else
  log "Adding GRUB_DISABLE_OS_PROBER=false to /etc/default/grub..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub
  fi
fi

# Install Catppuccin GRUB theme
THEME_DIR="/boot/grub/themes/catppuccin-macchiato-grub-theme"
if [[ ! -d "$THEME_DIR" ]]; then
  log "Installing Catppuccin GRUB theme..."
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    git clone --depth=1 https://github.com/catppuccin/grub.git /tmp/catppuccin-grub
    sudo mkdir -p "$THEME_DIR"
    sudo cp -r /tmp/catppuccin-grub/src/catppuccin-macchiato-grub-theme/* "$THEME_DIR/"
    # Imposta il tema GRUB aggiungendo la riga alla fine del file di configurazione
    echo 'GRUB_THEME=/boot/grub/themes/catppuccin-macchiato-grub-theme/theme.txt' | sudo tee -a /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    rm -rf /tmp/catppuccin-grub
  fi
  log "Catppuccin GRUB theme installed."
else
  log "Catppuccin GRUB theme already present."
fi
