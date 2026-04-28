#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

printing_packages=(
  cups
  cups-filters
  cups-pdf
  avahi
  nss-mdns
  ipp-usb
  system-config-printer
  cups-pk-helper
)

enable_and_start_service() {
  local service="$1"

  if is_dry_run; then
    log "Would enable and start $service."
    return 0
  fi

  if ! systemctl is-enabled --quiet "$service"; then
    run_cmd sudo systemctl enable "$service"
  else
    log "$service is already enabled."
  fi

  if ! systemctl is-active --quiet "$service"; then
    run_cmd sudo systemctl start "$service"
  else
    log "$service is already active."
  fi
}

install_pacman_packages "${printing_packages[@]}"

enable_and_start_service cups.service
enable_and_start_service avahi-daemon.service
enable_and_start_service ipp-usb.service

log "Printer setup complete: CUPS, Avahi/mDNS, and IPP-over-USB packages are installed."
log "Check /etc/nsswitch.conf manually for mDNS discovery; the hosts line should include: mdns_minimal [NOTFOUND=return]"
