#!/usr/bin/env bash
set -euo pipefail

# --- Argument parsing ---
dry_run=0
grep_filter=""
for arg in "$@"; do
  case "$arg" in
    --dry)
      dry_run=1
      ;;
    *)
      grep_filter="$arg"
      ;;
  esac
done

# --- Logging function ---
log() {
  if [[ "$dry_run" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

# --- Script execution logic ---
runs_dir="$PWD/runs"
if [[ -d "$runs_dir" ]]; then
  while IFS= read -r -d '' script; do
    script_name="$(basename "$script")"
    if [[ -n "$grep_filter" && "$script_name" != *$grep_filter* ]]; then
      continue
    fi
    log "Would run: $script_name"
    if [[ "$dry_run" != "1" ]]; then
      "$script"
    fi
  done < <(find "$runs_dir" -type f -executable -print0 | sort -z)
fi

# --- Main logic (to be modularized in future) ---
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo pacman -Sy --needed --noconfirm archlinux-keyring

if [[ -s "$current_dir/packages/pacman.txt" ]]; then
  sudo pacman -Sy --needed --noconfirm - < "$current_dir/packages/pacman.txt"
fi

if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi
if [[ -s "$current_dir/packages/aur.txt" ]]; then
  yay -S --needed --noconfirm - < "$current_dir/packages/aur.txt"
fi

echo "✓ All packages installed."

##
## STOW DOTFILES
##
for dir in "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/rofi" "$HOME/.config/nwg-bar" "/usr/share/sddm/themes/catppuccin-macchiato"; do
  if [[ -d "$dir" ]]; then
    mkdir -p "$HOME/.config/old_configs"
    sudo mv "$dir" "$HOME/.config/old_configs/"
    mkdir -p "$dir"
  fi
  mkdir -p "$dir"
done

stow --verbose --restow --dir=home/.config --target="$HOME/.config/hypr" hypr
stow --verbose --restow --dir=home/.config --target="$HOME/.config/waybar" waybar
stow --verbose --restow --dir=home/.config --target="$HOME/.config/rofi" rofi
stow --verbose --restow --dir=home/.config --target="$HOME/.config/nwg-bar" nwg-bar
stow --verbose --restow --dir=home/.config --target="$HOME/.config/qt6ct" qt6ct

sudo stow --verbose --restow --target=/usr/share/sddm/themes/catppuccin-macchiato catppuccin-macchiato

echo "✓ All configurations deployed."