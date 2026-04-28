#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

# Install bluez and blueman for Bluetooth support
install_pacman_packages bluez blueman

# Enable and start bluetooth service
enable_service() {
  local service="$1"
  if ! systemctl is-enabled --quiet "$service"; then
    run_cmd sudo systemctl enable "$service"
  fi
  if ! systemctl is-active --quiet "$service"; then
    run_cmd sudo systemctl start "$service"
  fi
}

enable_service bluetooth.service

log "bluez and blueman installed. Bluetooth service enabled and started."
