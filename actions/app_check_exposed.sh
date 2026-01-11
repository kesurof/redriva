#!/usr/bin/env bash
# Action REDRIVA — Vérification exposition applicative
# Diagnostic : l'application est-elle accessible publiquement via Traefik ?
#
# ❌ Aucun effet système
# ❌ Aucune orchestration
# ✅ Lisible, relançable, factuel

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/app_engine.sh"

title "Application — Vérification exposition HTTPS"

#######################################
# Sélection de l'application
#######################################
mapfile -t APPS < <(app_list)

if [[ "${#APPS[@]}" -eq 0 ]]; then
  error "Aucune application disponible"
fi

echo "Applications disponibles :"
echo ""

i=1
for app in "${APPS[@]}"; do
  unset APP_NAME APP_DESCRIPTION
  app_load_conf "$app" || continue
  printf " %2d) %-15s — %s\n" "$i" "$APP_NAME" "$APP_DESCRIPTION"
  ((i++))
done

echo ""
read -rp "👉 Choix de l'application : " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#APPS[@]} )); then
  error "Choix invalide"
fi

APP_SELECTED="${APPS[$((choice - 1))]}"

#######################################
# Chargement configuration app
#######################################
unset APP_NAME APP_DESCRIPTION APP_DEFAULT_DOMAIN APP_DOMAIN
app_load_conf "$APP_SELECTED" || error "Impossible de charger la configuration de l'application"

APP_DOMAIN="$(render_domain "$APP_DEFAULT_DOMAIN")" \
  || error "Impossible de déterminer le domaine (CF_DOMAIN manquant)"

TARGET_DIR="$(app_target_dir "$APP_SELECTED")"
CONTAINER_NAME="$APP_NAME"

info "Application : $APP_NAME"
info "Domaine     : $APP_DOMAIN"
info "Dossier     : $TARGET_DIR"

#######################################
# 1️⃣ Conteneur Docker
#######################################
info "Vérification conteneur Docker…"

if docker ps --format '{{.Names}}' | grep -qw "$CONTAINER_NAME"; then
  success "Conteneur '$CONTAINER_NAME' actif"
else
  error "Conteneur '$CONTAINER_NAME' non actif"
fi

#######################################
# 2️⃣ Labels Traefik
#######################################
info "Vérification labels Traefik…"

LABELS="$(docker inspect "$CONTAINER_NAME" --format '{{ json .Config.Labels }}')"

echo "$LABELS" | grep -q 'traefik.enable' \
  && success "traefik.enable présent" \
  || error "Label traefik.enable absent"

echo "$LABELS" | grep -q 'traefik.http.routers' \
  && success "Router Traefik détecté" \
  || error "Aucun router Traefik détecté"

#######################################
# 3️⃣ Résolution DNS
#######################################
info "Vérification DNS ($APP_DOMAIN)…"

if getent hosts "$APP_DOMAIN" >/dev/null; then
  success "DNS résout $APP_DOMAIN"
else
  error "DNS ne résout pas $APP_DOMAIN"
fi

#######################################
# 4️⃣ Test HTTPS réel
#######################################
info "Test HTTPS public : https://$APP_DOMAIN"

HTTP_CODE="$(curl -sk -o /dev/null -w "%{http_code}" "https://$APP_DOMAIN" || true)"

if [[ "$HTTP_CODE" =~ ^2|3 ]]; then
  success "Application accessible (HTTP $HTTP_CODE)"
else
  error "Application non accessible (HTTP $HTTP_CODE)"
fi

#######################################
# RÉSULTAT FINAL
#######################################
echo ""
success "Application '$APP_NAME' exposée correctement en HTTPS"
