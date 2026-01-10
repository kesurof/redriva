#!/usr/bin/env bash
# Action REDRIVA — Vérification réseau Docker pour Traefik
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Traefik — Vérification réseau Docker"

NETWORK="proxy"

# Présence du réseau
if ! docker network ls --format '{{.Name}}' | grep -qw "$NETWORK"; then
  error "Réseau Docker '$NETWORK' absent"
fi

success "Réseau Docker '$NETWORK' présent"

# Inspection du réseau
DRIVER="$(docker network inspect "$NETWORK" -f '{{.Driver}}')"
SCOPE="$(docker network inspect "$NETWORK" -f '{{.Scope}}')"

info "Driver : $DRIVER"
info "Scope  : $SCOPE"

[[ "$DRIVER" == "bridge" ]] && success "Driver conforme (bridge)" || error "Driver non recommandé (attendu: bridge)"
[[ "$SCOPE" == "local" ]] && success "Scope conforme (local)" || error "Scope non recommandé (attendu: local)"

# Vérification connectivité potentielle
CONTAINERS="$(docker network inspect "$NETWORK" -f '{{ range .Containers }}{{ .Name }} {{ end }}')"

if [[ -z "$CONTAINERS" ]]; then
  info "Aucun conteneur actuellement connecté au réseau proxy"
else
  info "Conteneurs connectés au réseau proxy : $CONTAINERS"
fi
