#!/usr/bin/env bash
# Action REDRIVA — Configuration Cloudflare
# Gère uniquement la configuration persistante

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/config.sh"

title "Cloudflare — Configuration"

ask_value "CF_DOMAIN"   "Domaine principal Cloudflare" "no"
ask_value "CF_EMAIL"    "Email Cloudflare"             "no"
ask_value "CF_API_KEY"  "Clé API Cloudflare"           "yes"

success "Configuration Cloudflare enregistrée"
