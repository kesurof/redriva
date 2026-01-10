#!/usr/bin/env bash
# Action REDRIVA — Application DNS wildcard Cloudflare

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/config.sh"
source "$SCRIPT_DIR/../../modules/cloudflare.sh"

title "Cloudflare — Application DNS wildcard"

CF_DOMAIN="$(config_get CF_DOMAIN)"
CF_EMAIL="$(config_get CF_EMAIL)"
CF_API_KEY="$(config_get CF_API_KEY)"

if [[ -z "$CF_DOMAIN" || -z "$CF_EMAIL" || -z "$CF_API_KEY" ]]; then
  error "Configuration Cloudflare incomplète"
  info "Lance d’abord : cloudflare_configure"
  exit 1
fi

info "Récupération IP publique…"
PUBLIC_IP="$(cf_get_public_ip)"

info "Récupération zone Cloudflare…"
ZONE_ID="$(cf_get_zone_id)"

if [[ -z "$ZONE_ID" ]]; then
  error "Zone Cloudflare introuvable pour $CF_DOMAIN"
  exit 1
fi

info "Application du DNS wildcard (*.$CF_DOMAIN → $PUBLIC_IP)…"
cf_apply_wildcard_dns "$ZONE_ID" "$PUBLIC_IP"

success "DNS wildcard Cloudflare appliqué"
