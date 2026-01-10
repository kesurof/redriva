#!/usr/bin/env bash
# Action REDRIVA — Vérification HTTPS Traefik
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Traefik — Vérification HTTPS"

TRAEFIK_CONTAINER="traefik"

# Traefik actif ?
if ! docker ps --format '{{.Names}}' | grep -qw "$TRAEFIK_CONTAINER"; then
  error "Traefik n’est pas actif"
fi

success "Traefik est actif"

# Vérification écoute ports
if ss -ltn | grep -q ':80 '; then
  success "Port 80 (HTTP) ouvert"
else
  error "Port 80 non ouvert"
fi

if ss -ltn | grep -q ':443 '; then
  success "Port 443 (HTTPS) ouvert"
else
  error "Port 443 non ouvert"
fi

# Test HTTP local
info "Test HTTP local (http://localhost)…"
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -Eq '^[23]'; then
  success "Réponse HTTP valide"
else
  error "Aucune réponse HTTP valide sur localhost"
fi

# Test HTTPS local (peut échouer sans cert)
info "Test HTTPS local (https://localhost)…"
if curl -sk -o /dev/null -w "%{http_code}" https://localhost | grep -Eq '^[23]'; then
  success "Réponse HTTPS valide"
else
  info "HTTPS non encore fonctionnel (normal si aucun domaine/certificat)"
fi
