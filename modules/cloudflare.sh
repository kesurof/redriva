#!/usr/bin/env bash
# Module Cloudflare — logique métier pure
# Aucune UI, aucune config, aucun exit

CF_API_BASE="https://api.cloudflare.com/client/v4"

#######################################
# Utils internes
#######################################

_cf_api() {
  local method="$1"
  local endpoint="$2"
  local data="$3"

  curl -fsSL -X "$method" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json" \
    ${data:+--data "$data"} \
    "$CF_API_BASE$endpoint"
}

#######################################
# IP publique
#######################################

cf_get_public_ip() {
  curl -fsSL https://api.ipify.org
}

#######################################
# Zone
#######################################

cf_get_zone_id() {
  _cf_api GET "/zones?name=$CF_DOMAIN" \
    | grep -o '"id":"[^"]*"' \
    | head -n1 \
    | cut -d'"' -f4
}

#######################################
# DNS records
#######################################

cf_get_dns_record_id() {
  local zone_id="$1"
  local name="$2"
  local type="${3:-A}"

  _cf_api GET "/zones/$zone_id/dns_records?type=$type&name=$name" \
    | grep -o '"id":"[^"]*"' \
    | head -n1 \
    | cut -d'"' -f4
}

cf_dns_record_exists() {
  local zone_id="$1"
  local name="$2"
  local type="${3:-A}"

  [[ -n "$(cf_get_dns_record_id "$zone_id" "$name" "$type")" ]]
}

#######################################
# Create / Update DNS
#######################################

cf_create_dns_record() {
  local zone_id="$1"
  local name="$2"
  local content="$3"
  local type="${4:-A}"
  local proxied="${5:-true}"

  _cf_api POST "/zones/$zone_id/dns_records" \
    "{
      \"type\": \"$type\",
      \"name\": \"$name\",
      \"content\": \"$content\",
      \"ttl\": 1,
      \"proxied\": $proxied
    }"
}

cf_update_dns_record() {
  local zone_id="$1"
  local record_id="$2"
  local name="$3"
  local content="$4"
  local type="${5:-A}"
  local proxied="${6:-true}"

  _cf_api PUT "/zones/$zone_id/dns_records/$record_id" \
    "{
      \"type\": \"$type\",
      \"name\": \"$name\",
      \"content\": \"$content\",
      \"ttl\": 1,
      \"proxied\": $proxied
    }"
}

#######################################
# Wildcard helper
#######################################

cf_apply_wildcard_dns() {
  local zone_id="$1"
  local ip="$2"
  local record_name="*.$CF_DOMAIN"

  local record_id
  record_id="$(cf_get_dns_record_id "$zone_id" "$record_name" "A")"

  if [[ -n "$record_id" ]]; then
    cf_update_dns_record "$zone_id" "$record_id" "$record_name" "$ip"
  else
    cf_create_dns_record "$zone_id" "$record_name" "$ip"
  fi
}
