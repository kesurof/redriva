#!/bin/bash

# Script de déploiement en production
# Usage: ./scripts/deploy-prod.sh [version]

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="redriva"
COMPOSE_FILE="docker-compose.prod.yml"
ENV_FILE=".env.prod"
BACKUP_DIR="./backups"

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifications préalables
check_requirements() {
    log_info "Vérification des prérequis..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    if [ ! -f "$ENV_FILE" ]; then
        log_error "Fichier d'environnement $ENV_FILE manquant"
        log_info "Copiez .env.prod.example vers $ENV_FILE et configurez-le"
        exit 1
    fi
    
    log_success "Prérequis vérifiés"
}

# Sauvegarde des données
backup_data() {
    log_info "Sauvegarde des données..."
    
    BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    
    mkdir -p "$BACKUP_PATH"
    
    # Sauvegarde des volumes Docker
    docker run --rm \
        -v redriva-data:/source \
        -v "$(pwd)/$BACKUP_PATH":/backup \
        alpine tar czf /backup/data.tar.gz -C /source .
    
    docker run --rm \
        -v redriva-logs:/source \
        -v "$(pwd)/$BACKUP_PATH":/backup \
        alpine tar czf /backup/logs.tar.gz -C /source .
    
    log_success "Sauvegarde créée: $BACKUP_PATH"
}

# Déploiement
deploy() {
    local VERSION=${1:-latest}
    
    log_info "Déploiement de la version: $VERSION"
    
    # Arrêt en douceur des services
    log_info "Arrêt des services actuels..."
    docker-compose -f "$COMPOSE_FILE" down --timeout 30
    
    # Nettoyage des images orphelines
    log_info "Nettoyage des images..."
    docker image prune -f
    
    # Pull des nouvelles images
    log_info "Téléchargement des nouvelles images..."
    if [ "$VERSION" != "latest" ]; then
        export TAG="$VERSION"
    fi
    docker-compose -f "$COMPOSE_FILE" pull
    
    # Démarrage des services
    log_info "Démarrage des services..."
    docker-compose -f "$COMPOSE_FILE" up -d
    
    # Attendre que les services soient prêts
    log_info "Attente de la disponibilité des services..."
    sleep 10
    
    # Vérification de santé
    if health_check; then
        log_success "Déploiement réussi !"
    else
        log_error "Échec du déploiement"
        rollback
        exit 1
    fi
}

# Vérification de santé
health_check() {
    log_info "Vérification de la santé des services..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -sf http://localhost/health > /dev/null 2>&1; then
            log_success "Services opérationnels"
            return 0
        fi
        
        log_info "Tentative $attempt/$max_attempts..."
        sleep 10
        ((attempt++))
    done
    
    log_error "Services non disponibles après $max_attempts tentatives"
    return 1
}

# Rollback en cas d'échec
rollback() {
    log_warning "Rollback en cours..."
    
    # Restaurer la version précédente (si disponible)
    docker-compose -f "$COMPOSE_FILE" down
    # Ici, vous pourriez restaurer des images taguées précédemment
    docker-compose -f "$COMPOSE_FILE" up -d
    
    log_info "Rollback terminé"
}

# Affichage des logs
show_logs() {
    log_info "Affichage des logs..."
    docker-compose -f "$COMPOSE_FILE" logs --tail=50 -f
}

# Fonction principale
main() {
    local command=${1:-deploy}
    local version=${2:-latest}
    
    case $command in
        "deploy")
            check_requirements
            backup_data
            deploy "$version"
            ;;
        "health")
            health_check
            ;;
        "logs")
            show_logs
            ;;
        "rollback")
            rollback
            ;;
        "backup")
            backup_data
            ;;
        *)
            echo "Usage: $0 {deploy|health|logs|rollback|backup} [version]"
            echo ""
            echo "Commandes:"
            echo "  deploy [version]  - Déploie l'application (défaut: latest)"
            echo "  health           - Vérifie la santé des services"
            echo "  logs             - Affiche les logs"
            echo "  rollback         - Effectue un rollback"
            echo "  backup           - Sauvegarde les données"
            exit 1
            ;;
    esac
}

# Exécution
main "$@"
