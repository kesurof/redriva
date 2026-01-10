#!/usr/bin/env bash
# Action REDRIVA — Déploiement Traefik
# Action effectrice, volontaire, rejouable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Traefik — Déploiement"

TRAEFIK_DIR="/opt/docker/traefik"
TRAEFIK_CONTAINER="traefik"

# Vérification dossier
if [[ ! -d "$TRAEFIK_DIR" ]]; then
  error "Dossier Traefik introuvable : $TRAEFIK_DIR"
fi

# Vérification docker-compose.yml
if [[ ! -f "$TRAEFIK_DIR/docker-compose.yml" ]]; then
  error "docker-compose.yml manquant dans $TRAEFIK_DIR"
fi

# Traefik déjà actif ?
if docker ps --format '{{.Names}}' | grep -qw "$TRAEFIK_CONTAINER"; then
  success "Traefik est déjà actif — aucune action nécessaire"
  exit 0
fi

echo ""
echo "⚠️  ACTION EFFECTRICE"
echo "Cette action va :"
echo " - démarrer Traefik via docker compose"
echo " - sans recréer le réseau proxy"
echo " - sans modifier la configuration existante"
echo ""

read -rp "❓ Démarrer Traefik maintenant ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Déploiement annulé par l’utilisateur"
  exit 0
}

# Déploiement
info "Démarrage de Traefik…"
(
  cd "$TRAEFIK_DIR"
  docker compose up -d
)

success "Traefik démarré avec succès"
