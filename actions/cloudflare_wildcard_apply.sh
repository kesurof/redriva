#!/usr/bin/env bash
# Action REDRIVA — Application DNS wildcard Cloudflare

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/cloudflare.sh"
# source modules si nécessaire

title "Cloudflare — Application DNS wildcard"

CF_DOMAIN="$(config_get CF_DOMAIN)"
CF_EMAIL="$(config_get CF_EMAIL)"
CF_API_KEY="$(config_get CF_API_KEY)"

if [[ -z "$CF_DOMAIN" || -z "$CF_EMAIL" || -z "$CF_API_KEY" ]]; then
  error "Configuration Cloudflare incomplète (lance d’abord cloudflare_configure)"
fi

info "Récupération IP publique…"
PUBLIC_IP="$(cf_get_public_ip)"

info "Récupération zone Cloudflare…"
ZONE_ID="$(cf_get_zone_id)"

if [[ -z "$ZONE_ID" ]]; then
  error "Zone Cloudflare introuvable pour $CF_DOMAIN"
fi

info "Application du DNS wildcard (*.$CF_DOMAIN → $PUBLIC_IP)…"
cf_apply_wildcard_dns "$ZONE_ID" "$PUBLIC_IP"

success "DNS wildcard Cloudflare appliqué"
