#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Core
source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/core/checks.sh"

# 🔒 Sécurité : REDRIVA s'exécute uniquement en root
require_root

# 📁 Initialisation de la configuration
redriva_config_init

ACTIONS_DIR="$BASE_DIR/actions"
MENUS_DIR="$BASE_DIR/menus"

#######################################
# ACTIONS
#######################################

redriva_list_actions() {
  ls -1 "$ACTIONS_DIR" 2>/dev/null | sed 's/\.sh$//'
}

redriva_action() {
  local action="$1"
  [[ -z "$action" ]] && error "Action manquante"

  local file="$ACTIONS_DIR/$action.sh"
  [[ ! -f "$file" ]] && error "Action inconnue : $action"

  title "Action : $action"
  bash "$file"
}

#######################################
# MENU
#######################################

redriva_menu() {
  local menu="$MENUS_DIR/main.menu"
  [[ ! -f "$menu" ]] && error "Menu principal manquant"

  while true; do
    clear
    title "REDRIVA — Menu principal"
    parse_menu "$menu"
    read -rp "👉 Choix : " choice

    [[ "$choice" == "0" ]] && exit 0
    run_menu_choice "$choice" "$menu"
    pause
  done
}

parse_menu() {
  local file="$1"
  local i=1

  declare -gA MENU_MAP=()

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^\[.*\]$ ]]; then
      echo ""
      echo "$line"
      continue
    fi

    key="${line%%=*}"
    label="${line#*=}"

    printf "  %s) %s\n" "$i" "$label"
    MENU_MAP["$i"]="$key"
    ((i++))
  done < "$file"

  echo ""
  echo "  0) Quitter"
}

run_menu_choice() {
  local choice="$1"
  local action="${MENU_MAP[$choice]}"

  [[ -z "$action" ]] && error "Choix invalide"
  redriva_action "$action"
}
