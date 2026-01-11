#!/usr/bin/env bash
# Action REDRIVA — Déploiement applicatif générique
# Orchestration humaine autour du moteur app_engine
#
# - Liste les applications disponibles
# - Demande la personnalisation (domaine)
# - Copie et prépare les fichiers via le module
# - Lance docker compose depuis le dossier serveur
#
# ⚠️ Action effectrice, volontaire, rejouable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "Applications — Déploiement"

#######################################
# Liste des applications disponibles
#######################################

mapfile -t APPS < <(app_list)

if [[ "${#APPS[@]}" -eq 0 ]]; then
  error "Aucune application disponible dans le dossier apps/"
fi

echo "Applications disponibles :"
echo ""

i=1
for app in "${APPS[@]}"; do
  # Charger app.conf pour afficher la description
  unset APP_NAME APP_DESCRIPTION APP_DEFAULT_DOMAIN
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

#######################################
# Chargement de la configuration app
#######################################

unset APP_NAME APP_DESCRIPTION APP_DEFAULT_DOMAIN APP_DOMAIN
app_load_conf "$APP_SELECTED" || error "Impossible de charger la configuration de l'app"

info "Application sélectionnée : $APP_NAME"

#######################################
# Détermination du domaine
#######################################

# Variables globales nécessaires aux substitutions
CF_DOMAIN="$(config_get CF_DOMAIN)"
[[ -z "$CF_DOMAIN" ]] && error "CF_DOMAIN non défini — configure Cloudflare d’abord"
export CF_DOMAIN

DEFAULT_DOMAIN="$(echo "$APP_DEFAULT_DOMAIN" | envsubst)"

APP_DOMAIN="$DEFAULT_DOMAIN"

info "Domaine par défaut : $DEFAULT_DOMAIN"
read -rp "👉 Modifier le domaine ? [y/N] : " change_domain

if [[ "$change_domain" =~ ^[yY]$ ]]; then
  read -rp "👉 Nouveau domaine : " APP_DOMAIN
fi

#######################################
# Résumé avant action
#######################################

TARGET_DIR="$(app_target_dir "$APP_SELECTED")"

echo ""
echo "Résumé du déploiement :"
echo " - Application : $APP_NAME"
echo " - Domaine     : $APP_DOMAIN"
echo " - Dossier     : $TARGET_DIR"
echo ""

read -rp "❓ Confirmer le déploiement ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Déploiement annulé par l'utilisateur"
  exit 0
}

#######################################
# Préparation des fichiers via le moteur
#######################################

export APP_DOMAIN
info "Préparation des fichiers applicatifs…"
app_prepare "$APP_SELECTED" || error "Échec de la préparation de l'application"

#######################################
# Déploiement effectif côté serveur
#######################################

info "Déploiement Docker de l'application…"
(
  cd "$TARGET_DIR"
  docker compose up -d
)

success "Application '$APP_NAME' déployée avec succès"
info "URL attendue : https://$APP_DOMAIN"
