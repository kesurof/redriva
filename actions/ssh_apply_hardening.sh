#!/usr/bin/env bash
# Action REDRIVA — Application du durcissement SSH
# Action effectrice, volontaire, rejouable
# ⚠️ Modifie la configuration SSH

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_BACKUP="/etc/ssh/sshd_config.redriva.bak"

title "SSH — Application du durcissement"

# Vérifications préalables minimales
if [[ ! -f "$SSHD_CONFIG" ]]; then
  error "Fichier $SSHD_CONFIG introuvable"
fi

info "Fichier cible : $SSHD_CONFIG"

echo ""
echo "⚠️  ACTION CRITIQUE"
echo "Cette action va appliquer les règles suivantes :"
echo " - Désactiver l’authentification par mot de passe"
echo " - Forcer l’authentification par clé"
echo " - Interdire la connexion SSH en root"
echo ""
echo "➡️ Assure-toi AVANT de continuer que :"
echo " - au moins un utilisateur dispose d’une clé SSH valide"
echo " - une session SSH alternative est ouverte"
echo ""

read -rp "❓ Continuer l’application du durcissement SSH ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Action annulée par l’utilisateur"
  exit 0
}

# Sauvegarde (une seule fois)
if [[ ! -f "$SSHD_BACKUP" ]]; then
  cp "$SSHD_CONFIG" "$SSHD_BACKUP"
  chmod 600 "$SSHD_BACKUP"
  success "Sauvegarde créée : $SSHD_BACKUP"
else
  info "Sauvegarde existante détectée : $SSHD_BACKUP"
fi

apply_setting() {
  local key="$1"
  local value="$2"

  if grep -Eq "^\s*#?\s*$key\s+" "$SSHD_CONFIG"; then
    sed -i "s|^\s*#\?\s*$key\s\+.*|$key $value|" "$SSHD_CONFIG"
  else
    echo "$key $value" >> "$SSHD_CONFIG"
  fi

  info "Appliqué : $key $value"
}

# Application des règles de durcissement
apply_setting "PasswordAuthentication" "no"
apply_setting "PubkeyAuthentication" "yes"
apply_setting "PermitRootLogin" "no"

# Vérification de cohérence SSH
info "Vérification de la configuration SSH…"
if ! sshd -t; then
  error "Configuration SSH invalide après modification — restauration requise depuis $SSHD_BACKUP"
fi

# Rechargement du service
info "Rechargement du service SSH…"
reload_ssh() {
  if systemctl list-unit-files | grep -q '^sshd\.service'; then
    systemctl reload sshd
    return
  fi

  if systemctl list-unit-files | grep -q '^ssh\.service'; then
    systemctl reload ssh
    return
  fi

  error "Service SSH introuvable (ni sshd ni ssh)"
}

info "Rechargement du service SSH…"
reload_ssh

success "Durcissement SSH appliqué avec succès"
