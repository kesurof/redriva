#!/usr/bin/env bash
# Action REDRIVA — Installation système de REDRIVA
#
# - Installe le projet REDRIVA dans /opt/redriva
# - Installe le lanceur système /usr/local/bin/redriva
# - Sépare strictement outil / données hôte
#
# ⚠️ Action effectrice, rejouable, explicite

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "REDRIVA — Installation système"

INSTALL_DIR="/opt/redriva"
LAUNCHER="/usr/local/bin/redriva"

echo ""
echo "⚠️  ACTION EFFECTRICE"
echo "Cette action va :"
echo " - installer REDRIVA dans : $INSTALL_DIR"
echo " - installer le lanceur : $LAUNCHER"
echo ""
echo "Aucune donnée applicative (/opt/docker) ne sera modifiée."
echo ""

read -rp "❓ Continuer l'installation de REDRIVA ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Installation annulée"
  exit 0
}

#######################################
# Installation du projet REDRIVA
#######################################

info "Installation du projet REDRIVA dans $INSTALL_DIR…"

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -a "$BASE_DIR/"* "$INSTALL_DIR/"

success "Projet installé dans $INSTALL_DIR"

#######################################
# Installation du lanceur système
#######################################

info "Installation du lanceur système $LAUNCHER…"

cat > "$LAUNCHER" <<'EOF'
#!/usr/bin/env bash
set -e

BASE_DIR="/opt/redriva"

# Auto-élévation root
if [[ "$EUID" -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

# Chargement du core (fonctions uniquement)
source "$BASE_DIR/core/loader.sh"

# Dispatch des commandes
case "$1" in
  menu|"")
    redriva_menu
    ;;
  action)
    shift
    redriva_action "$@"
    ;;
  list)
    redriva_list_actions
    ;;
  *)
    echo "Usage:"
    echo "  redriva menu"
    echo "  redriva action <name>"
    echo "  redriva list"
    exit 1
    ;;
esac
EOF

chmod 755 "$LAUNCHER"

success "Lanceur installé : $LAUNCHER"

echo ""
success "REDRIVA est maintenant installé comme outil système"
info "Utilisation : redriva menu"
