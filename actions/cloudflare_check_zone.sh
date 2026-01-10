#!/usr/bin/env bash
# Action REDRIVA — Vérification zone Cloudflare
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/cloudflare.sh"
# source modules si nécessaire

title "Cloudflare — Vérification zone"

CF_DOMAIN="$(config_get CF_DOMAIN)"
CF_EMAIL="$(config_get CF_EMAIL)"
CF_API_KEY="$(config_get CF_API_KEY)"

# Vérification configuration minimale
if [[ -z "$CF_DOMAIN" || -z "$CF_EMAIL" || -z "$CF_API_KEY" ]]; then
  error "Configuration Cloudflare incomplète (CF_DOMAIN / CF_EMAIL / CF_API_KEY)"
fi

info "Domaine configuré : $CF_DOMAIN"

info "Recherche de la zone Cloudflare…"
ZONE_ID="$(cf_get_zone_id)"

if [[ -z "$ZONE_ID" ]]; then
  error "Zone Cloudflare introuvable pour le domaine $CF_DOMAIN"
fi

success "Zone Cloudflare trouvée"
info "ID de zone : $ZONE_ID"
