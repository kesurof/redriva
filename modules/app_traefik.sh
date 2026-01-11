#!/usr/bin/env bash
# Module REDRIVA — Intégration Traefik pour applications
# Rôle : gérer les middlewares Traefik au niveau des apps

#######################################
# Appliquer un middleware Traefik
# $1 = app
# $2 = middleware (ex: auth-basic@file)
#######################################
app_traefik_apply_middleware() {
  local app="$1"
  local middleware="$2"

  local compose
  compose="$(app_target_dir "$app")/docker-compose.yml"

  [[ -f "$compose" ]] || return 1

  sed -i -E \
    "s|(traefik.http.routers.[^.]+.middlewares=)[^\"]*\"|\1$middleware\"|" \
    "$compose"
}


#######################################
# Supprimer un middleware Traefik
#######################################
app_traefik_remove_middleware() {
  local app="$1"

  local compose
  compose="$(app_target_dir "$app")/docker-compose.yml"

  [[ -f "$compose" ]] || return 1

  sed -i -E \
    "/traefik.http.routers.[^.]+.middlewares=/d" \
    "$compose"
}

#######################################
# Vérifier la présence d'un middleware
#######################################
app_traefik_has_middleware() {
  local app="$1"
  local middleware="$2"

  local compose
  compose="$(app_target_dir "$app")/docker-compose.yml"

  grep -q "$middleware" "$compose"
}
