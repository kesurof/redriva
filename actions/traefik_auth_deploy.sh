#!/usr/bin/env bash
# Action REDRIVA — Déploiement Auth Traefik (Basic Auth)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"

title "Traefik — Déploiement Auth Basic"

TRAEFIK_DIR="/opt/docker/traefik"
CONFIG_DIR="$TRAEFIK_DIR/config"
AUTH_DIR="/opt/docker/auth"
AUTH_FILE="$CONFIG_DIR/auth-basic.yml"
HTPASSWD_FILE="$AUTH_DIR/users.htpasswd"

#######################################
# Confirmation
#######################################
echo ""
echo "⚠️  ACTION EFFECTRICE"
echo "Cette action va :"
echo " - créer un middleware auth-basic"
echo " - activer l’authentification HTTP Basic"
echo " - recharger Traefik"
echo ""

read -rp "❓ Continuer ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || exit 0

#######################################
# Pré-requis
#######################################
command -v htpasswd >/dev/null 2>&1 \
  || error "htpasswd absent (installe apache2-utils)"

#######################################
# Utilisateur auth
#######################################
ask_value "AUTH_USER" "Utilisateur d’authentification" "no"
AUTH_USER="$(config_get AUTH_USER)"

mkdir -p "$AUTH_DIR"
chmod 700 "$AUTH_DIR"

if [[ ! -f "$HTPASSWD_FILE" ]]; then
  htpasswd -c "$HTPASSWD_FILE" "$AUTH_USER"
else
  read -rp "Modifier le mot de passe ? [y/N] : " r
  [[ "$r" =~ ^[yY]$ ]] && htpasswd "$HTPASSWD_FILE" "$AUTH_USER"
fi

chmod 600 "$HTPASSWD_FILE"

#######################################
# Middleware Traefik
#######################################
mkdir -p "$CONFIG_DIR"

cat > "$AUTH_FILE" <<EOF
http:
  middlewares:
    auth-basic:
      basicAuth:
        usersFile: /auth/users.htpasswd
        realm: "Accès protégé"
EOF

#######################################
# Docker compose Traefik
#######################################
if ! grep -q 'providers.file.directory' "$TRAEFIK_DIR/docker-compose.yml"; then
  sed -i '/providers.docker.exposedbydefault=false/a \
      - "--providers.file.directory=/config"\n\
      - "--providers.file.watch=true"' "$TRAEFIK_DIR/docker-compose.yml"
fi

if ! grep -q '/auth:/auth' "$TRAEFIK_DIR/docker-compose.yml"; then
  sed -i '/volumes:/a \
      - ../auth:/auth:ro\n\
      - ./config:/config:ro' "$TRAEFIK_DIR/docker-compose.yml"
fi

#######################################
# Rechargement Traefik
#######################################
info "Rechargement Traefik…"
(
  cd "$TRAEFIK_DIR"
  docker compose up -d
)

success "Auth Traefik déployée"
