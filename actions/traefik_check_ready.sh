#!/usr/bin/env bash
# Action REDRIVA — Traefik READY check
# Diagnostic global : Traefik est-il prêt à exposer des apps HTTPS publiques ?
#
# ❌ Aucun effet système
# ❌ Aucune dépendance applicative
# ✅ Lisible, explicite, relançable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"

title "Traefik — Vérification état READY"

TRAEFIK_CONTAINER="traefik"
TRAEFIK_DIR="/opt/docker/traefik"
NETWORK="proxy"

READY=true

fail() {
  error "$1"
  READY=false
}

warn() {
  echo "⚠️  $1"
}

#######################################
# 1️⃣ Traefik actif
#######################################
info "Vérification conteneur Traefik…"

if docker ps --format '{{.Names}}' | grep -qw "$TRAEFIK_CONTAINER"; then
  success "Traefik est actif"
else
  fail "Traefik n’est pas actif"
fi

#######################################
# 2️⃣ Réseau Docker proxy
#######################################
info "Vérification réseau Docker '$NETWORK'…"

if docker network ls --format '{{.Name}}' | grep -qw "$NETWORK"; then
  success "Réseau '$NETWORK' présent"
else
  fail "Réseau Docker '$NETWORK' absent"
fi

#######################################
# 3️⃣ Ports 80 / 443
#######################################
info "Vérification écoute des ports…"

if ss -ltn | grep -q ':80 '; then
  success "Port 80 (HTTP) ouvert"
else
  fail "Port 80 non ouvert"
fi

if ss -ltn | grep -q ':443 '; then
  success "Port 443 (HTTPS) ouvert"
else
  fail "Port 443 non ouvert"
fi

#######################################
# 4️⃣ Configuration Traefik minimale
#######################################
info "Vérification configuration Traefik…"

COMPOSE_FILE="$TRAEFIK_DIR/docker-compose.yml"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  fail "docker-compose.yml Traefik introuvable"
else
  success "docker-compose.yml Traefik présent"
fi

grep -q 'entrypoints.web.address' "$COMPOSE_FILE" \
  && success "EntryPoint web configuré" \
  || fail "EntryPoint web manquant"

grep -q 'entrypoints.websecure.address' "$COMPOSE_FILE" \
  && success "EntryPoint websecure configuré" \
  || fail "EntryPoint websecure manquant"

grep -q 'certificatesresolvers' "$COMPOSE_FILE" \
  && success "Resolver ACME détecté" \
  || warn "Aucun resolver ACME détecté (HTTPS public impossible)"

#######################################
# 5️⃣ Test HTTPS réel (si domaine configuré)
#######################################
CF_DOMAIN="$(config_get CF_DOMAIN)"

if [[ -z "$CF_DOMAIN" ]]; then
  warn "CF_DOMAIN non défini — test HTTPS public ignoré"
else
  TEST_DOMAIN="test.$CF_DOMAIN"
  info "Test HTTPS public : https://$TEST_DOMAIN"

  if curl -sk --max-time 5 "https://$TEST_DOMAIN" >/dev/null; then
    success "HTTPS fonctionnel sur $TEST_DOMAIN"
  else
    warn "HTTPS non fonctionnel sur $TEST_DOMAIN"
    warn "➡️ DNS / certificat / app absente (normal si aucun service)"
  fi
fi

#######################################
# RÉSULTAT FINAL
#######################################
echo ""
if [[ "$READY" == true ]]; then
  success "Traefik est READY pour exposer des applications HTTPS"
else
  error "Traefik n’est PAS prêt — corrige les points ci-dessus"
fi
