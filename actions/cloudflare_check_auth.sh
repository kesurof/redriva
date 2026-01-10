#!/usr/bin/env bash
# Action REDRIVA — Vérification authentification Cloudflare
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/cloudflare.sh"
# source modules si nécessaire

title "Cloudflare — Vérification authentification API"

CF_DOMAIN="$(config_get CF_DOMAIN)"
CF_EMAIL="$(config_get CF_EMAIL)"
CF_API_KEY="$(config_get CF_API_KEY)"

# Vérification configuration minimale
if [[ -z "$CF_DOMAIN" || -z "$CF_EMAIL" || -z "$CF_API_KEY" ]]; then
  error "Configuration Cloudflare incomplète (CF_DOMAIN / CF_EMAIL / CF_API_KEY)"
fi

info "Domaine configuré : $CF_DOMAIN"
info "Email Cloudflare  : $CF_EMAIL"
info "Clé API          : configurée"

# Test API minimal : lister les zones (sans supposer l'existence)
info "Test de connexion à l’API Cloudflare…"

if ! _cf_api GET "/zones" >/dev/null 2>&1; then
  error "Échec d’authentification Cloudflare (clé ou email invalide)"
fi

success "Authentification Cloudflare valide"
