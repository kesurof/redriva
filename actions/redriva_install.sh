#!/usr/bin/env bash
# Action REDRIVA — Installation système de REDRIVA (via Git)
#
# - Clone REDRIVA dans /opt/redriva
# - Branche de référence : main
# - Installe le lanceur système /usr/local/bin/redriva
#
# ⚠️ Action effectrice, explicite, rejouable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/ui.sh"

title "REDRIVA — Installation système (Git)"

INSTALL_DIR="/opt/redriva"
LAUNCHER="/usr/local/bin/redriva"
BRANCH="main"

#######################################
# Détection de l’URL Git
#######################################

if [[ ! -d "$BASE_DIR/.git" ]]; then
  error "Le projet courant n’est pas un dépôt Git"
  info "Impossible de déterminer l’URL distante"
  exit 1
fi

GIT_URL="$(git -C "$BASE_DIR" remote get-url origin)"

info "Dépôt Git : $GIT_URL"
info "Branche   : $BRANCH"
info "Cible     : $INSTALL_DIR"

echo ""
echo "⚠️  ACTION EFFECTRICE"
echo "Cette action va :"
echo " - installer REDRIVA dans $INSTALL_DIR via git"
echo " - installer le lanceur système $LAUNCHER"
echo " - ne PAS toucher aux applications ni aux données hôte"
echo ""

read -rp "❓ Continuer l'installation de REDRIVA ? [y/N] : " confirm
[[ "$confirm" =~ ^[yY]$ ]] || {
  info "Installation annulée"
  exit 0
}

#######################################
# Installation / mise à jour du dépôt
#######################################

if [[ -d "$INSTALL_DIR/.git" ]]; then
  info "REDRIVA déjà installé via Git — mise à jour du dépôt…"
  cd "$INSTALL_DIR"
  git fetch origin "$BRANCH"
  git checkout "$BRANCH"
  git pull --ff-only origin "$BRANCH"

elif [[ -d "$INSTALL_DIR" ]]; then
  echo ""
  info "⚠️  Le dossier $INSTALL_DIR existe mais n’est pas un dépôt Git"
  info "Une installation propre est nécessaire pour activer les mises à jour"

  read -rp "❓ Supprimer $INSTALL_DIR et réinstaller REDRIVA via Git ? [y/N] : " wipe
  [[ "$wipe" =~ ^[yY]$ ]] || {
    info "Installation annulée"
    exit 0
  }

  rm -rf "$INSTALL_DIR"
  info "Installation initiale de REDRIVA…"
  git clone --branch "$BRANCH" "$GIT_URL" "$INSTALL_DIR"

else
  info "Installation initiale de REDRIVA…"
  git clone --branch "$BRANCH" "$GIT_URL" "$INSTALL_DIR"
fi

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
success "REDRIVA est maintenant installé via Git"
info "Utilisation : redriva menu"
