#!/usr/bin/env bash
# Action REDRIVA — Vérification Auth Application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "Application — Vérification Auth"

#######################################
# Sélection app
#######################################
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
app_load_conf "$APP_SELECTED"

TARGET_DIR="$(app_target_dir "$APP_SELECTED")"
COMPOSE_FILE="$TARGET_DIR/docker-compose.yml"

#######################################
# Vérification middleware
#######################################
info "Vérification middleware auth…"

if grep -q 'middlewares=.*auth' "$COMPOSE_FILE"; then
  success "Middleware auth détecté"
else
  error "Aucun middleware auth appliqué à l'application"
fi

#######################################
# Test HTTP
#######################################
APP_DOMAIN="$(render_domain "$APP_DEFAULT_DOMAIN")"

info "Test HTTPS (sans auth) : https://$APP_DOMAIN"

CODE="$(curl -sk -o /dev/null -w "%{http_code}" "https://$APP_DOMAIN")"

if [[ "$CODE" == "401" || "$CODE" == "403" ]]; then
  success "Accès protégé (HTTP $CODE)"
else
  error "Application accessible sans auth (HTTP $CODE)"
fi
