#!/bin/bash

# Script de déploiement unifié pour Redriva
# Orchestre la construction, les tests et le déploiement

set -e

# Configuration
PROJECT_NAME="redriva"
VERSION=${VERSION:-$(git describe --tags --always 2>/dev/null || echo "dev-$(date +%Y%m%d)")}
ENVIRONMENT=${ENVIRONMENT:-"production"}
REGISTRY=${REGISTRY:-"ghcr.io"}
NAMESPACE=${NAMESPACE:-"kesurof"}

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARN:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1"
}

log_info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO:${NC} $1"
}

log_step() {
    echo -e "\n${PURPLE}==== $1 ====${NC}"
}

# Vérifier les prérequis
check_prerequisites() {
    log_step "Vérification des prérequis"
    
    local required_commands=("docker" "git")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        else
            log "✓ $cmd installé"
        fi
    done
    
    # Vérifier Docker Compose (nouvelle syntaxe)
    if docker compose version >/dev/null 2>&1; then
        log "✓ docker compose installé"
    else
        missing_commands+=("docker-compose")
    fi
    
    if [ ${#missing_commands[@]} -ne 0 ]; then
        log_error "Commandes manquantes: ${missing_commands[*]}"
        exit 1
    fi
    
    # Vérifier Docker
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker n'est pas accessible. Vérifiez que le daemon Docker est démarré."
        exit 1
    fi
    
    log "✓ Tous les prérequis sont satisfaits"
}

# Nettoyage de l'environnement
cleanup_environment() {
    log_step "Nettoyage de l'environnement"
    
    # Arrêter les conteneurs existants
    if docker compose ps -q | grep -q .; then
        log "Arrêt des conteneurs existants..."
        docker compose down --remove-orphans
    fi
    
    # Nettoyer les images non utilisées
    if [ "$CLEAN_IMAGES" = "true" ]; then
        log "Nettoyage des images Docker..."
        docker image prune -f
        docker system prune -f --volumes
    fi
    
    log "✓ Environnement nettoyé"
}

# Audit de sécurité
security_audit() {
    log_step "Audit de sécurité"
    
    if [ -x "./scripts/security-audit.sh" ]; then
        log "Exécution de l'audit de sécurité..."
        ./scripts/security-audit.sh
        log "✓ Audit de sécurité terminé"
    else
        log_warn "Script d'audit de sécurité non trouvé ou non exécutable"
    fi
}

# Construction des images
build_images() {
    log_step "Construction des images Docker"
    
    local compose_file="docker-compose.yml"
    if [ "$ENVIRONMENT" = "production" ] && [ -f "docker-compose.prod.yml" ]; then
        compose_file="docker-compose.prod.yml"
    fi
    
    log "Construction avec $compose_file..."
    
    # Construction avec cache si disponible
    DOCKER_BUILDKIT=1 docker compose -f "$compose_file" build \
        --build-arg VERSION="$VERSION" \
        --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --build-arg VCS_REF="$(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
    
    log "✓ Images construites avec succès"
}

# Tests de validation
run_tests() {
    log_step "Exécution des tests"
    
    local compose_file="docker-compose.yml"
    if [ "$ENVIRONMENT" = "production" ] && [ -f "docker-compose.prod.yml" ]; then
        compose_file="docker-compose.prod.yml"
    fi
    
    # Démarrer les services pour les tests
    log "Démarrage des services de test..."
    docker compose -f "$compose_file" up -d
    
    # Attendre que les services soient prêts
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -sf http://localhost:8000/health >/dev/null 2>&1; then
            log "✓ Services prêts"
            break
        fi
        
        log_info "Attente des services... ($attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "Timeout: les services ne sont pas accessibles"
        return 1
    fi
    
    # Tests fonctionnels basiques
    log "Tests fonctionnels..."
    test_endpoints
    
    # Tests de performance si demandés
    if [ "$RUN_PERFORMANCE_TESTS" = "true" ] && [ -x "./scripts/performance-test.sh" ]; then
        log "Tests de performance..."
        ./scripts/performance-test.sh --load-only
    fi
    
    log "✓ Tests terminés avec succès"
}

# Test des endpoints principaux
test_endpoints() {
    local endpoints=(
        "http://localhost:8000/health"
        "http://localhost:8000/api/torrents"
        "http://localhost:8000/api/queue"
        "http://localhost:8000/metrics"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -sf "$endpoint" >/dev/null 2>&1; then
            log "✓ $endpoint accessible"
        else
            log_error "✗ $endpoint non accessible"
            return 1
        fi
    done
}

# Sauvegarde avant déploiement
backup_data() {
    if [ "$SKIP_BACKUP" = "true" ]; then
        log_info "Sauvegarde désactivée"
        return 0
    fi
    
    log_step "Sauvegarde des données"
    
    local backup_dir="backups/deploy-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Sauvegarder les données si elles existent
    if [ -d "backend/data" ]; then
        cp -r backend/data "$backup_dir/"
        log "✓ Données backend sauvegardées"
    fi
    
    if [ -d "backend/database" ]; then
        cp -r backend/database "$backup_dir/"
        log "✓ Base de données sauvegardée"
    fi
    
    # Sauvegarder la configuration
    if [ -f ".env" ]; then
        cp .env "$backup_dir/"
    fi
    
    log "✓ Sauvegarde créée dans $backup_dir"
    export BACKUP_DIR="$backup_dir"
}

# Déploiement
deploy() {
    log_step "Déploiement"
    
    local compose_file="docker-compose.yml"
    if [ "$ENVIRONMENT" = "production" ] && [ -f "docker-compose.prod.yml" ]; then
        compose_file="docker-compose.prod.yml"
    fi
    
    # Déploiement avec mise à jour
    log "Déploiement avec $compose_file..."
    
    # Créer les répertoires nécessaires
    mkdir -p data logs backend/data backend/logs
    
    # Démarrer les services
    docker compose -f "$compose_file" up -d --remove-orphans
    
    # Vérifier le déploiement
    sleep 10
    if test_endpoints; then
        log "✓ Déploiement réussi"
    else
        log_error "Échec du déploiement"
        return 1
    fi
}

# Post-déploiement
post_deploy() {
    log_step "Actions post-déploiement"
    
    # Afficher les logs récents
    log "Logs des services (dernières 20 lignes):"
    docker compose logs --tail=20
    
    # Afficher le statut des services
    log "Statut des services:"
    docker compose ps
    
    # Afficher les URLs d'accès
    log "URLs d'accès:"
    log "  • Application: http://localhost:3000"
    log "  • API Backend: http://localhost:8000"
    log "  • API Documentation: http://localhost:8000/docs"
    log "  • Métriques: http://localhost:8000/metrics"
    
    # Générer un rapport de déploiement
    generate_deploy_report
    
    log "✓ Déploiement terminé avec succès"
}

# Générer un rapport de déploiement
generate_deploy_report() {
    local report_file="reports/deploy-$(date +%Y%m%d-%H%M%S).md"
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
# Rapport de Déploiement Redriva

**Date:** $(date)
**Version:** $VERSION
**Environnement:** $ENVIRONMENT
**Utilisateur:** $(whoami)
**Commit:** $(git rev-parse HEAD 2>/dev/null || echo 'unknown')

## Résumé

Déploiement réussi de Redriva version $VERSION.

## Configuration

- **Registry:** $REGISTRY
- **Namespace:** $NAMESPACE
- **Compose File:** $([ "$ENVIRONMENT" = "production" ] && echo "docker-compose.prod.yml" || echo "docker-compose.yml")

## Services Déployés

$(docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}")

## URLs d'Accès

- Application: http://localhost:3000
- API Backend: http://localhost:8000
- Documentation API: http://localhost:8000/docs
- Métriques: http://localhost:8000/metrics

## Sauvegarde

${BACKUP_DIR:+Données sauvegardées dans: $BACKUP_DIR}

## Prochaines Actions

- [ ] Valider le fonctionnement en production
- [ ] Surveiller les métriques
- [ ] Planifier la prochaine mise à jour

EOF

    log "Rapport de déploiement généré: $report_file"
}

# Affichage de l'aide
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND]

Commands:
  build      Construire les images seulement
  test       Exécuter les tests seulement  
  deploy     Déployer (build + test + deploy)
  cleanup    Nettoyer l'environnement

Options:
  --environment ENV     Environnement (development|production) [défaut: production]
  --version VERSION     Version à déployer [défaut: git describe]
  --skip-tests         Ignorer les tests
  --skip-backup        Ignorer la sauvegarde
  --clean-images       Nettoyer les images Docker
  --performance-tests  Exécuter les tests de performance
  --help, -h           Afficher cette aide

Variables d'environnement:
  REGISTRY             Registry Docker [défaut: ghcr.io]
  NAMESPACE            Namespace [défaut: kesurof]

Exemples:
  $0 deploy                    # Déploiement complet
  $0 build --environment dev   # Construction en dev
  $0 test --skip-backup        # Tests sans sauvegarde

EOF
}

# Parsing des arguments
SKIP_TESTS=false
SKIP_BACKUP=false
CLEAN_IMAGES=false
RUN_PERFORMANCE_TESTS=false
COMMAND="deploy"

while [[ $# -gt 0 ]]; do
    case $1 in
        --environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --clean-images)
            CLEAN_IMAGES=true
            shift
            ;;
        --performance-tests)
            RUN_PERFORMANCE_TESTS=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        build|test|deploy|cleanup)
            COMMAND="$1"
            shift
            ;;
        *)
            log_error "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Fonction principale
main() {
    log_step "Déploiement Redriva"
    log_info "Version: $VERSION"
    log_info "Environnement: $ENVIRONMENT"
    log_info "Commande: $COMMAND"
    
    case "$COMMAND" in
        build)
            check_prerequisites
            build_images
            ;;
        test)
            check_prerequisites
            build_images
            run_tests
            ;;
        deploy)
            check_prerequisites
            cleanup_environment
            security_audit
            backup_data
            build_images
            
            if [ "$SKIP_TESTS" != "true" ]; then
                run_tests
            fi
            
            deploy
            post_deploy
            ;;
        cleanup)
            cleanup_environment
            ;;
        *)
            log_error "Commande inconnue: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

# Point d'entrée
main "$@"
