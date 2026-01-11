#!/usr/bin/env bash
# Action REDRIVA — Vérification Auth Traefik

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/app_engine.sh"
source "$BASE_DIR/modules/app_traefik.sh"

title "Application — Vérification Auth"

APP_SELECTED="${1:-}"

#######################################
# Sélection application
#######################################
if [[ -n "$APP_SELECTED" ]]; then
  app_load_conf "$APP_SELECTED" || error "Application invalide"
else
  mapfile -t APPS < <(app_list)
  [[ "${#APPS[@]}" -eq 0 ]] && error "Aucune application disponible"

  echo "Applications disponibles :"
  echo ""

  i=1
  for app in "${APPS[@]}"; do
    unset APP_NAME APP_DESCRIPTION
    app_load_conf "$app" || continue
    printf " %2d) %-15s — %s\n" "$i" "$APP_NAME" "$APP_DESCRIPTION"
    ((i++))
  done

  echo ""
  read -rp "👉 Choix de l'application : " choice
  (( choice < 1 || choice > ${#APPS[@]} )) && error "Choix invalide"

  APP_SELECTED="${APPS[$((choice - 1))]}"
  app_load_conf "$APP_SELECTED"
fi

#######################################
# Vérification
#######################################
if app_traefik_has_middleware "$APP_SELECTED" "auth-basic@file"; then
  success "Auth Traefik activée pour $APP_NAME"
else
  info "Aucune authentification active pour $APP_NAME"
fi
