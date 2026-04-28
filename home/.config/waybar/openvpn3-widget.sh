#!/usr/bin/env bash
set -uo pipefail

COMMAND="${1:-status}"

log() {
  printf 'openvpn3-widget: %s\n' "$*" >&2
}

notify() {
  local message="$1"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "OpenVPN" "$message"
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

require_openvpn3() {
  command -v openvpn3 >/dev/null 2>&1
}

configs_json_output() {
  openvpn3 configs-list --json 2>/dev/null || true
}

sessions_json_output() {
  openvpn3 sessions-list --json 2>/dev/null || true
}

configs_output() {
  openvpn3 configs-list 2>/dev/null || true
}

sessions_output() {
  openvpn3 sessions-list 2>/dev/null || true
}

parse_config_names() {
  awk '
    BEGIN { found_name_lines = 0 }
    /^[[:space:]]*Name:[[:space:]]*/ {
      name = $0
      sub(/^[[:space:]]*Name:[[:space:]]*/, "", name)
      if (name != "") {
        print name
        found_name_lines = 1
      }
      next
    }
    { lines[++line_count] = $0 }
    END {
      if (found_name_lines) {
        exit
      }

      for (i = 1; i <= line_count; i++) {
        line = lines[i]
        if (line ~ /^[[:space:]]*$/ || line ~ /^-+$/ || line ~ /Configuration[[:space:]]+Name/) {
          continue
        }
        if (line !~ /^\/net\/openvpn\/v3\/configuration\//) {
          split(line, simple_fields, /[[:space:]]+/)
          if (simple_fields[1] != "") {
            print simple_fields[1]
          }
          continue
        }

        sub(/[[:space:]]+$/, "", line)
        count = split(line, fields, /[[:space:]][[:space:]]+/)
        if (count >= 2 && fields[count] != "") {
          print fields[count]
        }
      }
    }
  '
}

parse_active_config_names() {
  awk '
    /^[[:space:]]*(Config|Configuration)[[:space:]]+name:[[:space:]]*/ {
      name = $0
      sub(/^[[:space:]]*(Config|Configuration)[[:space:]]+name:[[:space:]]*/, "", name)
      if (name != "") {
        print name
      }
      next
    }
    /^\/net\/openvpn\/v3\/sessions\// {
      sub(/[[:space:]]+$/, "", $0)
      count = split($0, fields, /[[:space:]][[:space:]]+/)
      if (count >= 2 && fields[count] != "") {
        print fields[count]
      }
    }
  '
}

parse_config_names_json() {
  jq -r '
    [
      .. | objects |
      .name? //
      .Name? //
      .config_name? //
      .configuration_name? //
      ."Configuration Name"? //
      empty
    ] | .[] | strings
  ' 2>/dev/null
}

parse_active_config_names_json() {
  jq -r '
    [
      .. | objects |
      .config_name? //
      .configuration_name? //
      .configurationName? //
      ."Configuration Name"? //
      ."Config name"? //
      empty
    ] | .[] | strings
  ' 2>/dev/null
}

read_configs() {
  if command -v jq >/dev/null 2>&1; then
    mapfile -t CONFIGS < <(configs_json_output | parse_config_names_json | awk 'NF && !seen[$0]++')
  else
    CONFIGS=()
  fi

  if ((${#CONFIGS[@]} == 0)); then
    mapfile -t CONFIGS < <(configs_output | parse_config_names | awk 'NF && !seen[$0]++')
  fi
}

read_active_configs() {
  if command -v jq >/dev/null 2>&1; then
    mapfile -t ACTIVE_CONFIGS < <(sessions_json_output | parse_active_config_names_json | awk 'NF && !seen[$0]++')
  else
    ACTIVE_CONFIGS=()
  fi

  if ((${#ACTIVE_CONFIGS[@]} == 0)); then
    mapfile -t ACTIVE_CONFIGS < <(sessions_output | parse_active_config_names | awk 'NF && !seen[$0]++')
  fi
}

is_active() {
  local profile="$1"
  local active

  for active in "${ACTIVE_CONFIGS[@]:-}"; do
    [[ "$active" == "$profile" ]] && return 0
  done

  return 1
}

status() {
  if ! require_openvpn3; then
    waybar_json "VPN -" "vpn-unavailable" "OpenVPN 3 CLI is not installed"
    return 0
  fi

  read_configs
  if ((${#CONFIGS[@]} == 0)); then
    waybar_json "VPN -" "vpn-disconnected" "No OpenVPN 3 profiles imported"
    return 0
  fi

  read_active_configs
  if ((${#ACTIVE_CONFIGS[@]} > 0)); then
    local active_text
    printf -v active_text '%s, ' "${ACTIVE_CONFIGS[@]}"
    active_text="${active_text%, }"
    waybar_json "VPN on" "vpn-connected" "Connected: ${active_text}"
    return 0
  fi

  waybar_json "VPN off" "vpn-disconnected" "Imported profiles: ${#CONFIGS[@]}"
}

toggle() {
  if ! require_openvpn3; then
    notify "OpenVPN 3 CLI is not installed."
    return 1
  fi

  if ! command -v rofi >/dev/null 2>&1; then
    notify "rofi is not installed; cannot choose an OpenVPN profile."
    return 1
  fi

  read_configs
  if ((${#CONFIGS[@]} == 0)); then
    notify "No OpenVPN 3 profiles imported."
    return 1
  fi

  read_active_configs

  local menu=""
  local profile state menu_line selected selected_profile=""
  for profile in "${CONFIGS[@]}"; do
    if is_active "$profile"; then
      state="connected"
    else
      state="disconnected"
    fi
    menu+="${profile} (${state})"$'\n'
  done

  selected="$(printf '%s' "$menu" | rofi -dmenu -i -p "OpenVPN" || true)"
  [[ -z "$selected" ]] && return 0

  for profile in "${CONFIGS[@]}"; do
    if is_active "$profile"; then
      state="connected"
    else
      state="disconnected"
    fi

    menu_line="${profile} (${state})"
    if [[ "$selected" == "$menu_line" ]]; then
      selected_profile="$profile"
      break
    fi
  done

  if [[ -z "$selected_profile" ]]; then
    notify "Unknown OpenVPN profile selection."
    return 1
  fi

  if is_active "$selected_profile"; then
    if openvpn3 session-manage --config "$selected_profile" --disconnect; then
      notify "Disconnected ${selected_profile}."
    else
      notify "Failed to disconnect ${selected_profile}."
      return 1
    fi
  else
    if openvpn3 session-start --config "$selected_profile"; then
      notify "Connected ${selected_profile}."
    else
      notify "Failed to connect ${selected_profile}."
      return 1
    fi
  fi
}

case "$COMMAND" in
  status)
    status
    ;;
  toggle)
    toggle
    ;;
  *)
    log "usage: $0 {status|toggle}"
    exit 2
    ;;
esac
