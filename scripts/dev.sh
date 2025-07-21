#!/bin/bash

# Script de développement pour Redriva
# Simplifie les tâches courantes de développement

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Démarrage de l'environnement de développement
dev_start() {
    log_info "Démarrage de l'environnement de développement..."
    docker-compose up -d
    log_success "Environnement démarré"
    echo ""
    echo "🌐 Frontend: http://localhost:5173"
    echo "🔌 Backend API: http://localhost:8080"
    echo "📖 API Docs: http://localhost:8080/docs"
}

# Arrêt de l'environnement
dev_stop() {
    log_info "Arrêt de l'environnement de développement..."
    docker-compose down
    log_success "Environnement arrêté"
}

# Reconstruction des images
dev_rebuild() {
    log_info "Reconstruction des images..."
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    log_success "Images reconstruites et services redémarrés"
}

# Nettoyage complet
dev_clean() {
    log_warning "Nettoyage complet (ATTENTION: supprime toutes les données)"
    read -p "Êtes-vous sûr ? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v
        docker system prune -f
        docker volume prune -f
        log_success "Nettoyage terminé"
    else
        log_info "Nettoyage annulé"
    fi
}

# Affichage des logs
dev_logs() {
    local service=${1:-}
    if [ -n "$service" ]; then
        docker-compose logs -f "$service"
    else
        docker-compose logs -f
    fi
}

# Tests
dev_test() {
    log_info "Exécution des tests..."
    
    # Tests backend
    log_info "Tests backend..."
    docker-compose exec backend pytest
    
    # Tests frontend
    log_info "Tests frontend..."
    docker-compose exec frontend npm run test:unit
    
    log_success "Tous les tests sont passés"
}

# Linting
dev_lint() {
    log_info "Vérification du code..."
    
    # Lint backend
    log_info "Lint backend..."
    docker-compose exec backend python -m flake8 .
    
    # Lint frontend
    log_info "Lint frontend..."
    docker-compose exec frontend npm run lint
    
    log_success "Code vérifié"
}

# Shell dans un conteneur
dev_shell() {
    local service=${1:-backend}
    log_info "Ouverture d'un shell dans le conteneur $service..."
    docker-compose exec "$service" /bin/bash
}

# Base de données: reset
db_reset() {
    log_warning "Reset de la base de données"
    read -p "Êtes-vous sûr ? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose exec backend rm -f /app/data/redriva.db
        docker-compose restart backend
        log_success "Base de données réinitialisée"
    else
        log_info "Reset annulé"
    fi
}

# Monitoring en temps réel
dev_monitor() {
    log_info "Monitoring en temps réel des services..."
    echo "Appuyez sur Ctrl+C pour arrêter"
    
    while true; do
        clear
        echo "=== STATUS DES SERVICES ==="
        docker-compose ps
        echo ""
        echo "=== USAGE CPU/MEMOIRE ==="
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
        echo ""
        echo "=== DERNIERS LOGS ==="
        docker-compose logs --tail=5
        sleep 5
    done
}

# Menu d'aide
show_help() {
    echo "Usage: $0 <command> [args...]"
    echo ""
    echo "Commandes de développement:"
    echo "  start          - Démarre l'environnement de développement"
    echo "  stop           - Arrête l'environnement"
    echo "  restart        - Redémarre l'environnement"
    echo "  rebuild        - Reconstruit les images et redémarre"
    echo "  clean          - Nettoyage complet (supprime tout)"
    echo ""
    echo "Debug et monitoring:"
    echo "  logs [service] - Affiche les logs (optionnel: service spécifique)"
    echo "  shell [service]- Ouvre un shell (défaut: backend)"
    echo "  monitor        - Monitoring en temps réel"
    echo ""
    echo "Tests et qualité:"
    echo "  test           - Lance tous les tests"
    echo "  lint           - Vérifie la qualité du code"
    echo ""
    echo "Base de données:"
    echo "  db:reset       - Remet à zéro la base de données"
    echo ""
    echo "Production:"
    echo "  build:prod     - Construit les images de production"
    echo "  deploy:prod    - Déploie en production"
}

# Construction des images de production
build_prod() {
    log_info "Construction des images de production..."
    
    docker build -f backend/Dockerfile.prod -t redriva/backend:latest ./backend
    docker build -f frontend/Dockerfile.prod -t redriva/frontend:latest ./frontend
    
    log_success "Images de production construites"
}

# Fonction principale
main() {
    local command=${1:-help}
    
    case $command in
        "start")
            dev_start
            ;;
        "stop")
            dev_stop
            ;;
        "restart")
            dev_stop
            dev_start
            ;;
        "rebuild")
            dev_rebuild
            ;;
        "clean")
            dev_clean
            ;;
        "logs")
            dev_logs "$2"
            ;;
        "shell")
            dev_shell "$2"
            ;;
        "monitor")
            dev_monitor
            ;;
        "test")
            dev_test
            ;;
        "lint")
            dev_lint
            ;;
        "db:reset")
            db_reset
            ;;
        "build:prod")
            build_prod
            ;;
        "deploy:prod")
            ./scripts/deploy-prod.sh
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Exécution
main "$@"
