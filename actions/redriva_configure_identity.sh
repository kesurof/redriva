#!/usr/bin/env bash
# Action REDRIVA — Configuration identité runtime
# Sélection de l'utilisateur système réel pour Docker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/user_identity.sh"

title "REDRIVA — Configuration identité runtime"

#######################################
# Liste des utilisateurs système valides
#######################################
mapfile -t USERS < <(
  getent passwd |
    awk -F: '$3 >= 1000 && $3 < 65534 { print $1 }'
)

if [[ "${#USERS[@]}" -eq 0 ]]; then
  error "Aucun utilisateur système valide trouvé"
fi

echo "Utilisateurs système disponibles :"
echo ""

i=1
for u in "${USERS[@]}"; do
  printf " %2d) %s\n" "$i" "$u"
  ((i++))
done

echo ""
read -rp "👉 Choix de l'utilisateur runtime : " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#USERS[@]} )); then
  error "Choix invalide"
fi

RUNTIME_USER="${USERS[$((choice - 1))]}"
config_set "RUNTIME_USER" "$RUNTIME_USER"

#######################################
# Vérification
#######################################
if ! user_identity_check; then
  error "Utilisateur sélectionné invalide"
fi

#######################################
# Affichage résultat
#######################################
RUNTIME_UID="$(user_identity_get_uid)"
RUNTIME_GID="$(user_identity_get_gid)"

success "Identité runtime configurée"
info "Utilisateur : $RUNTIME_USER"
info "UID         : $RUNTIME_UID"
info "GID         : $RUNTIME_GID"
