#!/usr/bin/env bash
# Action REDRIVA — Diagnostic global
#
# Diagnostic global du serveur :
# - Docker
# - Traefik
# - Cloudflare
# - Applications
#
# ❌ Aucun effet système
# ❌ Aucune orchestration
# ✅ Vue synthétique admin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "REDRIVA — Diagnostic global"

#######################################
# Docker
#######################################
title "Docker"

if command -v docker >/dev/null 2>&1; then
  success "Docker installé"
else
  error "Docker absent"
fi

if docker info >/dev/null 2>&1; then
  success "Daemon Docker accessible"
else
  error "Daemon Docker inaccessible"
fi

#######################################
# Traefik
#######################################
title "Traefik"

TRAEFIK_CONTAINER="traefik"

if docker ps --format '{{.Names}}' | grep -qw "$TRAEFIK_CONTAINER"; then
  success "Traefik actif"
else
  error "Traefik non actif"
fi

docker network ls --format '{{.Name}}' | grep -qw proxy \
  && success "Réseau proxy présent" \
  || error "Réseau proxy absent"

#######################################
# Cloudflare
#######################################
title "Cloudflare"

CF_DOMAIN="$(config_get CF_DOMAIN)"
CF_EMAIL="$(config_get CF_EMAIL)"
CF_API_KEY="$(config_get CF_API_KEY)"

[[ -n "$CF_DOMAIN" ]] \
  && success "CF_DOMAIN configuré ($CF_DOMAIN)" \
  || error "CF_DOMAIN manquant"

[[ -n "$CF_EMAIL" ]] \
  && success "CF_EMAIL configuré" \
  || error "CF_EMAIL manquant"

[[ -n "$CF_API_KEY" ]] \
  && success "CF_API_KEY configurée" \
  || error "CF_API_KEY manquante"

#######################################
# Applications
#######################################
title "Applications"

mapfile -t APPS < <(app_list)

if [[ "${#APPS[@]}" -eq 0 ]]; then
  info "Aucune application déclarée"
else
  for app in "${APPS[@]}"; do
    unset APP_NAME APP_DESCRIPTION APP_DEFAULT_DOMAIN
    app_load_conf "$app" || continue

    APP_DOMAIN="$(render_domain "$APP_DEFAULT_DOMAIN" 2>/dev/null || true)"
    CONTAINER="$APP_NAME"

    echo ""
    info "Application : $APP_NAME"
    info "Domaine     : ${APP_DOMAIN:-inconnu}"

    if docker ps --format '{{.Names}}' | grep -qw "$CONTAINER"; then
      success "Conteneur actif"
    else
      error "Conteneur non actif"
      continue
    fi

    if [[ -n "$APP_DOMAIN" ]]; then
      CODE="$(curl -sk -o /dev/null -w "%{http_code}" "https://$APP_DOMAIN" || true)"

      if [[ "$CODE" =~ ^2|3 ]]; then
        success "Accessible HTTPS (HTTP $CODE)"
      elif [[ "$CODE" == "401" || "$CODE" == "403" ]]; then
        success "Protégée par auth (HTTP $CODE)"
      else
        error "Non accessible (HTTP $CODE)"
      fi
    else
      error "Domaine non résolu"
    fi
  done
fi

#######################################
# FIN
#######################################
echo ""
success "Diagnostic global terminé"
