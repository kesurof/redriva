#!/usr/bin/env bash

CONFIG_DIR="/etc/redriva"
CONFIG_FILE="$CONFIG_DIR/config"

redriva_config_init() {
  mkdir -p "$CONFIG_DIR"
  chmod 700 "$CONFIG_DIR"

  touch "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"
}

config_get() {
  grep -E "^$1=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2- | tr -d '"'
}

config_set() {
  local key="$1"
  local val="$2"

  if grep -q "^$key=" "$CONFIG_FILE" 2>/dev/null; then
    sed -i "s|^$key=.*|$key=\"$val\"|" "$CONFIG_FILE"
  else
    echo "$key=\"$val\"" >> "$CONFIG_FILE"
  fi
}

#######################################
# UI config helpers (interaction contrôlée)
#######################################

mask_secret() {
  local v="$1"
  local l=${#v}

  if (( l <= 8 )); then
    echo "********"
  else
    echo "${v:0:4}*****${v: -4}"
  fi
}

ask_value() {
  local key="$1"
  local label="$2"
  local sensitive="$3"

  local current
  current="$(config_get "$key")"

  if [[ -n "$current" ]]; then
    if [[ "$sensitive" == "yes" ]]; then
      info "$label : $(mask_secret "$current")"
    else
      info "$label : $current"
    fi

    read -rp "❓ Modifier cette valeur ? [y/N] : " r
    [[ "$r" =~ ^[yY]$ ]] || return 0
  fi

  if [[ "$sensitive" == "yes" ]]; then
    read -rsp "👉 $label : " new
    echo ""
  else
    read -rp "👉 $label : " new
  fi

  config_set "$key" "$new"
}
