#!/usr/bin/env bash
# Action REDRIVA — Vérification permissions Docker
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Docker — Vérification des permissions"

# Groupe docker
if getent group docker >/dev/null 2>&1; then
  success "Groupe docker présent"
else
  error "Groupe docker absent"
fi

DOCKER_GROUP_USERS="$(getent group docker | cut -d: -f4)"

if [[ -z "$DOCKER_GROUP_USERS" ]]; then
  info "Aucun utilisateur dans le groupe docker"
else
  info "Utilisateurs du groupe docker : $DOCKER_GROUP_USERS"
fi

# Utilisateur appelant réel (même avec sudo)
CALLING_USER="${SUDO_USER:-$(whoami)}"
info "Utilisateur appelant : $CALLING_USER"

# Vérification appartenance au groupe docker
if id -nG "$CALLING_USER" | grep -qw docker; then
  success "L’utilisateur $CALLING_USER appartient au groupe docker"
else
  error "L’utilisateur $CALLING_USER n’appartient PAS au groupe docker"
fi

# Test accès Docker sans sudo
info "Test d’accès Docker sans sudo…"

if sudo -u "$CALLING_USER" docker ps >/dev/null 2>&1; then
  success "Docker accessible sans sudo pour $CALLING_USER"
else
  error "Docker NON accessible sans sudo pour $CALLING_USER"
fi
