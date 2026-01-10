#!/usr/bin/env bash
# Action REDRIVA — Vérification installation Docker
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Docker — Vérification installation"

# Vérification binaire
if ! command -v docker >/dev/null 2>&1; then
  error "Docker n’est pas installé"
fi

success "Binaire docker présent"

# Version
DOCKER_VERSION="$(docker --version 2>/dev/null || true)"
info "Version Docker : ${DOCKER_VERSION:-inconnue}"

# Vérification service (si systemd présent)
if command -v systemctl >/dev/null 2>&1; then
  if systemctl list-unit-files | grep -q '^docker\.service'; then
    success "Service docker déclaré"
  else
    error "Service docker non trouvé"
  fi
else
  info "systemctl non disponible (environnement non systemd)"
fi

# Test minimal du daemon (sans conteneur)
if docker info >/dev/null 2>&1; then
  success "Daemon Docker accessible"
else
  error "Daemon Docker inaccessible (permissions ou service arrêté)"
fi
