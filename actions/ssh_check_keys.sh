#!/usr/bin/env bash
# Action REDRIVA — Vérification des clés SSH
# Diagnostic uniquement, aucun effet système

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "SSH — Vérification des clés"

found_user=false

# Format /etc/passwd :
# user:x:uid:gid:comment:home:shell
while IFS=: read -r user _ uid _ _ home shell; do
  # Filtrage des comptes non humains
  [[ "$uid" -lt 1000 ]] && continue
  [[ "$user" == "nobody" ]] && continue
  [[ "$home" == "/" ]] && continue
  [[ ! -d "$home" ]] && continue
  [[ "$shell" =~ (nologin|false)$ ]] && continue

  found_user=true
  echo ""
  info "Utilisateur : $user"

  SSH_DIR="$home/.ssh"
  AUTH_KEYS="$SSH_DIR/authorized_keys"

  if [[ ! -d "$SSH_DIR" ]]; then
    error "Dossier .ssh absent ($SSH_DIR)"
    continue
  fi

  if [[ ! -f "$AUTH_KEYS" ]]; then
    error "authorized_keys absent"
    continue
  fi

  success "Clé SSH présente"

  perms="$(stat -c %a "$AUTH_KEYS")"
  owner="$(stat -c %U "$AUTH_KEYS")"

  info "Permissions authorized_keys : $perms"
  info "Propriétaire : $owner"

  [[ "$perms" == "600" ]] \
    && success "Permissions correctes" \
    || error "Permissions recommandées : 600"

  [[ "$owner" == "$user" ]] \
    && success "Propriétaire correct" \
    || error "Propriétaire incorrect"

done < /etc/passwd

if [[ "$found_user" == false ]]; then
  error "Aucun utilisateur standard trouvé"
fi
