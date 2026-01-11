#!/usr/bin/env bash
# Action REDRIVA — Redémarrage application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "Application — Redémarrage"

mapfile -t APPS < <(app_list)
[[ "${#APPS[@]}" -eq 0 ]] && error "Aucune application disponible"

i=1
for app in "${APPS[@]}"; do
  unset APP_NAME APP_DESCRIPTION
  app_load_conf "$app" || continue
  printf " %2d) %-15s — %s\n" "$i" "$APP_NAME" "$APP_DESCRIPTION"
  ((i++))
done

read -rp "👉 Choix de l'application : " choice
(( choice < 1 || choice > ${#APPS[@]} )) && error "Choix invalide"

APP_SELECTED="${APPS[$((choice - 1))]}"
TARGET_DIR="$(app_target_dir "$APP_SELECTED")"

info "Redémarrage de l'application…"
(
  cd "$TARGET_DIR"
  docker compose restart
)

success "Application redémarrée"
