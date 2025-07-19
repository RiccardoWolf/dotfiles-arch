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

# --- Help message ---
show_help() {
  cat <<EOF
NAME
    install.sh - Dotfiles Arch setup & automation script

SYNOPSIS
    $0 [--dry] [--help] [run_script [args ...]]

DESCRIPTION
    Interactive script to configure an Arch Linux system and run modular scripts from the 'runs/' directory.
    At startup, it may prompt for system actions (sudo timeout, keyring update, dolphin replacement).
    You can specify one or more scripts to run, with optional arguments, which will be searched in the 'runs/' directory.

OPTIONS
    --dry
        Simulate actions without making changes (dry run).
    --help
        Show this help message and exit.

SCRIPT EXECUTION LOGIC
    run_script [args ...]
        Each argument is checked against the available scripts in 'runs/'.
        If a match is found (e.g. 'base' or 'base.sh'), it is treated as a script to execute.
        All following arguments that do not match another script name are passed as arguments to that script.
        If another script name is found, a new execution group starts.
        Limitation: if an argument has the same name as a script, it will be interpreted as a new script, not as an argument.
        Example:
            $0 base arg1 arg2 bluetooth arg3
            # Runs 'runs/base.sh arg1 arg2' then 'runs/bluetooth.sh arg3'

AVAILABLE RUN SCRIPTS
    base           Install all base packages listed in packages/pacman.txt under the BASE section.
    bluetooth      Installs bluez and blueman, enables and starts the bluetooth service.
    git            Configures global git username/email and generates an SSH key if missing (and adds it to ssh-agent). Prompts for username/email.
    grub           Installs os-prober and enables it in grub config. Then installs grub catppuccin theme.
    kitty          Stows kitty config to $HOME/.config/kitty.
    myzsh          Installs zsh and oh-my-zsh if missing. And stows config.
    rofi-wayland   Installs rofi-wayland and stows its config.
    sddm           Installs dependencies for the Catppuccin SDDM theme.
    stow [PKG...]  Stows dotfiles from home/.config to $HOME/.config. If no arguments, stows all. If arguments are given, only those dotfiles are stowed.
    waybar [nwgbar] Installs waybar and stows its config. If 'nwgbar' is passed as argument, also installs nwg-bar.

EXAMPLES
    $0 --help
        Show this help message.
    $0 --dry base
        Simulate running 'runs/base.sh' without making changes.
    $0 base bluetooth grub
        Run 'runs/base.sh', then 'runs/bluetooth.sh', then 'runs/grub.sh'.
    $0 git
        Configure git (will prompt for username and email).
    $0 stow kitty waybar
        Stow only 'kitty' and 'waybar' dotfiles.
    $0 waybar nwgbar
        Install waybar and also install nwg-bar.

EOF
}

# --- Argument parsing ---
# Prima passata: estrai --dry ovunque si trovi
args=()
dry_run=0
for arg in "$@"; do
  if [[ "$arg" == "--dry" ]]; then
    dry_run=1
  else
    args+=("$arg")
  fi
done

# Check for --help come primo argomento rimasto
if [[ "${args[0]:-}" == "--help" ]]; then
  show_help
  exit 0
fi

# Special handling for stow: se presente, solo stow viene eseguito e tutti gli argomenti successivi vengono passati a lui
run_groups=()
if [[ "${#args[@]}" -gt 0 ]]; then
  for ((idx=0; idx<${#args[@]}; idx++)); do
    arg="${args[$idx]}"
    if [[ "$arg" == "stow" || "$arg" == "stow.sh" ]]; then
      stow_args=("${args[@]:$((idx+1))}")
      run_groups=("stow.sh ${stow_args[*]}")
      break
    fi
  done
fi

# If stow was not found, proceed with normal parsing
# Get all available run scripts (without .sh extension)
mapfile -t all_runs < <(ls "$current_dir/runs/" | grep -E '\.sh$' | sed 's/\.sh$//')

if [[ ${#run_groups[@]} -eq 0 ]]; then
  declare -a current_group=()
  for arg in "${args[@]}"; do
    match_script=""
    for run in "${all_runs[@]}"; do
      if [[ "$arg" == "$run" || "$arg" == "$run.sh" ]]; then
        match_script="$run.sh"
        break
      fi
    done
    if [[ -n "$match_script" && -x "$current_dir/runs/$match_script" ]]; then
      if [[ ${#current_group[@]} -gt 0 ]]; then
        run_groups+=("${current_group[*]}")
      fi
      current_group=()
      current_group+=("$match_script")
    else
      current_group+=("$arg")
    fi
  done
  if [[ ${#current_group[@]} -gt 0 ]]; then
    run_groups+=("${current_group[*]}")
  fi
fi

# If no runs specified, run all except stow
if [[ ${#run_groups[@]} -eq 0 ]]; then
  for run in "${all_runs[@]}"; do
    if [[ "$run" != "stow" ]]; then
      run_groups+=("$run.sh")
    fi
  done
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