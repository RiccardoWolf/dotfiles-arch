#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

PACKAGE_FILE="$REPO_ROOT/package-list.txt"
categories=("$@")
if [[ ${#categories[@]} -eq 0 ]]; then
  categories=(all)
fi

extract_pkgs() {
  local file="$1"
  local category="$2"

  if [[ "$category" == "all" ]]; then
    awk 'NF && $1 !~ /^#/ {print $1}' "$file"
  else
    awk -v cat="$category" '
      BEGIN {in_cat=0; wanted=tolower(cat)}
      /^# / {
        heading=tolower($0)
        sub(/^#[[:space:]]*/, "", heading)
        in_cat=(heading == wanted)
        next
      }
      in_cat && NF && $1 !~ /^#/ {print $1}
    ' "$file"
  fi
}

package_in_sync_db() {
  pacman -Si "$1" &>/dev/null
}

ensure_path_exists "$PACKAGE_FILE"

mapfile -t packages < <(
  for category in "${categories[@]}"; do
    extract_pkgs "$PACKAGE_FILE" "$category"
  done | awk '!seen[$0]++'
)
if [[ ${#packages[@]} -eq 0 ]]; then
  die "No packages found for categories '${categories[*]}' in $PACKAGE_FILE"
fi

pacman_pkgs=()
aur_pkgs=()
for pkg in "${packages[@]}"; do
  if package_in_sync_db "$pkg"; then
    pacman_pkgs+=("$pkg")
  else
    aur_pkgs+=("$pkg")
  fi
done

if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
  log "Checking pacman packages: ${pacman_pkgs[*]}"
  install_pacman_packages "${pacman_pkgs[@]}"
else
  log "No pacman packages found for categories '${categories[*]}'."
fi

if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
  ensure_yay

  missing_aur_pkgs=()
  for pkg in "${aur_pkgs[@]}"; do
    if command -v yay &>/dev/null && yay -Qi "$pkg" &>/dev/null; then
      log "[AUR] $pkg is already installed."
    else
      log "[AUR] $pkg is missing. Will install."
      missing_aur_pkgs+=("$pkg")
    fi
  done

  if [[ ${#missing_aur_pkgs[@]} -gt 0 ]]; then
    run_cmd yay -S --needed --noconfirm "${missing_aur_pkgs[@]}"
  fi
else
  log "No AUR packages found for categories '${categories[*]}'."
fi
