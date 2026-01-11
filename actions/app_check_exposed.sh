#!/usr/bin/env bash
# Action REDRIVA — Vérification exposition HTTPS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "Application — Vérification exposition HTTPS"

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
# Vérification exposition
#######################################
APP_DOMAIN="$(render_domain "$APP_DEFAULT_DOMAIN")"

info "Test HTTPS : https://$APP_DOMAIN"

if curl -sk --max-time 5 "https://$APP_DOMAIN" >/dev/null; then
  success "Application accessible en HTTPS"
else
  error "Application non accessible (HTTPS)"
fi
