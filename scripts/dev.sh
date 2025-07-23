#!/bin/bash
# scripts/dev.sh - Script développement ultra-simplifié
# Approche unifiée "Zéro Réécriture"

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[DEV]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Banner
echo -e "${BLUE}"
echo "🚀 Redriva - Environnement de Développement"
echo "=========================================="
echo -e "${NC}"

case "${1:-start}" in
    "start")
        log "🚀 Démarrage environnement développement"
        info "Construction et démarrage des services..."
        docker compose up --build -d
        
        log "⏳ Attente de la disponibilité des services..."
        sleep 10
        
        # Vérification simple
        if curl -sf http://localhost:8080/api/ping >/dev/null 2>&1; then
            log "✅ Backend disponible"
        else
            warn "⚠️  Backend en cours de démarrage..."
        fi
        
        if curl -sf http://localhost:5174 >/dev/null 2>&1; then
            log "✅ Frontend disponible"
        else
            warn "⚠️  Frontend en cours de démarrage..."
        fi
        
        echo ""
        info "🌐 URLs d'accès:"
        info "   Frontend: http://localhost:5174"
        info "   Backend:  http://localhost:8080/api"
        info "   API Docs: http://localhost:8080/docs"
        echo ""
        info "📋 Commandes utiles:"
        info "   $0 logs      # Voir tous les logs"
        info "   $0 stop      # Arrêter"
        info "   $0 rebuild   # Reconstruire"
        ;;
    
    "stop")
        log "🛑 Arrêt environnement"
        docker compose down
        log "✅ Services arrêtés"
        ;;
    
    "rebuild")
        log "🔨 Reconstruction complète"
        docker compose down
        docker compose up --build -d
        log "✅ Reconstruction terminée"
        ;;
    
    "clear-cache")
        service=${2:-backend}
        log "🧹 Effacement du cache Docker pour: $service"
        warn "⚠️  Reconstruction sans cache - peut prendre plus de temps"
        echo ""
        log "🛑 Arrêt des services..."
        docker compose down
        
        if [ "$service" = "all" ]; then
            log "🔨 Reconstruction sans cache de TOUS les services..."
            docker compose build --no-cache
        else
            log "🔨 Reconstruction sans cache de $service..."
            docker compose build --no-cache "$service"
        fi
        
        log "🚀 Redémarrage des services..."
        docker compose up -d
        log "✅ Effacement du cache terminé"
        echo ""
        info "💡 Utilisation:"
        info "   $0 clear-cache           # Efface le cache du backend"
        info "   $0 clear-cache frontend  # Efface le cache du frontend"
        info "   $0 clear-cache all       # Efface le cache de tous les services"
        ;;
    
    "logs")
        service=${2:-}
        if [ -n "$service" ]; then
            log "📋 Logs du service: $service"
            docker compose logs -f "$service"
        else
            log "📋 Logs de tous les services"
            docker compose logs -f
        fi
        ;;
    
    "shell")
        service=${2:-backend}
        log "🐚 Shell dans $service"
        docker compose exec "$service" bash
        ;;
    
    "status")
        log "📊 Statut des services"
        docker compose ps
        echo ""
        info "🔗 Tests de connectivité:"
        
        if curl -sf http://localhost:8080/api/ping >/dev/null 2>&1; then
            echo -e "   Backend:  ${GREEN}✅ OK${NC}"
        else
            echo -e "   Backend:  ${RED}❌ KO${NC}"
        fi
        
        if curl -sf http://localhost:5174 >/dev/null 2>&1; then
            echo -e "   Frontend: ${GREEN}✅ OK${NC}"
        else
            echo -e "   Frontend: ${RED}❌ KO${NC}"
        fi
        ;;
    
    "deps-frontend")
        package=${2:-}
        if [ -z "$package" ]; then
            error "Usage: $0 deps-frontend <package-name>"
            exit 1
        fi
        log "📦 Installation dépendance frontend: $package"
        docker compose run --rm frontend npm install "$package"
        docker compose build frontend
        log "✅ Dépendance installée, redémarrage..."
        docker compose up -d frontend
        ;;
    
    "deps-backend")
        log "📦 Mise à jour dépendances backend"
        warn "Ajoutez le paquet dans backend/requirements.txt puis:"
        info "   $0 rebuild"
        ;;
    
    "reset")
        log "💥 Reset complet (ATTENTION: supprime tout)"
        echo -e "${RED}⚠️  Cela va supprimer:${NC}"
        echo "   - Tous les containers"
        echo "   - Toutes les images Redriva"
        echo "   - Tous les volumes de données"
        echo ""
        read -p "Êtes-vous sûr ? (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && {
            log "🧹 Nettoyage en cours..."
            docker compose down -v --rmi all
            docker system prune -f
            log "✅ Reset terminé"
        } || {
            log "❌ Reset annulé"
        }
        ;;
    
    *)
        echo -e "${YELLOW}Usage: $0 {start|stop|rebuild|clear-cache [service]|logs [service]|shell [service]|status|deps-frontend <package>|deps-backend|reset}${NC}"
        echo ""
        echo "Commandes principales:"
        echo "  start               Démarrer l'environnement"
        echo "  stop                Arrêter l'environnement"
        echo "  rebuild             Reconstruire complètement"
        echo "  clear-cache [svc]   Effacer le cache Docker (backend par défaut)"
        echo "  status              Statut des services"
        echo ""
        echo "Debug et maintenance:"
        echo "  logs [service]      Voir les logs"
        echo "  shell [service]     Accéder au shell"
        echo "  reset               Reset complet (dangereux)"
        echo ""
        echo "Gestion des dépendances:"
        echo "  deps-frontend <pkg> Ajouter un paquet npm"
        echo "  deps-backend        Instructions pour backend"
        echo ""
        echo "Exemples clear-cache:"
        echo "  $0 clear-cache           # Cache backend uniquement"
        echo "  $0 clear-cache frontend  # Cache frontend uniquement"
        echo "  $0 clear-cache all       # Cache de tous les services"
        ;;
esac
