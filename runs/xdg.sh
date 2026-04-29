#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

applications_source_dir="$REPO_ROOT/home/.local/share/applications"
applications_target_dir="$HOME/.local/share/applications"
chrome_launcher_source="$REPO_ROOT/home/bin/google-chrome-live"
chrome_launcher_target="$HOME/bin/google-chrome-live"
thunar_launcher_source="$REPO_ROOT/home/bin/thunar-themed"
thunar_launcher_target="$HOME/bin/thunar-themed"

ensure_path_exists "$applications_source_dir"
ensure_path_exists "$chrome_launcher_source"
ensure_path_exists "$thunar_launcher_source"

install_pacman_packages xdg-utils desktop-file-utils glib2

if [[ ! -d "$applications_target_dir" ]]; then
  run_cmd mkdir -p -- "$applications_target_dir"
fi

install_user_bin() {
  local source_path="$1"
  local target_path="$2"
  local target_real source_real

  if [[ ! -d "$(dirname -- "$target_path")" ]]; then
    run_cmd mkdir -p -- "$(dirname -- "$target_path")"
  fi

  if [[ -L "$target_path" ]]; then
    target_real="$(readlink -f -- "$target_path" 2>/dev/null || true)"
    source_real="$(readlink -f -- "$source_path" 2>/dev/null || true)"
    if [[ "$target_real" != "$source_real" ]]; then
      die "Refusing to replace existing symlink with different target: $target_path"
    fi
  else
    if [[ -f "$target_path" ]] && cmp -s -- "$source_path" "$target_path"; then
      log "$target_path is already up to date."
    else
      backup_existing_target "$target_path" "$source_path"
      log "Installing $(basename -- "$source_path") to $(dirname -- "$target_path")."
      run_cmd install -m 0755 -- "$source_path" "$target_path"
    fi
  fi
}

install_user_bin "$chrome_launcher_source" "$chrome_launcher_target"
install_user_bin "$thunar_launcher_source" "$thunar_launcher_target"

shopt -s nullglob
desktop_files=("$applications_source_dir"/*.desktop)
shopt -u nullglob

if [[ ${#desktop_files[@]} -eq 0 ]]; then
  die "No desktop files found in $applications_source_dir"
fi

for desktop_file in "${desktop_files[@]}"; do
  desktop_name="$(basename -- "$desktop_file")"
  log "Installing $desktop_name to $applications_target_dir."
  run_cmd install -m 0644 -- "$desktop_file" "$applications_target_dir/$desktop_name"
done

if is_dry_run; then
  log "Would run: update-desktop-database $(printf '%q' "$applications_target_dir")"
elif command -v update-desktop-database &>/dev/null; then
  run_cmd update-desktop-database "$applications_target_dir"
else
  die "update-desktop-database is not available after installing desktop-file-utils."
fi

set_mime_default() {
  local desktop_file="$1"
  shift

  local mime_type
  for mime_type in "$@"; do
    run_cmd xdg-mime default "$desktop_file" "$mime_type"
  done
}

browser_desktop="google-chrome.desktop"
file_manager_desktop="thunar.desktop"
image_desktop="imv.desktop"
text_desktop="nvim.desktop"
media_desktop="vlc.desktop"

run_cmd xdg-settings set default-web-browser "$browser_desktop"
set_mime_default "$browser_desktop" \
  x-scheme-handler/http \
  x-scheme-handler/https \
  application/pdf

set_mime_default "$file_manager_desktop" \
  inode/directory

set_mime_default "$image_desktop" \
  image/jpeg \
  image/png \
  image/gif \
  image/bmp \
  image/svg+xml

set_mime_default "$text_desktop" \
  text/plain \
  text/x-markdown \
  text/x-python \
  application/javascript \
  text/javascript \
  text/x-typescript \
  text/jsx \
  text/x-java-source \
  text/x-ruby \
  text/x-go \
  application/x-shellscript \
  text/x-c \
  text/x-c++src \
  text/x-chdr \
  text/x-csrc \
  text/x-rust \
  application/x-php \
  text/html \
  text/csv

set_mime_default "$media_desktop" \
  video/mp4 \
  audio/mpeg

log "XDG desktop applications and MIME defaults configured."
