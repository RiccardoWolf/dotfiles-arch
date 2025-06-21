#!/usr/bin/env bash
set -euo pipefail
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prompt to set sudo timeout to never expire
read -rp "Set sudo timeout to never expire (timestamp_timeout=-1)? [y/N]: " sudo_timeout_reply
if [[ "$sudo_timeout_reply" =~ ^[Yy]$ ]]; then
  echo "Backing up /etc/sudoers to /etc/sudoers.bak.copilot"
  sudo cp /etc/sudoers /etc/sudoers.bak.copilot
  if ! sudo grep -q '^Defaults timestamp_timeout=-1' /etc/sudoers; then
    echo 'Defaults timestamp_timeout=-1' | sudo tee -a /etc/sudoers > /dev/null
  fi
  echo "Validating sudoers file syntax..."
  if sudo visudo -c; then
    echo "✓ Sudo timeout set to never expire."
  else
    echo "✗ Syntax error detected! Restoring backup."
    sudo cp /etc/sudoers.bak.copilot /etc/sudoers
    exit 1
  fi
else
  echo "Skipped modifying sudo timeout."
fi

# Prompt to update archlinux-keyring
read -rp "Update archlinux-keyring? [y/N]: " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
  sudo pacman -Sy --needed --noconfirm archlinux-keyring
fi

# Prompt to replace dolphin with thunar
read -rp "Replace dolphin with thunar? [y/N]: " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
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