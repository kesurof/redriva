#!/bin/bash
# scripts/deploy.sh - Script déploiement production simplifié
# Approche unifiée "Zéro Réécriture"

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[DEPLOY]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Banner
echo -e "${BLUE}"
echo "🚀 Redriva - Déploiement Production"
echo "==================================="
echo -e "${NC}"

# Vérifications prérequis
check_requirements() {
    log "🔍 Vérification des prérequis..."
    
    [ ! -f ".env.prod" ] && {
        error "Fichier .env.prod manquant"
        info "Copiez .env.prod.example vers .env.prod et configurez-le"
        exit 1
    }
    
    command -v docker >/dev/null || {
        error "Docker non installé"
        exit 1
    }
    
    docker compose version >/dev/null || {
        error "Docker Compose non installé"
        exit 1
    }
    
    log "✅ Prérequis validés"
}

# Sauvegarde rapide
backup() {
    log "💾 Sauvegarde des données"
    backup_dir="backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Sauvegarde données existantes
    [ -d "backend/data" ] && cp -r backend/data "$backup_dir/" 2>/dev/null || true
    [ -f ".env.prod" ] && cp .env.prod "$backup_dir/" 2>/dev/null || true
    
    # Sauvegarde volumes Docker si existants
    if docker volume ls | grep -q redriva; then
        info "📦 Volumes Docker détectés, création d'une archive..."
        docker run --rm -v redriva_redriva-data:/data -v "$PWD/$backup_dir":/backup alpine tar czf /backup/redriva-data.tar.gz -C /data . 2>/dev/null || true
    fi
    
    log "✅ Sauvegarde dans $backup_dir"
}

# Déploiement principal
deploy() {
    log "🚀 Déploiement production"
    
    # Arrêt services existants (sans erreur si inexistants)
    info "🛑 Arrêt des services existants..."
    docker compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    # Construction et démarrage
    info "🔨 Construction des images..."
    docker compose -f docker-compose.prod.yml build --no-cache
    
    info "🏃 Démarrage des services..."
    docker compose -f docker-compose.prod.yml up -d
    
    # Vérification santé
    log "⏳ Attente services (45s max)..."
    for i in {1..45}; do
        if curl -sf http://localhost:3000 >/dev/null 2>&1; then
            break
        fi
        sleep 1
        printf "."
    done
    echo ""
    
    # Validation finale
    if curl -sf http://localhost:3000 >/dev/null 2>&1; then
        log "✅ Déploiement réussi !"
        echo ""
        info "🌐 Application disponible:"
        info "   URL: http://localhost:3000"
        echo ""
        info "📋 Commandes utiles:"
        info "   $0 status    # Statut des services"
        info "   $0 logs      # Voir les logs"
        info "   $0 stop      # Arrêter"
    else
        error "❌ Déploiement échoué"
        warn "🔍 Vérification des logs..."
        docker compose -f docker-compose.prod.yml logs --tail=50
        exit 1
    fi
}

# Validation de l'environnement
validate() {
    log "🔍 Validation de l'environnement"
    
    info "📊 Statut des services:"
    docker compose -f docker-compose.prod.yml ps
    
    echo ""
    info "🔗 Tests de connectivité:"
    
    # Test frontend
    if curl -sf http://localhost:3000 >/dev/null 2>&1; then
        echo -e "   Frontend: ${GREEN}✅ OK${NC}"
    else
        echo -e "   Frontend: ${RED}❌ KO${NC}"
    fi
    
    # Test backend via proxy
    if curl -sf http://localhost:3000/api/ping >/dev/null 2>&1; then
        echo -e "   Backend:  ${GREEN}✅ OK${NC}"
    else
        echo -e "   Backend:  ${RED}❌ KO${NC}"
    fi
    
    # Test Redis
    if docker compose -f docker-compose.prod.yml exec -T redis redis-cli ping >/dev/null 2>&1; then
        echo -e "   Redis:    ${GREEN}✅ OK${NC}"
    else
        echo -e "   Redis:    ${RED}❌ KO${NC}"
    fi
}

# Menu principal
case "${1:-deploy}" in
    "deploy")
        check_requirements
        backup
        deploy
        ;;
    
    "stop")
        log "🛑 Arrêt production"
        docker compose -f docker-compose.prod.yml down
        log "✅ Services arrêtés"
        ;;
    
    "restart")
        log "🔄 Redémarrage production"
        docker compose -f docker-compose.prod.yml down
        docker compose -f docker-compose.prod.yml up -d
        log "✅ Services redémarrés"
        ;;
    
    "logs")
        service=${2:-}
        if [ -n "$service" ]; then
            log "📋 Logs du service: $service"
            docker compose -f docker-compose.prod.yml logs -f "$service"
        else
            log "📋 Logs de tous les services"
            docker compose -f docker-compose.prod.yml logs -f
        fi
        ;;
    
    "status")
        validate
        ;;
    
    "backup")
        backup
        ;;
    
    "shell")
        service=${2:-backend}
        log "🐚 Shell dans $service"
        docker compose -f docker-compose.prod.yml exec "$service" bash
        ;;
    
    "update")
        log "🔄 Mise à jour production"
        check_requirements
        backup
        info "🔨 Reconstruction des images..."
        docker compose -f docker-compose.prod.yml build --no-cache
        docker compose -f docker-compose.prod.yml up -d
        log "✅ Mise à jour terminée"
        ;;
    
    *)
        echo -e "${YELLOW}Usage: $0 {deploy|stop|restart|logs [service]|status|backup|shell [service]|update}${NC}"
        echo ""
        echo "Commandes principales:"
        echo "  deploy         Déploiement complet avec sauvegarde"
        echo "  stop           Arrêter la production"
        echo "  restart        Redémarrer la production"
        echo "  status         Statut et validation"
        echo ""
        echo "Maintenance:"
        echo "  logs [service] Voir les logs"
        echo "  shell [service] Accéder au shell"
        echo "  backup         Sauvegarde manuelle"
        echo "  update         Mise à jour (rebuild + restart)"
        echo ""
        echo "Exemples:"
        echo "  $0 deploy              # Déploiement initial"
        echo "  $0 logs backend        # Logs du backend"
        echo "  $0 shell frontend      # Shell dans le frontend"
        ;;
esac
