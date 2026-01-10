#!/usr/bin/env bash
# Action REDRIVA — Vérification configuration SSH
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

SSHD_CONFIG="/etc/ssh/sshd_config"

title "SSH — Vérification configuration"

if [[ ! -f "$SSHD_CONFIG" ]]; then
  error "Fichier $SSHD_CONFIG introuvable"
fi

info "Fichier de configuration : $SSHD_CONFIG"

check() {
  local key="$1"
  local expected="$2"

  local value
  value="$(grep -Ei "^\s*$key\s+" "$SSHD_CONFIG" | tail -n1 | awk '{print $2}')"

  if [[ -z "$value" ]]; then
    error "$key non défini"
    return
  fi

  info "$key = $value"

  if [[ -n "$expected" && "$value" != "$expected" ]]; then
    error "$key devrait être '$expected'"
  else
    success "$key conforme"
  fi
}

check "PasswordAuthentication" "no"
check "PubkeyAuthentication" "yes"
check "PermitRootLogin" "no"

PORT="$(grep -Ei "^\s*Port\s+" "$SSHD_CONFIG" | tail -n1 | awk '{print $2}')"
info "Port SSH : ${PORT:-22}"
