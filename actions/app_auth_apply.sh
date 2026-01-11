#!/usr/bin/env bash
# Action REDRIVA — Application Auth Traefik (Basic)
# Mode interactif OU scriptable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "Application — Activation Auth Traefik"

#######################################
# Mode non-interactif
#######################################
APP_SELECTED="${1:-}"
APP_DOMAIN="${2:-}"

#######################################
# Sélection application
#######################################
if [[ -n "$APP_SELECTED" ]]; then
  app_load_conf "$APP_SELECTED" || error "Application invalide : $APP_SELECTED"
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
# Domaine
#######################################
if [[ -z "$APP_DOMAIN" ]]; then
  APP_DOMAIN="$(render_domain "$APP_DEFAULT_DOMAIN")" \
    || error "Impossible de déterminer le domaine"
fi

#######################################
# Confirmation (uniquement interactif)
#######################################
if [[ -z "${1:-}" ]]; then
  echo ""
  echo "Application : $APP_NAME"
  echo "Domaine     : $APP_DOMAIN"
  echo ""
  read -rp "❓ Appliquer l'authentification ? [y/N] : " confirm
  [[ "$confirm" =~ ^[yY]$ ]] || { info "Action annulée"; exit 0; }
fi

#######################################
# Application Auth (label Traefik)
#######################################
info "Application du middleware auth-basic sur $APP_DOMAIN"

app_traefik_apply_middleware "$APP_SELECTED" "auth-basic@file"

success "Authentification Traefik activée pour $APP_DOMAIN"
