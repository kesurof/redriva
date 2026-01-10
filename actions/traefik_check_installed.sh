#!/usr/bin/env bash
# Action REDRIVA — Vérification présence Traefik
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Traefik — Vérification installation"

TRAEFIK_DIR="/opt/docker/traefik"
TRAEFIK_CONTAINER="traefik"

# Vérification dossier
if [[ -d "$TRAEFIK_DIR" ]]; then
  success "Dossier Traefik présent : $TRAEFIK_DIR"
else
  info "Dossier Traefik absent"
fi

# Vérification docker-compose.yml
if [[ -f "$TRAEFIK_DIR/docker-compose.yml" ]]; then
  success "docker-compose.yml Traefik présent"
else
  info "docker-compose.yml Traefik absent"
fi

# Vérification conteneur Docker
if docker ps --format '{{.Names}}' | grep -qw "$TRAEFIK_CONTAINER"; then
  success "Conteneur Traefik actif"
else
  info "Conteneur Traefik non actif"
fi

# Vérification réseau proxy
if docker network ls --format '{{.Name}}' | grep -qw proxy; then
  success "Réseau Docker 'proxy' présent"
else
  info "Réseau Docker 'proxy' absent"
fi
