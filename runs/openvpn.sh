#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

install_openvpn3() {
  if pacman_installed openvpn3; then
    log "openvpn3 is already installed."
    return 0
  fi

  ensure_yay
  log "Installing openvpn3 from AUR with yay."
  run_cmd yay -S --needed --noconfirm openvpn3
}

install_pacman_packages jq libnotify
install_openvpn3

if is_dry_run; then
  log "Would verify the openvpn3 command is available."
elif ! command -v openvpn3 &>/dev/null; then
  die "openvpn3 package install completed, but the openvpn3 command is not available in PATH."
fi

log "OpenVPN 3 setup complete."
log "Import a profile: openvpn3 config-import --config Brandon.ovpn --name <MY_CONFIG_NAME> --persistent"
log "List profiles: openvpn3 configs-list"
log "Start a session: openvpn3 session-start --config <MY_CONFIG_NAME>"
log "List sessions: openvpn3 sessions-list"
log "Disconnect: openvpn3 session-manage --config <MY_CONFIG_NAME> --disconnect"
