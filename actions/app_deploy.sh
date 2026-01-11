#!/usr/bin/env bash
# Action REDRIVA — Déploiement applicatif générique
# Orchestration humaine autour du moteur app_engine
#
# ⚠️ Action effectrice, volontaire, rejouable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/app_engine.sh"
source "$BASE_DIR/modules/user_identity.sh"

title "Applications — Déploiement"

#######################################
# Identité runtime (PUID / PGID)
#######################################
if ! user_identity_check; then
  error "Identité runtime non configurée — exécute redriva_configure_identity"
fi

export PUID="$(user_identity_get_uid)"
export PGID="$(user_identity_get_gid)"

info "Identité runtime : UID=$PUID / GID=$PGID"

#######################################
# Liste des applications disponibles
#######################################
mapfile -t APPS < <(app_list)

[[ "${#APPS[@]}" -eq 0 ]] && error "Aucune application disponible"

echo "Applications disponibles :"
echo ""

i=1
for app in "${APPS[@]}"; do
  unset APP_NAME APP_DESCRIPTION APP_DEFAULT_DOMAIN
  app_load_conf "$app" || continue
  printf " %2d) %-15s — %s\n" "$i" "$APP_NAME" "$APP_DESCRIPTION"
  ((i++))
done

echo ""
read -rp "👉 Choix de l'application : " choice
(( choice < 1 || choice > ${#APPS[@]} )) && error "Choix invalide"

APP_SELECTED="${APPS[$((choice - 1))]}"

#######################################
# Chargement configuration app
#######################################
unset APP_NAME APP_DESCRIPTION APP_DEFAULT_DOMAIN APP_DOMAIN
app_load_conf "$APP_SELECTED" || error "Impossible de charger l'app"

info "Application sélectionnée : $APP_NAME"

#######################################
# Domaine
#######################################
CF_DOMAIN="$(config_get CF_DOMAIN)"
[[ -z "$CF_DOMAIN" ]] && error "CF_DOMAIN non défini"

export CF_DOMAIN

APP_DOMAIN="$(render_domain "$APP_DEFAULT_DOMAIN")" \
  || error "Impossible de déterminer le domaine"

info "Domaine par défaut : $APP_DOMAIN"
read -rp "👉 Modifier le domaine ? [y/N] : " change_domain
[[ "$change_domain" =~ ^[yY]$ ]] && read -rp "👉 Nouveau domaine : " APP_DOMAIN

#######################################
# Choix authentification
#######################################
echo ""
echo "Type d'authentification :"
echo "  1) Aucune"
echo "  2) Auth Traefik (Basic)"
echo ""

read -rp "👉 Choix [1-2] (défaut: 1) : " auth_choice
auth_choice="${auth_choice:-1}"

case "$auth_choice" in
  1) APP_AUTH_TYPE="none" ;;
  2) APP_AUTH_TYPE="traefik_basic" ;;
  *) error "Choix invalide" ;;
esac

#######################################
# Résumé
#######################################
TARGET_DIR="$(app_target_dir "$APP_SELECTED")"

echo ""
echo "Résumé du déploiement :"
echo " - Application : $APP_NAME"
echo " - Domaine     : $APP_DOMAIN"
echo " - Dossier     : $TARGET_DIR"
echo " - Auth        : $APP_AUTH_TYPE"
echo ""

read -rp "❓ Confirmer le déploiement ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || exit 0

#######################################
# Préparation & déploiement
#######################################
export APP_DOMAIN
info "Préparation des fichiers…"
app_prepare "$APP_SELECTED"

info "Déploiement Docker…"
(
  cd "$TARGET_DIR"
  docker compose up -d
)

#######################################
# Authentification (automatique)
#######################################
case "$APP_AUTH_TYPE" in
  traefik_basic)
    info "Application automatique de l'auth Traefik"
    "$BASE_DIR/actions/app_auth_apply.sh" "$APP_SELECTED" "$APP_DOMAIN"
    ;;
  none)
    info "Suppression automatique de toute auth Traefik"
    "$BASE_DIR/actions/app_auth_remove.sh" "$APP_SELECTED"
    ;;
esac

#######################################
# Vérifications post-déploiement
#######################################
"$BASE_DIR/actions/app_check_auth.sh" "$APP_SELECTED"
"$BASE_DIR/actions/app_check_exposed.sh" "$APP_SELECTED"

success "Application '$APP_NAME' déployée avec succès"
info "URL : https://$APP_DOMAIN"
