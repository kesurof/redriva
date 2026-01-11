#!/usr/bin/env bash
# Module REDRIVA — Moteur de déploiement applicatif
# Rôle : gérer les templates d'applications (apps/)
# - lister les apps
# - charger app.conf
# - copier les fichiers vers le serveur
# - appliquer envsubst sur les templates
#
# ⚠️ Ce module :
# - n'affiche rien à l'utilisateur
# - ne lance aucun docker
# - ne prend aucune décision UX

#######################################
# Constantes internes
#######################################

APP_TEMPLATES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../apps" && pwd)"
APP_INSTALL_BASE="/opt/docker/config"
APP_DATA_BASE="/opt/docker/apps"

#######################################
# Liste des applications disponibles
# stdout : une app par ligne
#######################################
app_list() {
  for dir in "$APP_TEMPLATES_DIR"/*; do
    [[ -d "$dir" ]] || continue
    basename "$dir"
  done
}

#######################################
# Charger la configuration d'une app
# args:
#   $1 = nom de l'app
#######################################
app_load_conf() {
  local app="$1"
  local conf="$APP_TEMPLATES_DIR/$app/app.conf"

  [[ -f "$conf" ]] || return 1

  # shellcheck disable=SC1090
  source "$conf"
}

#######################################
# Préparer le dossier cible serveur
# args:
#   $1 = nom de l'app
# stdout : chemin du dossier cible
#######################################
app_target_dir() {
  local app="$1"
  echo "$APP_INSTALL_BASE/$app"
}

#######################################
# Copier les fichiers templates vers le serveur
# args:
#   $1 = nom de l'app
#   $2 = dossier cible serveur
#######################################
app_copy_templates() {
  local app="$1"
  local target="$2"
  local src="$APP_TEMPLATES_DIR/$app"

  mkdir -p "$target"

  # Copie brute (tpl + autres fichiers éventuels)
  cp -r "$src/"* "$target/"
}

#######################################
# Appliquer envsubst sur les fichiers .tpl
# args:
#   $1 = dossier cible serveur
#######################################
app_apply_templates() {
  local target="$1"

  find "$target" -type f -name "*.tpl" | while read -r tpl; do
    local out="${tpl%.tpl}"
    envsubst < "$tpl" > "$out"
    rm -f "$tpl"
  done
}

#######################################
# Déployer une app (phase technique uniquement)
# args:
#   $1 = nom de l'app
#######################################
app_prepare() {
  local app="$1"
  local target

  # Charger la config app.conf
  app_load_conf "$app" || return 1

  target="$(app_target_dir "$app")"

  # Export minimal requis pour envsubst
  export APP_NAME
  export APP_DOMAIN

  export APP_DATA_DIR="$APP_DATA_BASE/$app"

  # Copie + substitution
  app_copy_templates "$app" "$target"
  app_apply_templates "$target"
}

render_domain() {
  local template="$1"
  local cf_domain

  cf_domain="$(config_get CF_DOMAIN)"
  [[ -z "$cf_domain" ]] && return 1

  echo "$template" | sed "s/{{CF_DOMAIN}}/$cf_domain/g"
}
