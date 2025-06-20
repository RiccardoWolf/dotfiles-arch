#!/usr/bin/env bash
set -euo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo pacman -Sy --needed --noconfirm archlinux-keyring
# --- Argument parsing ---
dry_run=0
declare -a run_groups=()
declare -a current_group=()
parsing_first=1
for arg in "$@"; do
  if [[ "$parsing_first" == "1" && "$arg" == "--dry" ]]; then
    dry_run=1
    continue
  fi
  parsing_first=0
  # Se è uno script valido, inizia un nuovo gruppo
  if [[ -f "$current_dir/runs/$arg" && -x "$current_dir/runs/$arg" ]]; then
    if [[ -n "${current_group[*]:-}" ]]; then
      run_groups+=("${current_group[*]}")
    fi
    current_group=()
    current_group+=("$arg")
  else
    current_group+=("$arg")
  fi
done
if [[ -n "${current_group[*]:-}" ]]; then
  run_groups+=("${current_group[*]}")
fi

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
  for group in "${run_groups[@]}"; do
    IFS=' ' read -r -a parts <<< "$group"
    script_name="${parts[0]}"
    script_path="$runs_dir/$script_name"
    script_args=("${parts[@]:1}")
    if [[ -f "$script_path" && -x "$script_path" ]]; then
      log "Would run: $script_name ${script_args[*]}"
      if [[ "$dry_run" != "1" ]]; then
        "$script_path" "${script_args[@]}"
      fi
    else
      log "Script not found or not executable: $script_name"
    fi
  done
fi

# --- Main logic (to be modularized in future) ---
#
#if [[ -s "$current_dir/packages/pacman.txt" ]]; then
#  sudo pacman -Sy --needed --noconfirm - < "$current_dir/packages/pacman.txt"
#fi
#
#if ! command -v yay &>/dev/null; then
#  git clone https://aur.archlinux.org/yay.git /tmp/yay
#  (cd /tmp/yay && makepkg -si --noconfirm)
#fi
#if [[ -s "$current_dir/packages/aur.txt" ]]; then
#  yay -S --needed --noconfirm - < "$current_dir/packages/aur.txt"
#fi
#
#echo "✓ All packages installed."
#
###
### STOW DOTFILES
###
#for dir in "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/rofi" "$HOME/.config/nwg-bar" "/usr/share/sddm/themes/catppuccin-macchiato"; do
#  if [[ -d "$dir" ]]; then
#    mkdir -p "$HOME/.config/old_configs"
#    sudo mv "$dir" "$HOME/.config/old_configs/"
#    mkdir -p "$dir"
#  fi
#  mkdir -p "$dir"
#done
#
#stow --verbose --restow --dir=home/.config --target="$HOME/.config/hypr" hypr
#stow --verbose --restow --dir=home/.config --target="$HOME/.config/waybar" waybar
#stow --verbose --restow --dir=home/.config --target="$HOME/.config/rofi" rofi
#stow --verbose --restow --dir=home/.config --target="$HOME/.config/nwg-bar" nwg-bar
#stow --verbose --restow --dir=home/.config --target="$HOME/.config/qt6ct" qt6ct
#
#sudo stow --verbose --restow --target=/usr/share/sddm/themes/catppuccin-macchiato catppuccin-macchiato
#
echo "✓ All configurations deployed."