#!/usr/bin/env bash
# Action REDRIVA — Correction des permissions Docker
# Action effectrice, volontaire, ciblée
# ⚠️ Ajoute un utilisateur au groupe docker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "Docker — Correction des permissions"

# Pré-requis : groupe docker
if ! getent group docker >/dev/null 2>&1; then
  error "Groupe docker absent — Docker n’est probablement pas installé"
fi

# Utilisateur appelant réel
CALLING_USER="${SUDO_USER:-$(whoami)}"
info "Utilisateur appelant : $CALLING_USER"

# Vérification utilisateur
if ! id "$CALLING_USER" >/dev/null 2>&1; then
  error "Utilisateur $CALLING_USER introuvable"
fi

# Déjà membre ?
if id -nG "$CALLING_USER" | grep -qw docker; then
  success "L’utilisateur $CALLING_USER appartient déjà au groupe docker"
  info "Aucune action nécessaire"
  exit 0
fi

echo ""
echo "⚠️  ACTION EFFECTRICE"
echo "Cette action va :"
echo " - ajouter l’utilisateur '$CALLING_USER' au groupe docker"
echo ""
echo "➡️ Effets à connaître :"
echo " - une reconnexion de l’utilisateur sera nécessaire"
echo " - aucune session existante n’est modifiée"
echo ""

read -rp "❓ Ajouter $CALLING_USER au groupe docker ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Action annulée par l’utilisateur"
  exit 0
}

# Application
usermod -aG docker "$CALLING_USER"
success "Utilisateur $CALLING_USER ajouté au groupe docker"

echo ""
info "ℹ️ Une déconnexion / reconnexion est nécessaire pour appliquer les nouveaux droits"
