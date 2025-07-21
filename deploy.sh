#!/bin/bash

# Script de déploiement pour Redriva en production
# Ce script télécharge et lance les dernières images Docker

set -e

# Configuration
REGISTRY="ghcr.io"
REPO_NAME="redriva"  # Remplacer par le nom du repo GitHub
GITHUB_USER="your-github-username"  # Remplacer par votre nom d'utilisateur GitHub

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier Docker Compose
if ! command -v docker compose &> /dev/null; then
    log_error "Docker Compose n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Fonction pour télécharger les images
pull_images() {
    local tag=${1:-latest}
    
    log_info "Téléchargement des images Docker (tag: $tag)..."
    
    docker pull "${REGISTRY}/${GITHUB_USER}/${REPO_NAME}/backend:${tag}"
    docker pull "${REGISTRY}/${GITHUB_USER}/${REPO_NAME}/frontend:${tag}"
    
    log_info "Images téléchargées avec succès"
}

# Fonction pour démarrer les services
start_services() {
    local tag=${1:-latest}
    
    log_info "Démarrage des services Redriva..."
    
    # Exporter les variables d'environnement pour docker-compose
    export BACKEND_IMAGE="${REGISTRY}/${GITHUB_USER}/${REPO_NAME}/backend:${tag}"
    export FRONTEND_IMAGE="${REGISTRY}/${GITHUB_USER}/${REPO_NAME}/frontend:${tag}"
    
    # Utiliser docker-compose.prod.yml
    docker compose -f docker-compose.prod.yml up -d
    
    log_info "Services démarrés avec succès"
}

# Fonction pour arrêter les services
stop_services() {
    log_info "Arrêt des services Redriva..."
    docker compose -f docker-compose.prod.yml down
    log_info "Services arrêtés"
}

# Fonction pour mettre à jour
update_services() {
    local tag=${1:-latest}
    
    log_info "Mise à jour de Redriva vers la version $tag..."
    
    # Arrêter les services
    stop_services
    
    # Télécharger les nouvelles images
    pull_images "$tag"
    
    # Redémarrer les services
    start_services "$tag"
    
    # Nettoyer les anciennes images
    log_info "Nettoyage des anciennes images..."
    docker image prune -f
    
    log_info "Mise à jour terminée avec succès"
}

# Fonction pour afficher le statut
show_status() {
    log_info "Statut des services Redriva:"
    docker compose -f docker-compose.prod.yml ps
}

# Fonction pour afficher les logs
show_logs() {
    local service=${1:-}
    
    if [ -n "$service" ]; then
        docker compose -f docker-compose.prod.yml logs -f "$service"
    else
        docker compose -f docker-compose.prod.yml logs -f
    fi
}

# Fonction d'aide
show_help() {
    cat << EOF
Utilisation: $0 [COMMAND] [OPTIONS]

COMMANDES:
    pull [TAG]      Télécharger les images Docker (défaut: latest)
    start [TAG]     Démarrer les services (défaut: latest)
    stop            Arrêter les services
    update [TAG]    Mettre à jour vers une nouvelle version (défaut: latest)
    status          Afficher le statut des services
    logs [SERVICE]  Afficher les logs (optionnel: service spécifique)
    help            Afficher cette aide

EXEMPLES:
    $0 update v1.2.0    # Mettre à jour vers la version v1.2.0
    $0 start latest     # Démarrer avec les dernières images
    $0 logs frontend    # Afficher les logs du frontend
    $0 status           # Afficher le statut

CONFIGURATION:
    Modifiez les variables GITHUB_USER et REPO_NAME en haut de ce script
    pour correspondre à votre configuration GitHub.
EOF
}

# Parser les arguments
case "${1:-help}" in
    pull)
        pull_images "${2:-latest}"
        ;;
    start)
        start_services "${2:-latest}"
        ;;
    stop)
        stop_services
        ;;
    update)
        update_services "${2:-latest}"
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "${2:-}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Commande inconnue: $1"
        show_help
        exit 1
        ;;
esac
