#!/usr/bin/env bash

RUNS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$RUNS_DIR/.." && pwd -P)"

is_dry_run() {
  [[ "${DRY_RUN:-0}" == "1" ]]
}

log() {
  if is_dry_run; then
    echo "[DRY_RUN]: $*"
  else
    echo "$*"
  fi
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

run_cmd() {
  if is_dry_run; then
    log "Would run: $(printf '%q ' "$@")"
  else
    log "Running: $(printf '%q ' "$@")"
    "$@"
  fi
}

ensure_path_exists() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || die "Required path not found: $path"
}

pacman_installed() {
  pacman -Qi "$1" &>/dev/null
}

install_pacman_packages() {
  local -a missing=()
  local pkg

  for pkg in "$@"; do
    if pacman_installed "$pkg"; then
      log "$pkg is already installed."
    else
      log "$pkg is missing. Will install."
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    run_cmd sudo pacman -Sy --needed --noconfirm "${missing[@]}"
  fi
}

ensure_yay() {
  if command -v yay &>/dev/null; then
    log "yay is already installed."
    return 0
  fi

  log "yay not found. Installing yay from AUR."
  run_cmd rm -rf /tmp/yay
  run_cmd git clone https://aur.archlinux.org/yay.git /tmp/yay
  if is_dry_run; then
    log "Would build and install yay from /tmp/yay."
  else
    (cd /tmp/yay && makepkg -si --noconfirm)
  fi
}

backup_existing_target() {
  local target="$1"
  local source_path="${2:-}"
  local backup_base backup_path suffix

  [[ -e "$target" || -L "$target" ]] || return 0

  if [[ -n "$source_path" && -L "$target" ]]; then
    local target_real source_real
    target_real="$(readlink -f -- "$target" 2>/dev/null || true)"
    source_real="$(readlink -f -- "$source_path" 2>/dev/null || true)"
    if [[ -n "$target_real" && "$target_real" == "$source_real" ]]; then
      log "$target already points to $source_path."
      return 0
    fi
  fi

  backup_base="${target}.backup.$(date +%Y%m%d%H%M%S)"
  backup_path="$backup_base"
  suffix=1
  while [[ -e "$backup_path" || -L "$backup_path" ]]; do
    backup_path="${backup_base}.${suffix}"
    suffix=$((suffix + 1))
  done

  log "Backing up existing $target to $backup_path"
  run_cmd mv -- "$target" "$backup_path"
}

stow_package() {
  local stow_dir="$1"
  local target_dir="$2"
  local package="$3"
  local target_path="${4:-$target_dir/$package}"
  local source_path="$stow_dir/$package"
  local expected_target="$source_path"
  local default_target="$target_dir/$package"

  command -v stow &>/dev/null || die "stow command not found. Install stow before stowing dotfiles."
  ensure_path_exists "$source_path"
  if [[ -f "$source_path/$(basename -- "$target_path")" ]]; then
    expected_target="$source_path/$(basename -- "$target_path")"
  fi

  if [[ ! -d "$target_dir" ]]; then
    run_cmd mkdir -p -- "$target_dir"
  fi

  backup_existing_target "$target_path" "$expected_target"
  if [[ "$target_path" == "$default_target" && -d "$source_path" ]]; then
    if [[ -e "$target_path" || -L "$target_path" ]]; then
      local target_real source_real
      target_real="$(readlink -f -- "$target_path" 2>/dev/null || true)"
      source_real="$(readlink -f -- "$source_path" 2>/dev/null || true)"
      if [[ -n "$target_real" && "$target_real" == "$source_real" ]]; then
        return 0
      fi
      if ! is_dry_run; then
        die "Target still exists after backup attempt: $target_path"
      fi
    fi
    run_cmd ln -s --relative -- "$source_path" "$target_path"
    return 0
  fi

  run_cmd stow --verbose --restow --dir="$stow_dir" --target="$target_dir" "$package"
}
