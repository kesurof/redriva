#!/usr/bin/env bash
# Action REDRIVA — Application Auth sur une application
#
# Action EFFECTRICE volontaire :
# - ajoute le middleware auth-basic@file
# - modifie docker-compose.yml applicatif
# - redémarre l'application
#
# ❌ ne crée PAS l'auth Traefik
# ❌ ne vérifie PAS Traefik
# ✅ suppose traefik_auth_deploy déjà exécuté

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "Application — Application Auth (Basic)"

#######################################
# Sélection de l'application
#######################################
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

if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#APPS[@]} )); then
  error "Choix invalide"
fi

APP_SELECTED="${APPS[$((choice - 1))]}"
app_load_conf "$APP_SELECTED"

TARGET_DIR="$(app_target_dir "$APP_SELECTED")"
COMPOSE_FILE="$TARGET_DIR/docker-compose.yml"

#######################################
# Vérifications préalables
#######################################
[[ ! -f "$COMPOSE_FILE" ]] && error "docker-compose.yml introuvable"

info "Application : $APP_NAME"
info "Fichier     : $COMPOSE_FILE"

#######################################
# Détection auth existante
#######################################
if grep -q 'middlewares=.*auth-basic@file' "$COMPOSE_FILE"; then
  success "Auth déjà appliquée à cette application"
  exit 0
fi

#######################################
# Confirmation utilisateur
#######################################
echo ""
echo "⚠️  ACTION EFFECTRICE"
echo "Cette action va :"
echo " - appliquer le middleware auth-basic@file"
echo " - modifier docker-compose.yml"
echo " - redémarrer l'application"
echo ""

read -rp "❓ Continuer ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Action annulée par l'utilisateur"
  exit 0
}

#######################################
# Application du middleware
#######################################
info "Application du middleware auth…"

# On ajoute le middleware sur le router existant
sed -i "/traefik.http.routers.${APP_NAME}\./{
  /middlewares=/!{
    s|$|\\n      - \"traefik.http.routers.${APP_NAME}.middlewares=auth-basic@file\"|
  }
}" "$COMPOSE_FILE"

#######################################
# Redémarrage application
#######################################
info "Redémarrage de l'application…"
(
  cd "$TARGET_DIR"
  docker compose up -d
)

#######################################
# Fin
#######################################
success "Auth appliquée à l'application '$APP_NAME'"
info "L'accès HTTPS est maintenant protégé par authentification"
