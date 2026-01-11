#!/usr/bin/env bash
# Action REDRIVA — Vérification Auth Traefik
# Diagnostic : middleware d’auth présent et chargé

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Traefik — Vérification Auth"

TRAEFIK_DIR="/opt/docker/traefik"
CONFIG_DIR="$TRAEFIK_DIR/config"
AUTH_FILE="$CONFIG_DIR/auth-basic.yml"
TRAEFIK_CONTAINER="traefik"

#######################################
# 1️⃣ Traefik actif
#######################################
info "Vérification Traefik actif…"

docker ps --format '{{.Names}}' | grep -qw "$TRAEFIK_CONTAINER" \
  && success "Traefik actif" \
  || error "Traefik non actif"

#######################################
# 2️⃣ Fichier middleware
#######################################
info "Vérification middleware auth…"

if [[ -f "$AUTH_FILE" ]]; then
  success "Middleware auth présent : $AUTH_FILE"
else
  error "Middleware auth absent ($AUTH_FILE)"
fi

#######################################
# 3️⃣ Provider file activé
#######################################
info "Vérification provider file Traefik…"

grep -q 'providers.file.directory' "$TRAEFIK_DIR/docker-compose.yml" \
  && success "Provider file activé" \
  || error "Provider file non configuré"

#######################################
# FIN
#######################################
success "Auth Traefik correctement configurée"
