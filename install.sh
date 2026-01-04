#!/bin/bash

################################################################################
#                      REDRIVA - Installation Script                           #
#                            Version 3.0 (Python)                              #
#                                                                              #
# Installation automatique de Redriva avec tous les prérequis                 #
# Usage: bash install.sh                                                       #
################################################################################

set -e

# ============================================================================
# VARIABLES GLOBALES
# ============================================================================

REDRIVA_PROJECT_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REDRIVA_USER_HOME="${HOME}/my_redriva"

NORMAL='\033[0m'
BOLD='\033[1m'
BLUE='\033[94m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
CYAN='\033[96m'

# ============================================================================
# FONCTIONS DE LOG
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NORMAL} $1"
}

log_ok() {
    echo -e "${GREEN}✓${NORMAL} $1"
}

log_error() {
    echo -e "${RED}✗${NORMAL} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}⚠${NORMAL} $1"
}

log_title() {
    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NORMAL}"
    echo -e "${CYAN}${BOLD}  $1${NORMAL}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NORMAL}"
}

# ============================================================================
# DÉTECTION SYSTÈME
# ============================================================================

detect_system() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        else
            echo "linux"
        fi
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
    
    # Python 3
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 n'est pas installé"
        has_error=1
    else
        local py_version=$(python3 --version 2>&1 | awk '{print $2}')
        log_ok "Python 3: ${py_version}"
    fi
    
    # Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        has_error=1
    else
        local docker_version=$(docker --version | awk '{print $3}' | sed 's/,//')
        log_ok "Docker: ${docker_version}"
    fi
    
    # Git
    if ! command -v git &> /dev/null; then
        log_warn "Git n'est pas installé (optionnel)"
    else
        local git_version=$(git --version | awk '{print $3}')
        log_ok "Git: ${git_version}"
    fi
    
    if [ $has_error -eq 1 ]; then
        return 1
    fi
    
    return 0
}

# ============================================================================
# INSTALLATION DÉPENDANCES
# ============================================================================

install_dependencies() {
    log_title "Installation des dépendances"
    
    local system=$(detect_system)
    
    case $system in
        debian)
            log_info "Système détecté: Debian/Ubuntu"
            sudo apt-get update
            sudo apt-get install -y \
                python3 \
                python3-pip \
                docker.io \
                git \
                curl
            ;;
        redhat)
            log_info "Système détecté: RedHat/CentOS"
            sudo yum install -y \
                python3 \
                python3-pip \
                docker \
                git \
                curl
            ;;
        macos)
            log_info "Système détecté: macOS"
            if ! command -v brew &> /dev/null; then
                log_error "Homebrew n'est pas installé"
                return 1
            fi
            brew install python docker git
            ;;
        *)
            log_warn "Système non reconnu, installation manuelle requise"
            return 1
            ;;
    esac
    
    log_ok "Dépendances installées"
    return 0
}

# ============================================================================
# CRÉATION STRUCTURE RÉPERTOIRES
# ============================================================================

create_directories() {
    log_title "Création de la structure des répertoires"
    
    # Répertoires projet
    mkdir -p "${REDRIVA_PROJECT_HOME}/bin"
    mkdir -p "${REDRIVA_PROJECT_HOME}/lib"
    mkdir -p "${REDRIVA_PROJECT_HOME}/templates"
    mkdir -p "${REDRIVA_PROJECT_HOME}/docs"
    
    # Répertoires utilisateur (VISIBLE!)
    mkdir -p "${REDRIVA_USER_HOME}/config"
    mkdir -p "${REDRIVA_USER_HOME}/data/traefik/acme"
    mkdir -p "${REDRIVA_USER_HOME}/data/radarr"
    mkdir -p "${REDRIVA_USER_HOME}/data/sonarr"
    mkdir -p "${REDRIVA_USER_HOME}/data/qbittorrent"
    mkdir -p "${REDRIVA_USER_HOME}/data/plex"
    mkdir -p "${REDRIVA_USER_HOME}/state"
    
    log_ok "Répertoires créés: ${REDRIVA_USER_HOME}"
}

# ============================================================================
# CONFIGURATION DOCKER
# ============================================================================

setup_docker() {
    log_title "Configuration Docker"
    
    # Vérifier que Docker est accessible
    if ! docker ps &> /dev/null; then
        log_error "Docker n'est pas accessible"
        log_info "Essayez: sudo usermod -aG docker $USER"
        return 1
    fi
    
    # Ajouter l'utilisateur au groupe docker
    if ! groups $USER | grep -q docker; then
        log_info "Ajout de l'utilisateur au groupe docker..."
        sudo usermod -aG docker $USER
        log_warn "Changement de groupe nécessaire. Exécutez: newgrp docker"
    fi
    
    log_ok "Docker configuré"
    return 0
}

# ============================================================================
# CRÉATION LIEN SYMBOLIQUE
# ============================================================================

setup_symlink() {
    log_title "Configuration du lien symbolique"
    
    # Rendre redriva.sh exécutable
    chmod +x "${REDRIVA_PROJECT_HOME}/bin/redriva.sh"
    
    # Créer ou mettre à jour le lien
    if [ -L "/usr/local/bin/redriva" ]; then
        sudo rm /usr/local/bin/redriva
    fi
    
    sudo ln -s "${REDRIVA_PROJECT_HOME}/bin/redriva.sh" /usr/local/bin/redriva
    
    log_ok "Lien symbolique créé: /usr/local/bin/redriva"
}

# ============================================================================
# VÉRIFICATION INSTALLATION
# ============================================================================

verify_installation() {
    log_title "Vérification de l'installation"
    
    local has_error=0
    
    # Vérifier redriva.sh
    if [ ! -f "${REDRIVA_PROJECT_HOME}/bin/redriva.sh" ]; then
        log_error "redriva.sh introuvable"
        has_error=1
    else
        log_ok "redriva.sh trouvé"
    fi
    
    # Vérifier redriva-core.py
    if [ ! -f "${REDRIVA_PROJECT_HOME}/bin/redriva-core.py" ]; then
        log_error "redriva-core.py introuvable"
        has_error=1
    else
        log_ok "redriva-core.py trouvé"
    fi
    
    # Vérifier le lien symbolique
    if [ ! -L "/usr/local/bin/redriva" ]; then
        log_error "Lien symbolique /usr/local/bin/redriva introuvable"
        has_error=1
    else
        log_ok "Lien symbolique /usr/local/bin/redriva OK"
    fi
    
    # Test de la commande
    if redriva help > /dev/null 2>&1; then
        log_ok "Commande 'redriva' fonctionnelle"
    else
        log_error "Commande 'redriva' non fonctionnelle"
        has_error=1
    fi
    
    if [ $has_error -eq 1 ]; then
        return 1
    fi
    
    return 0
}

# ============================================================================
# AFFICHAGE PROCHAINES ÉTAPES
# ============================================================================

display_next_steps() {
    log_title "Prochaines étapes"
    
    cat << EOF

${BOLD}1. Configuration du core (Traefik + OAuth2)${NORMAL}
   redriva setup-core

${BOLD}2. Lister les applications disponibles${NORMAL}
   redriva list

${BOLD}3. Voir les infos d'une application${NORMAL}
   redriva info radarr

${BOLD}4. Installer une application${NORMAL}
   redriva install radarr

${BOLD}5. Voir les logs${NORMAL}
   redriva logs radarr

${BOLD}Fichiers de configuration:${NORMAL}
   ${REDRIVA_USER_HOME}/config/core.env     (secrets)
   ${REDRIVA_USER_HOME}/config/             (configuration)

${BOLD}Données Docker:${NORMAL}
   ${REDRIVA_USER_HOME}/data/                (données des apps)

${BOLD}Documentation:${NORMAL}
   ${REDRIVA_PROJECT_HOME}/README.md
   ${REDRIVA_PROJECT_HOME}/INSTALLATION.md
   ${REDRIVA_PROJECT_HOME}/SETUP.md

EOF
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    clear
    
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                    🚀 REDRIVA - Installation v3.0                         ║
║                                                                            ║
║              Gestionnaire d'Applications Docker avec Traefik               ║
║                         et Authentification OAuth2                        ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF

    log_info "Répertoire du projet: ${REDRIVA_PROJECT_HOME}"
    log_info "Répertoire utilisateur: ${REDRIVA_USER_HOME}"
    log_info "Système détecté: $(detect_system)"
    
    # Étapes d'installation
    check_requirements || {
        log_error "Prérequis manquants"
        exit 1
    }
    
    install_dependencies || {
        log_warn "Installation des dépendances incomplète"
    }
    
    create_directories
    
    setup_docker || {
        log_warn "Configuration Docker incomplète"
    }
    
    setup_symlink
    
    verify_installation || {
        log_error "Vérification échouée"
        exit 1
    }
    
    display_next_steps
    
    cat << EOF

${GREEN}${BOLD}Installation terminée avec succès!${NORMAL}

Pour plus d'informations:
  https://github.com/kesuro/redriva

EOF
}

# ============================================================================
# EXÉCUTION
# ============================================================================

main "$@"
