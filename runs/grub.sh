#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

grub_changed=0

# Install os-prober and enable it in grub config
if ! pacman -Qi os-prober &>/dev/null; then
  log "Installing os-prober..."
  run_cmd sudo pacman -Sy --needed --noconfirm os-prober
  grub_changed=1
else
  log "os-prober is already installed."
fi

# Enable os-prober in /etc/default/grub
if grep -Fxq 'GRUB_DISABLE_OS_PROBER=false' /etc/default/grub; then
  log "os-prober is already enabled in /etc/default/grub."
elif grep -q '^#*GRUB_DISABLE_OS_PROBER=' /etc/default/grub; then
  log "Enabling os-prober in /etc/default/grub..."
  run_cmd sudo sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
  grub_changed=1
else
  log "Adding GRUB_DISABLE_OS_PROBER=false to /etc/default/grub..."
  run_cmd sudo sh -c "printf '%s\n' 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub"
  grub_changed=1
fi

# Install Catppuccin GRUB theme
THEME_DIR="/boot/grub/themes/catppuccin-macchiato-grub-theme"
THEME_LINE="GRUB_THEME=/boot/grub/themes/catppuccin-macchiato-grub-theme/theme.txt"
if [[ ! -d "$THEME_DIR" ]]; then
  log "Installing Catppuccin GRUB theme..."
  run_cmd rm -rf /tmp/catppuccin-grub
  run_cmd git clone --depth=1 https://github.com/catppuccin/grub.git /tmp/catppuccin-grub
  run_cmd sudo mkdir -p "$THEME_DIR"
  run_cmd sudo cp -r /tmp/catppuccin-grub/src/catppuccin-macchiato-grub-theme/. "$THEME_DIR/"
  run_cmd rm -rf /tmp/catppuccin-grub
  log "Catppuccin GRUB theme installed."
  grub_changed=1
else
  log "Catppuccin GRUB theme already present."
fi

if grep -q '^#*GRUB_THEME=' /etc/default/grub; then
  if grep -Fxq "$THEME_LINE" /etc/default/grub; then
    log "GRUB theme is already configured."
  else
    log "Updating GRUB theme in /etc/default/grub..."
    run_cmd sudo sed -i "s|^#*GRUB_THEME=.*|${THEME_LINE}|" /etc/default/grub
    grub_changed=1
  fi
else
  log "Adding GRUB theme to /etc/default/grub..."
  run_cmd sudo sh -c "printf '%s\n' '$THEME_LINE' >> /etc/default/grub"
  grub_changed=1
fi

if [[ "$grub_changed" == "1" ]]; then
  run_cmd sudo grub-mkconfig -o /boot/grub/grub.cfg
else
  log "GRUB configuration already up to date."
fi
