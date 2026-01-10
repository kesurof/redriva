#!/usr/bin/env bash
# Action REDRIVA — Rechargement Traefik
# Action effectrice légère, sans interruption

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Traefik — Rechargement"

TRAEFIK_DIR="/opt/docker/traefik"
TRAEFIK_CONTAINER="traefik"

# Traefik actif ?
if ! docker ps --format '{{.Names}}' | grep -qw "$TRAEFIK_CONTAINER"; then
  error "Traefik n’est pas actif — impossible de recharger"
fi

echo ""
echo "Cette action va :"
echo " - recharger Traefik via docker compose"
echo " - sans arrêter le conteneur"
echo ""

read -rp "❓ Recharger Traefik maintenant ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Rechargement annulé par l’utilisateur"
  exit 0
}

info "Rechargement de Traefik…"
(
  cd "$TRAEFIK_DIR"
  docker compose up -d
)

success "Traefik rechargé avec succès"
