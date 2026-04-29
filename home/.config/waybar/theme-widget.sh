#!/usr/bin/env bash
set -uo pipefail

COMMAND="${1:-status}"
THEME_SWITCH="${THEME_WIDGET_THEME_SWITCH:-$HOME/bin/theme-switch/theme-switch}"

log() {
  printf 'theme-widget: %s\n' "$*" >&2
}

notify() {
  local message="$1"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Theme" "$message"
  else
    log "$message"
  fi
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

waybar_json() {
  local text="$1"
  local class="$2"
  local tooltip="$3"

  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$(json_escape "$text")" \
    "$(json_escape "$class")" \
    "$(json_escape "$tooltip")"
}

theme_switch_available() {
  [[ -x "$THEME_SWITCH" ]]
}

current_theme() {
  theme_switch_available || return 127
  "$THEME_SWITCH" current 2>/dev/null
}

status() {
  local mode

  if ! mode="$(current_theme)"; then
    waybar_json "theme" "theme-unavailable" "theme-switch is not installed"
    return 0
  fi

  case "$mode" in
    dark)
      waybar_json "dark" "theme-dark" "Theme: dark\nClick to switch to light"
      ;;
    light)
      waybar_json "light" "theme-light" "Theme: light\nClick to switch to dark"
      ;;
    *)
      waybar_json "theme" "theme-unavailable" "Unknown theme state: $mode"
      ;;
  esac
}

toggle() {
  if ! theme_switch_available; then
    notify "theme-switch is not installed"
    status
    return 0
  fi

  if ! "$THEME_SWITCH" toggle >/dev/null 2>&1; then
    notify "Theme toggle failed"
    status
    return 1
  fi

  status
}

case "$COMMAND" in
  status)
    status
    ;;
  toggle)
    toggle
    ;;
  *)
    log "unknown command: $COMMAND"
    status
    exit 1
    ;;
esac
