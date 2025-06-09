#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo pacman -Sy --needed --noconfirm archlinux-keyring

if [[ -s "$repo_dir/packages/pacman.txt" ]]; then
  sudo pacman -Sy --needed --noconfirm - < "$repo_dir/packages/pacman.txt"
fi

if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi
if [[ -s "$repo_dir/packages/aur.txt" ]]; then
  yay -S --needed --noconfirm - < "$repo_dir/packages/aur.txt"
fi

if ! command -v stow &>/dev/null; then
  sudo pacman -Sy --needed --noconfirm stow
fi
cd "$repo_dir"

stow --verbose --restow --target="$HOME" home

sudo stow --verbose --restow --target=/ system

echo "✓ All packages installed and configurations deployed."