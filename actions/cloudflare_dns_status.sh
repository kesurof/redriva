#!/usr/bin/env bash
# Action REDRIVA — Statut DNS wildcard Cloudflare

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/config.sh"
source "$SCRIPT_DIR/../../modules/cloudflare.sh"

title "Cloudflare — Statut DNS wildcard"

CF_DOMAIN="$(config_get CF_DOMAIN)"
CF_EMAIL="$(config_get CF_EMAIL)"
CF_API_KEY="$(config_get CF_API_KEY)"

if [[ -z "$CF_DOMAIN" || -z "$CF_EMAIL" || -z "$CF_API_KEY" ]]; then
  error "Configuration Cloudflare incomplète"
  exit 1
fi

ZONE_ID="$(cf_get_zone_id)"

if [[ -z "$ZONE_ID" ]]; then
  error "Zone Cloudflare introuvable pour $CF_DOMAIN"
  exit 1
fi

RECORD_NAME="*.$CF_DOMAIN"
RECORD_ID="$(cf_get_dns_record_id "$ZONE_ID" "$RECORD_NAME" "A")"
PUBLIC_IP="$(cf_get_public_ip)"

echo ""
info "Domaine        : $CF_DOMAIN"
info "IP publique    : $PUBLIC_IP"

if [[ -z "$RECORD_ID" ]]; then
  error "Aucun DNS wildcard trouvé pour $RECORD_NAME"
  exit 0
fi

DNS_IP="$(
  _cf_api GET "/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  | grep -o '"content":"[^"]*"' \
  | cut -d'"' -f4
)"

info "DNS wildcard   : présent"
info "IP Cloudflare  : $DNS_IP"

if [[ "$DNS_IP" == "$PUBLIC_IP" ]]; then
  success "DNS wildcard à jour"
else
  error "DNS wildcard non synchronisé avec l’IP publique"
fi
