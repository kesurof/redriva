#!/usr/bin/env bash
# Action REDRIVA — Suppression Auth Traefik

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "Application — Suppression Auth Traefik"

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
# Confirmation (interactif uniquement)
#######################################
if [[ -z "${1:-}" ]]; then
  read -rp "❓ Supprimer l'authentification ? [y/N] : " confirm
  [[ "$confirm" =~ ^[yY]$ ]] || { info "Action annulée"; exit 0; }
fi

#######################################
# Suppression
#######################################
info "Suppression du middleware auth-basic"

app_traefik_remove_middleware "$APP_SELECTED" "auth-basic@file"

success "Authentification supprimée pour $APP_NAME"
