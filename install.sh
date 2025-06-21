#!/usr/bin/env bash
set -euo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read -rp "Update archlinux-keyring? [y/N]: " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
  sudo pacman -Sy --needed --noconfirm archlinux-keyring
fi

read -rp "Replace dolphin with thunar? [Y/n]: " reply
if [[ "$reply" =~ ^([Yy]|)$ ]]; then
  if pacman -Qs dolphin &>/dev/null; then
    sudo pacman -Rns --noconfirm dolphin
  fi
  sudo pacman -Sy --needed --noconfirm thunar gvfs thunar-volman
  echo "✓ Dolphin replaced with Thunar."
else
  echo "Skipped replacing dolphin."
fi

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
  # Usa ls e grep per trovare il primo script eseguibile che corrisponde
  match_script=""
  match_script=$(ls "$current_dir/runs/" | grep -E "^$arg(\\.sh)?" | head -n1 || true)
  if [[ -n "$match_script" && -x "$current_dir/runs/$match_script" ]]; then
    if [[ -n "${current_group[*]:-}" ]]; then
      run_groups+=("${current_group[*]}")
    fi
    current_group=()
    current_group+=("$match_script")
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

echo "✓ All configurations deployed."