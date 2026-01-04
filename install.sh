#!/usr/bin/env bash
################################################################################
#                      REDRIVA - Installation Script                           #
#                            Version 3.0 (Python)                              #
#                                                                              #
# Installation automatique de Redriva avec tous les prérequis                 #
# Usage: bash install.sh                                                       #
################################################################################

set -Eeuo pipefail

# ============================================================================
# VARIABLES GLOBALES
# ============================================================================

REDRIVA_PROJECT_HOME="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REDRIVA_USER_HOME="${HOME}/my_redriva"

# Couleurs ANSI (à utiliser UNIQUEMENT via printf '%b')
NORMAL='\033[0m'
BOLD='\033[1m'
BLUE='\033[94m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
CYAN='\033[96m'

# ============================================================================
# FONCTIONS DE LOG (CENTRALISÉES)
# ============================================================================

log_info()  { printf '%b\n' "${BLUE}ℹ${NORMAL} $1"; }
log_ok()    { printf '%b\n' "${GREEN}✓${NORMAL} $1"; }
log_warn()  { printf '%b\n' "${YELLOW}⚠${NORMAL} $1"; }
log_error() { printf '%b\n' "${RED}✗${NORMAL} $1" >&2; }

log_title() {
    printf '\n%b\n' "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NORMAL}"
    printf '%b\n'  "${CYAN}${BOLD}  $1${NORMAL}"
    printf '%b\n'  "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NORMAL}"
}

# ============================================================================
# DÉTECTION SYSTÈME
# ============================================================================

detect_system() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        [[ -f /etc/debian_version ]] && echo "debian" && return
        [[ -f /etc/redhat-release ]] && echo "redhat" && return
        [[ -f /etc/arch-release ]] && echo "arch" && return
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# ============================================================================
# VÉRIFICATIONS PRÉREQUIS
# ============================================================================

check_requirements() {
    log_title "Vérification des prérequis"

    local has_error=0

    if command -v python3 >/dev/null 2>&1; then
        log_ok "Python 3: $(python3 --version | awk '{print $2}')"
    else
        log_error "Python 3 n'est pas installé"
        has_error=1
    fi

    if command -v docker >/dev/null 2>&1; then
        log_ok "Docker: $(docker --version | awk '{print $3}' | tr -d ,)"
    else
        log_error "Docker n'est pas installé"
        has_error=1
    fi

    if command -v git >/dev/null 2>&1; then
        log_ok "Git: $(git --version | awk '{print $3}')"
    else
        log_warn "Git non installé (optionnel)"
    fi

    [[ $has_error -eq 0 ]]
}

# ============================================================================
# INSTALLATION DÉPENDANCES
# ============================================================================

install_dependencies() {
    log_title "Installation des dépendances"

    case "$(detect_system)" in
        debian)
            log_info "Système détecté: Debian/Ubuntu"
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip docker.io git curl
            ;;
        redhat)
            log_info "Système détecté: RedHat/CentOS"
            sudo yum install -y python3 python3-pip docker git curl
            ;;
        macos)
            log_info "Système détecté: macOS"
            command -v brew >/dev/null 2>&1 || {
                log_error "Homebrew requis"
                return 1
            }
            brew install python docker git
            ;;
        *)
            log_warn "Système non reconnu – installation manuelle requise"
            return 1
            ;;
    esac

    log_ok "Dépendances installées"
}

# ============================================================================
# STRUCTURE DES RÉPERTOIRES
# ============================================================================

create_directories() {
    log_title "Création de la structure des répertoires"

    mkdir -p \
        "${REDRIVA_PROJECT_HOME}/bin" \
        "${REDRIVA_PROJECT_HOME}/lib" \
        "${REDRIVA_PROJECT_HOME}/templates" \
        "${REDRIVA_PROJECT_HOME}/docs" \
        "${REDRIVA_USER_HOME}/config" \
        "${REDRIVA_USER_HOME}/data"/{traefik/acme,radarr,sonarr,qbittorrent,plex} \
        "${REDRIVA_USER_HOME}/state"

    log_ok "Répertoires créés: ${REDRIVA_USER_HOME}"
}

# ============================================================================
# CONFIGURATION DOCKER
# ============================================================================

setup_docker() {
    log_title "Configuration Docker"

    docker ps >/dev/null 2>&1 || {
        log_warn "Docker non accessible (groupe docker requis)"
        log_info "Commande suggérée: sudo usermod -aG docker $USER"
        return 1
    }

    log_ok "Docker accessible"
}

# ============================================================================
# LIEN SYMBOLIQUE
# ============================================================================

setup_symlink() {
    log_title "Configuration du lien symbolique"

    chmod +x "${REDRIVA_PROJECT_HOME}/bin/redriva.sh"
    sudo ln -sf "${REDRIVA_PROJECT_HOME}/bin/redriva.sh" /usr/local/bin/redriva

    log_ok "Lien symbolique créé: /usr/local/bin/redriva"
}

# ============================================================================
# VÉRIFICATION INSTALLATION
# ============================================================================

verify_installation() {
    log_title "Vérification de l'installation"

    command -v redriva >/dev/null 2>&1 \
        && log_ok "Commande 'redriva' disponible" \
        || return 1

    if ! redriva list >/dev/null 2>&1; then
        log_warn "redriva fonctionne mais nécessite une configuration (normal)"
    else
        log_ok "redriva opérationnel"
    fi
}

# ============================================================================
# PROCHAINES ÉTAPES (UI PROPRE)
# ============================================================================

display_next_steps() {
    log_title "Prochaines étapes"

    printf '%b\n' "
${BOLD}Étapes recommandées${NORMAL}

  1. Configuration du core (Traefik + OAuth2)
     redriva setup-core

  2. Lister les applications disponibles
     redriva list

  3. Voir les informations d'une application
     redriva info radarr

  4. Installer une application
     redriva install radarr

  5. Afficher les logs d'une application
     redriva logs radarr


${BOLD}Fichiers de configuration${NORMAL}
  ${REDRIVA_USER_HOME}/config/core.env     secrets
  ${REDRIVA_USER_HOME}/config/             configuration générale


${BOLD}Données Docker${NORMAL}
  ${REDRIVA_USER_HOME}/data/               données persistantes


${BOLD}Documentation${NORMAL}
  ${REDRIVA_PROJECT_HOME}/README.md
  ${REDRIVA_PROJECT_HOME}/INSTALLATION.md
  ${REDRIVA_PROJECT_HOME}/SETUP.md
"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    clear

    cat <<'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                    🚀 REDRIVA - Installation v3.0                         ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF

    log_info "Projet      : ${REDRIVA_PROJECT_HOME}"
    log_info "Utilisateur : ${REDRIVA_USER_HOME}"
    log_info "Système     : $(detect_system)"

    check_requirements || exit 1
    install_dependencies || log_warn "Certaines dépendances peuvent manquer"
    create_directories
    setup_docker || log_warn "Docker partiellement configuré"
    setup_symlink
    verify_installation || exit 1
    display_next_steps

    printf '\n%b\n' "${GREEN}${BOLD}✔ Installation terminée avec succès${NORMAL}"
    echo
    echo "Pour plus d'informations :"
    echo "  https://github.com/kesuro/redriva"
}

# ============================================================================
# EXÉCUTION
# ============================================================================

main "$@"
