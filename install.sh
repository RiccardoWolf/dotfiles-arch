#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNS_DIR="$REPO_ROOT/runs"
DRY_RUN=0
MENU=0

# --- Help message ---
show_help() {
  cat <<EOF
NAME
    install.sh - Dotfiles Arch setup & automation script

SYNOPSIS
    $0 [--dry] [--menu] [--help] [run_script [args ...]]

DESCRIPTION
    Interactive script to configure an Arch Linux system and run modular scripts from the 'runs/' directory.
    At startup, it may prompt for system actions (sudo timeout, keyring update, dolphin replacement).
    You can specify one or more scripts to run, with optional arguments, which will be searched in the 'runs/' directory.

OPTIONS
    --dry
        Simulate actions without making changes (dry run).
    --menu
        Open an fzf task picker instead of passing task names as command arguments.
    --help
        Show this help message and exit.

SCRIPT EXECUTION LOGIC
    run_script [args ...]
        Each argument is checked against the available scripts in 'runs/'.
        If a match is found (e.g. 'pkg' or 'pkg.sh'), it is treated as a script to execute.
        All following arguments that do not match another script name are passed as arguments to that script.
        If another script name is found, a new execution group starts.
        Special case: stow consumes all following arguments as dotfile names.
        Limitation: if an argument has the same name as a script, it will be interpreted as a new script, not as an argument.
        Example:
            $0 pkg BASE bluetooth
            # Runs 'runs/pkg.sh BASE' then 'runs/bluetooth.sh'

AVAILABLE RUN SCRIPTS
    pkg [PKG_CATEGORY...] Install packages from package-list.txt. If no category is given, installs all listed packages.
    bluetooth             Installs bluez and blueman, enables and starts the bluetooth service.
    git                   Configures global git username/email and generates an SSH key if missing (and adds it to ssh-agent). Prompts for username/email.
    grub                  Installs os-prober and enables it in grub config. Then installs grub catppuccin theme.
    myzsh                 Installs zsh and oh-my-zsh if missing. And stows config.
    rofi-wayland          Installs rofi-wayland and stows its config.
    sddm                  Installs dependencies for the Catppuccin SDDM theme.
    stow [PKG...]         Stows dotfiles from home/.config to $HOME/.config. If no arguments, stows all. If arguments are given, only those dotfiles are stowed.
    waybar [nwgbar]       Installs waybar and stows its config. If 'nwgbar' is passed as argument, also installs nwg-bar.

EXAMPLES
    $0 --help
        Show this help message.
    $0 --dry pkg BASE
        Simulate running 'runs/pkg.sh BASE' without making changes.
    $0 --menu
        Select tasks interactively with fzf.
    $0 pkg BASE bluetooth grub
        Run 'runs/pkg.sh', then 'runs/bluetooth.sh', then 'runs/grub.sh'.
    $0 git
        Configure git (will prompt for username and email).
    $0 stow rofi waybar
        Stow only 'rofi' and 'waybar' dotfiles.
    $0 waybar nwgbar
        Install waybar and also install nwg-bar.

EOF
}

# --- Argument parsing ---
args=()
for arg in "$@"; do
  case "$arg" in
    --dry)
      DRY_RUN=1
      ;;
    --menu)
      MENU=1
      ;;
    --help)
      show_help
      exit 0
      ;;
    --*)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
    *)
      args+=("$arg")
      ;;
  esac
done

export REPO_ROOT RUNS_DIR DRY_RUN

log() {
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

run_command() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "Would run: $*"
  else
    "$@"
  fi
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

# --- Script execution plan ---
if [[ ! -d "$RUNS_DIR" ]]; then
  echo "Runs directory not found: $RUNS_DIR" >&2
  exit 1
fi

declare -A run_scripts=()
mapfile -t all_runs < <(find "$RUNS_DIR" -maxdepth 1 -type f -name '*.sh' ! -name 'lib.sh' -printf '%f\n' | sort)
for script_name in "${all_runs[@]}"; do
  run_scripts["${script_name%.sh}"]="$script_name"
  run_scripts["$script_name"]="$script_name"
done

preferred_default_runs=(
  pkg.sh
  bluetooth.sh
  git.sh
  grub.sh
  myzsh.sh
  rofi-wayland.sh
  sddm.sh
  waybar.sh
)

default_runs=()
for script_name in "${preferred_default_runs[@]}"; do
  if [[ -n "${run_scripts[$script_name]:-}" ]]; then
    default_runs+=("$script_name")
  fi
done

run_plan=()
queue_script() {
  local script_name="$1"
  shift

  local script_path="$RUNS_DIR/$script_name"
  if [[ ! -e "$script_path" ]]; then
    echo "Unknown run task: $script_name" >&2
    exit 1
  fi
  if [[ ! -x "$script_path" ]]; then
    echo "Run task is not executable: $script_name" >&2
    exit 1
  fi

  run_plan+=("$script_name" "$#" "$@")
}

ensure_fzf() {
  if command -v fzf &>/dev/null; then
    return 0
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "Would run: sudo pacman -Sy --needed --noconfirm fzf"
    die "fzf is required for --menu, but it is not installed. Install fzf or run without --dry to auto-install it."
  fi

  command -v pacman &>/dev/null || die "fzf is required for --menu and pacman is not available to auto-install it."
  run_command sudo pacman -Sy --needed --noconfirm fzf
  command -v fzf &>/dev/null || die "fzf install completed, but fzf is still not available in PATH."
}

fzf_select_many() {
  local prompt="$1"
  shift
  local selection status

  [[ $# -gt 0 ]] || return 1

  set +e
  selection="$(
    printf '%s\n' "$@" |
      fzf --multi --no-sort --height=70% --border --prompt="$prompt" \
        --header="Tab selects multiple entries. Enter confirms."
  )"
  status=$?
  set -e

  [[ $status -eq 0 && -n "$selection" ]] || return 1
  mapfile -t FZF_SELECTIONS <<< "$selection"
}

fzf_confirm() {
  local prompt="$1"
  local selection status

  FZF_CONFIRM_CANCELLED=0
  set +e
  selection="$(
    printf '%s\n' yes no |
      fzf --no-sort --height=40% --border --prompt="$prompt" \
        --header="Enter confirms the highlighted choice."
  )"
  status=$?
  set -e

  if [[ $status -ne 0 ]]; then
    FZF_CONFIRM_CANCELLED=1
    return 1
  fi

  [[ $status -eq 0 && "$selection" == "yes" ]]
}

package_categories() {
  local package_file="$REPO_ROOT/package-list.txt"
  [[ -f "$package_file" ]] || return 0
  awk '/^# / {sub(/^#[[:space:]]*/, ""); print}' "$package_file"
}

dotfile_packages() {
  local config_dir="$REPO_ROOT/home/.config"
  [[ -d "$config_dir" ]] || return 0
  find "$config_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

queue_menu_task() {
  local task_name="$1"
  local -a choices=()

  case "$task_name" in
    pkg)
      mapfile -t choices < <(package_categories)
      if [[ ${#choices[@]} -eq 0 ]]; then
        queue_script "pkg.sh"
      elif fzf_select_many "Package categories> " all "${choices[@]}"; then
        choices=("${FZF_SELECTIONS[@]}")
        if [[ " ${choices[*]} " == *" all "* ]]; then
          queue_script "pkg.sh"
        else
          queue_script "pkg.sh" "${choices[@]}"
        fi
      else
        echo "Skipped pkg."
      fi
      ;;
    stow)
      mapfile -t choices < <(dotfile_packages)
      if [[ ${#choices[@]} -eq 0 ]]; then
        queue_script "stow.sh"
      elif fzf_select_many "Dotfiles> " all "${choices[@]}"; then
        choices=("${FZF_SELECTIONS[@]}")
        if [[ " ${choices[*]} " == *" all "* ]]; then
          queue_script "stow.sh"
        else
          queue_script "stow.sh" "${choices[@]}"
        fi
      else
        echo "Skipped stow."
      fi
      ;;
    waybar)
      if fzf_confirm "Install nwg-bar too? "; then
        queue_script "waybar.sh" nwgbar
      elif [[ ${FZF_CONFIRM_CANCELLED:-0} != "1" ]]; then
        queue_script "waybar.sh"
      else
        echo "Skipped waybar."
      fi
      ;;
    *)
      queue_script "${run_scripts[$task_name]}"
      ;;
  esac
}

build_menu_plan() {
  local -a task_names=()
  local -a selected_tasks=()
  local script_name

  ensure_fzf

  for script_name in "${all_runs[@]}"; do
    [[ -x "$RUNS_DIR/$script_name" ]] || continue
    task_names+=("${script_name%.sh}")
  done

  if ! fzf_select_many "Tasks> " "${task_names[@]}"; then
    echo "No tasks selected."
    exit 0
  fi

  selected_tasks=("${FZF_SELECTIONS[@]}")
  for task_name in "${selected_tasks[@]}"; do
    queue_menu_task "$task_name"
  done
}

if [[ "$MENU" == "1" && ${#args[@]} -gt 0 ]]; then
  die "--menu cannot be combined with run task arguments."
fi

if [[ "$MENU" == "1" ]]; then
  build_menu_plan
elif [[ ${#args[@]} -eq 0 ]]; then
  for script_name in "${default_runs[@]}"; do
    queue_script "$script_name"
  done
else
  current_script=""
  current_args=()

  for ((idx=0; idx<${#args[@]}; idx++)); do
    arg="${args[$idx]}"
    if [[ "$arg" == "stow" || "$arg" == "stow.sh" ]]; then
      if [[ -n "$current_script" ]]; then
        queue_script "$current_script" "${current_args[@]}"
      fi
      stow_args=("${args[@]:$((idx + 1))}")
      queue_script "stow.sh" "${stow_args[@]}"
      current_script=""
      current_args=()
      break
    fi

    if [[ -n "${run_scripts[$arg]:-}" ]]; then
      if [[ -n "$current_script" ]]; then
        queue_script "$current_script" "${current_args[@]}"
      fi
      current_script="${run_scripts[$arg]}"
      current_args=()
    elif [[ -z "$current_script" ]]; then
      echo "Unknown run task: $arg" >&2
      exit 1
    else
      current_args+=("$arg")
    fi
  done

  if [[ -n "$current_script" ]]; then
    queue_script "$current_script" "${current_args[@]}"
  fi
fi

# Prompt to set sudo timeout to never expire
read -rp "Set sudo timeout to never expire (timestamp_timeout=-1)? [y/N]: " sudo_timeout_reply
if [[ "$sudo_timeout_reply" =~ ^[Yy]$ ]]; then
  echo "Backing up /etc/sudoers to /etc/sudoers.bak.copilot"
  run_command sudo cp /etc/sudoers /etc/sudoers.bak.copilot
  if [[ "$DRY_RUN" == "1" ]] || ! sudo grep -q '^Defaults timestamp_timeout=-1' /etc/sudoers; then
    if [[ "$DRY_RUN" == "1" ]]; then
      log "Would append sudoers timestamp_timeout setting"
    else
      echo 'Defaults timestamp_timeout=-1' | sudo tee -a /etc/sudoers > /dev/null
    fi
  fi
  echo "Validating sudoers file syntax..."
  if [[ "$DRY_RUN" == "1" ]] || sudo visudo -c; then
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
  run_command sudo pacman -Sy --needed --noconfirm archlinux-keyring
fi

# Prompt to replace dolphin with thunar
read -rp "Replace dolphin with thunar? [y/N]: " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
  if [[ "$DRY_RUN" == "1" ]]; then
    log "Would check whether dolphin is installed"
  elif pacman -Qs dolphin &>/dev/null; then
    sudo pacman -Rns --noconfirm dolphin
  fi
  run_command sudo pacman -Sy --needed --noconfirm thunar gvfs thunar-volman
  echo "✓ Dolphin replaced with Thunar."
else
  echo "Skipped replacing dolphin."
fi

# --- Script execution logic ---
run_script() {
  local script_name="$1"
  shift

  local script_path="$RUNS_DIR/$script_name"
  if [[ ! -e "$script_path" ]]; then
    echo "Unknown run task: $script_name" >&2
    exit 1
  fi
  if [[ ! -x "$script_path" ]]; then
    echo "Run task is not executable: $script_name" >&2
    exit 1
  fi

  log "Running: $script_name $*"
  if [[ "$DRY_RUN" == "1" ]]; then
    DRY_RUN=1 "$script_path" "$@"
  else
    "$script_path" "$@"
  fi
}

plan_idx=0
while [[ $plan_idx -lt ${#run_plan[@]} ]]; do
  script_name="${run_plan[$plan_idx]}"
  ((plan_idx += 1))
  arg_count="${run_plan[$plan_idx]}"
  ((plan_idx += 1))
  script_args=("${run_plan[@]:$plan_idx:$arg_count}")
  ((plan_idx += arg_count))

  run_script "$script_name" "${script_args[@]}"
done

echo "✓ All configurations deployed."
