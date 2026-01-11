#!/usr/bin/env bash
# Action REDRIVA — Configuration identité runtime
# Définit l'utilisateur système utilisé pour les conteneurs Docker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/user_identity.sh"

title "REDRIVA — Configuration identité runtime"

#######################################
# Demande utilisateur
#######################################
ask_value "RUNTIME_USER" "Utilisateur système pour les conteneurs Docker" "no"

#######################################
# Vérification
#######################################
if ! user_identity_check; then
  error "Utilisateur invalide ou inexistant"
fi

#######################################
# Affichage résultat
#######################################
USER="$(config_get RUNTIME_USER)"
UID="$(user_identity_get_uid)"
GID="$(user_identity_get_gid)"

success "Identité runtime configurée"
info "Utilisateur : $USER"
info "UID         : $UID"
info "GID         : $GID"
