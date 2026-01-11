#!/usr/bin/env bash
# Module REDRIVA — User identity
#
# Gestion stricte de l'identité runtime (UID / GID)
# Basée EXCLUSIVEMENT sur la config REDRIVA
#
# ❌ aucune supposition
# ❌ aucun fallback implicite
# ✅ échec explicite si incohérence

#######################################
# Récupération utilisateur runtime
#######################################
user_identity_get_user() {
  local user
  user="$(config_get RUNTIME_USER)"

  [[ -z "$user" ]] && return 1
  echo "$user"
}

#######################################
# Vérifie que l'utilisateur existe
#######################################
user_identity_user_exists() {
  local user
  user="$(user_identity_get_user)" || return 1

  getent passwd "$user" >/dev/null 2>&1
}

#######################################
# UID réel
#######################################
user_identity_get_uid() {
  local user
  user="$(user_identity_get_user)" || return 1

  id -u "$user" 2>/dev/null
}

#######################################
# GID réel
#######################################
user_identity_get_gid() {
  local user
  user="$(user_identity_get_user)" || return 1

  id -g "$user" 2>/dev/null
}

#######################################
# Vérification globale
#######################################
user_identity_check() {
  local user uid gid

  user="$(user_identity_get_user)" || return 1
  user_identity_user_exists || return 1

  uid="$(user_identity_get_uid)" || return 1
  gid="$(user_identity_get_gid)" || return 1

  [[ "$uid" =~ ^[0-9]+$ ]] || return 1
  [[ "$gid" =~ ^[0-9]+$ ]] || return 1

  return 0
}
