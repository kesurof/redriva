#!/usr/bin/env bash
# Action REDRIVA — Mise à jour du code REDRIVA
#
# - Met à jour REDRIVA depuis GitHub (branche main)
# - Agit uniquement sur le code (/opt/redriva)
# - Ne touche PAS aux apps, données, ou configuration
#
# ⚠️ Action effectrice, explicite, rejouable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="/opt/redriva"

source "$BASE_DIR/core/ui.sh"

title "REDRIVA — Mise à jour"

#######################################
# Vérifications préalables
#######################################

if [[ ! -d "$BASE_DIR/.git" ]]; then
  error "REDRIVA n’est pas installé depuis un dépôt Git"
  info "Installation détectée dans : $BASE_DIR"
  info "La mise à jour automatique est impossible"
  exit 1
fi

cd "$BASE_DIR"

#######################################
# Informations Git actuelles
#######################################

CURRENT_BRANCH="$(git branch --show-current)"
CURRENT_COMMIT="$(git rev-parse --short HEAD)"

info "Dossier      : $BASE_DIR"
info "Branche      : $CURRENT_BRANCH"
info "Commit local : $CURRENT_COMMIT"

if [[ "$CURRENT_BRANCH" != "main" ]]; then
  error "Branche non supportée : $CURRENT_BRANCH"
  info "Branche attendue : main"
  exit 1
fi

#######################################
# Vérification des mises à jour
#######################################

echo ""
info "Vérification des mises à jour distantes…"
git fetch origin main

LOCAL_COMMIT="$(git rev-parse HEAD)"
REMOTE_COMMIT="$(git rev-parse origin/main)"

if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
  success "REDRIVA est déjà à jour"
  exit 0
fi

COMMITS_BEHIND="$(git rev-list --count HEAD..origin/main)"

info "$COMMITS_BEHIND commit(s) disponible(s) sur origin/main"

#######################################
# Confirmation utilisateur
#######################################

echo ""
echo "⚠️  ACTION EFFECTRICE"
echo "Cette action va :"
echo " - mettre à jour le code REDRIVA"
echo " - appliquer les changements depuis GitHub"
echo " - sans modifier les apps ni les données hôte"
echo ""

read -rp "❓ Appliquer la mise à jour maintenant ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Mise à jour annulée"
  exit 0
}

#######################################
# Mise à jour
#######################################

info "Application de la mise à jour…"
git pull --ff-only origin main

#######################################
# Normalisation des permissions
#######################################

info "Normalisation des permissions REDRIVA…"

# Actions exécutables
find "$BASE_DIR/actions" -type f -exec chmod 755 {} \;

# Modules et core en lecture seule
find "$BASE_DIR/modules" -type f -exec chmod 644 {} \;
find "$BASE_DIR/core" -type f -exec chmod 644 {} \;
find "$BASE_DIR/menus" -type f -exec chmod 644 {} \;

success "Permissions normalisées"

NEW_COMMIT="$(git rev-parse --short HEAD)"
success "REDRIVA mis à jour avec succès"
info "Nouveau commit : $NEW_COMMIT"

#######################################
# Fin
#######################################

echo ""
success "Mise à jour terminée"
info "Tu peux continuer à utiliser REDRIVA normalement"
