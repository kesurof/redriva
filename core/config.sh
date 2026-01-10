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
