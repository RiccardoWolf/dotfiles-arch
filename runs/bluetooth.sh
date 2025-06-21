#!/usr/bin/env bash
set -euo pipefail

# Install bluez and blueman for Bluetooth support
sudo pacman -Sy --needed --noconfirm bluez blueman

# Enable and start bluetooth service
enable_service() {
  local service="$1"
  if ! systemctl is-enabled --quiet "$service"; then
    sudo systemctl enable "$service"
  fi
  if ! systemctl is-active --quiet "$service"; then
    sudo systemctl start "$service"
  fi
}

enable_service bluetooth.service

echo "✓ bluez and blueman installed. Bluetooth service enabled and started."
