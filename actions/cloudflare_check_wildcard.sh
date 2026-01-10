#!/usr/bin/env bash
# Action REDRIVA — Vérification DNS wildcard Cloudflare
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/cloudflare.sh"
# source modules si nécessaire

title "Cloudflare — Vérification DNS wildcard"

CF_DOMAIN="$(config_get CF_DOMAIN)"
CF_EMAIL="$(config_get CF_EMAIL)"
CF_API_KEY="$(config_get CF_API_KEY)"

# Vérification configuration minimale
if [[ -z "$CF_DOMAIN" || -z "$CF_EMAIL" || -z "$CF_API_KEY" ]]; then
  error "Configuration Cloudflare incomplète (CF_DOMAIN / CF_EMAIL / CF_API_KEY)"
fi

info "Domaine configuré : $CF_DOMAIN"

# Zone
info "Recherche de la zone Cloudflare…"
ZONE_ID="$(cf_get_zone_id)"

if [[ -z "$ZONE_ID" ]]; then
  error "Zone Cloudflare introuvable pour $CF_DOMAIN"
fi

success "Zone trouvée"

# IP publique
info "Récupération de l’IP publique…"
PUBLIC_IP="$(cf_get_public_ip)"

if [[ -z "$PUBLIC_IP" ]]; then
  error "Impossible de déterminer l’IP publique"
fi

info "IP publique : $PUBLIC_IP"

# Wildcard DNS
RECORD_NAME="*.$CF_DOMAIN"
info "Recherche du DNS wildcard ($RECORD_NAME)…"

RECORD_ID="$(cf_get_dns_record_id "$ZONE_ID" "$RECORD_NAME" "A")"

if [[ -z "$RECORD_ID" ]]; then
  error "Aucun DNS wildcard trouvé pour $RECORD_NAME"
fi

success "DNS wildcard présent"

DNS_IP="$(
  _cf_api GET "/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    | grep -o '"content":"[^"]*"' \
    | cut -d'"' -f4
)"

info "IP Cloudflare : $DNS_IP"

if [[ "$DNS_IP" == "$PUBLIC_IP" ]]; then
  success "DNS wildcard synchronisé avec l’IP publique"
else
  error "DNS wildcard NON synchronisé avec l’IP publique"
fi
