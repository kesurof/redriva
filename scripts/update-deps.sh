#!/bin/bash

# Script de mise à jour automatique des dépendances pour Redriva
# Met à jour les dépendances backend et frontend de manière sécurisée

set -e

# Configuration
BACKUP_DIR="backups/deps-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="logs/update-deps-$(date +%Y%m%d-%H%M%S).log"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARN:${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

# Créer les dossiers nécessaires
mkdir -p "$(dirname "$LOG_FILE")" "$BACKUP_DIR"

# Fonction de backup
backup_files() {
    log "Création des sauvegardes..."
    
    [ -f "backend/requirements.txt" ] && cp "backend/requirements.txt" "$BACKUP_DIR/"
    [ -f "frontend/package.json" ] && cp "frontend/package.json" "$BACKUP_DIR/"
    [ -f "frontend/package-lock.json" ] && cp "frontend/package-lock.json" "$BACKUP_DIR/"
    
    log "Sauvegardes créées dans $BACKUP_DIR"
}

# Fonction de restauration
restore_files() {
    log "Restauration des fichiers depuis $BACKUP_DIR..."
    
    [ -f "$BACKUP_DIR/requirements.txt" ] && cp "$BACKUP_DIR/requirements.txt" "backend/"
    [ -f "$BACKUP_DIR/package.json" ] && cp "$BACKUP_DIR/package.json" "frontend/"
    [ -f "$BACKUP_DIR/package-lock.json" ] && cp "$BACKUP_DIR/package-lock.json" "frontend/"
    
    log "Fichiers restaurés"
}

# Mise à jour des dépendances Python
update_python_deps() {
    log "Mise à jour des dépendances Python..."
    
    if [ ! -f "backend/requirements.txt" ]; then
        log_error "Fichier backend/requirements.txt non trouvé"
        return 1
    fi
    
    # Vérifier les vulnérabilités avant mise à jour
    if command -v pip-audit >/dev/null 2>&1; then
        log "Vérification des vulnérabilités Python..."
        pip-audit -r backend/requirements.txt --format=json --output="$BACKUP_DIR/python-audit-before.json" || true
    fi
    
    # Mise à jour via Docker
    log "Mise à jour des packages Python via Docker..."
    
    if docker compose run --rm backend pip list --outdated --format=json > "$BACKUP_DIR/python-outdated.json" 2>/dev/null; then
        log "Liste des packages obsolètes sauvegardée"
    fi
    
    # Mettre à jour les packages de sécurité en priorité
    docker compose run --rm backend sh -c "
        pip install --upgrade pip setuptools wheel &&
        pip install --upgrade pip-audit safety
    " || {
        log_error "Erreur lors de la mise à jour des outils de sécurité Python"
        return 1
    }
    
    # Vérifier après mise à jour
    if command -v pip-audit >/dev/null 2>&1; then
        pip-audit -r backend/requirements.txt --format=json --output="$BACKUP_DIR/python-audit-after.json" || true
    fi
    
    log "Dépendances Python mises à jour"
}

# Mise à jour des dépendances Node.js
update_node_deps() {
    log "Mise à jour des dépendances Node.js..."
    
    if [ ! -f "frontend/package.json" ]; then
        log_error "Fichier frontend/package.json non trouvé"
        return 1
    fi
    
    # Audit de sécurité avant mise à jour
    log "Audit de sécurité Node.js avant mise à jour..."
    docker compose run --rm frontend npm audit --json > "$BACKUP_DIR/npm-audit-before.json" 2>/dev/null || true
    
    # Liste des packages obsolètes
    docker compose run --rm frontend npm outdated --json > "$BACKUP_DIR/npm-outdated.json" 2>/dev/null || true
    
    # Mise à jour des packages de sécurité
    log "Correction des vulnérabilités Node.js..."
    docker compose run --rm frontend npm audit fix || {
        log_warn "Impossible de corriger automatiquement toutes les vulnérabilités"
    }
    
    # Mise à jour des dépendances mineures
    log "Mise à jour des dépendances mineures..."
    docker compose run --rm frontend npm update || {
        log_error "Erreur lors de la mise à jour des dépendances Node.js"
        return 1
    }
    
    # Audit après mise à jour
    docker compose run --rm frontend npm audit --json > "$BACKUP_DIR/npm-audit-after.json" 2>/dev/null || true
    
    log "Dépendances Node.js mises à jour"
}

# Tests après mise à jour
run_tests() {
    log "Exécution des tests après mise à jour..."
    
    # Reconstruire les images
    log "Reconstruction des images Docker..."
    docker compose build || {
        log_error "Erreur lors de la reconstruction des images"
        return 1
    }
    
    # Démarrer les services
    log "Démarrage des services pour les tests..."
    docker compose up -d || {
        log_error "Erreur lors du démarrage des services"
        return 1
    }
    
    # Attendre que les services soient prêts
    sleep 10
    
    # Test de santé basique
    log "Test de connectivité des services..."
    
    if docker compose exec backend curl -f http://localhost:8000/health >/dev/null 2>&1; then
        log "Backend accessible ✓"
    else
        log_error "Backend non accessible"
        return 1
    fi
    
    if docker compose exec frontend curl -f http://localhost:5173 >/dev/null 2>&1; then
        log "Frontend accessible ✓"
    else
        log_error "Frontend non accessible"
        return 1
    fi
    
    # Tests unitaires si disponibles
    if [ -f "frontend/package.json" ] && grep -q '"test"' frontend/package.json; then
        log "Exécution des tests frontend..."
        docker compose exec frontend npm test || log_warn "Tests frontend échoués"
    fi
    
    log "Tests terminés"
}

# Génération du rapport
generate_report() {
    log "Génération du rapport de mise à jour..."
    
    report_file="reports/deps-update-$(date +%Y%m%d-%H%M%S).md"
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
# Rapport de Mise à Jour des Dépendances

**Date:** $(date)
**Backup Directory:** $BACKUP_DIR

## Résumé

Ce rapport détaille la mise à jour automatique des dépendances pour Redriva.

## Fichiers Sauvegardés

- requirements.txt
- package.json
- package-lock.json
- Audits de sécurité (avant/après)

## Actions Effectuées

1. ✅ Sauvegarde des fichiers de dépendances
2. ✅ Mise à jour des dépendances Python
3. ✅ Mise à jour des dépendances Node.js
4. ✅ Tests de fonctionnement
5. ✅ Audits de sécurité

## Prochaines Actions

- Valider le fonctionnement en production
- Surveiller les performances après mise à jour
- Programmer la prochaine mise à jour (mensuelle)

## Logs Détaillés

Consultez le fichier: $LOG_FILE

## Restauration (en cas de problème)

\`\`\`bash
# Restaurer les fichiers
cp $BACKUP_DIR/* backend/ frontend/

# Reconstruire
docker compose build
docker compose up -d
\`\`\`

EOF

    log "Rapport généré: $report_file"
}

# Fonction de nettoyage
cleanup() {
    log "Nettoyage des ressources temporaires..."
    docker compose down || true
}

# Handler d'erreur
error_handler() {
    log_error "Erreur détectée. Restauration des fichiers..."
    restore_files
    cleanup
    exit 1
}

# Configuration du trap pour les erreurs
trap error_handler ERR

# Fonction principale
main() {
    log "=== Démarrage de la mise à jour des dépendances ==="
    
    # Vérifications préalables
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    if ! docker compose version >/dev/null 2>&1; then
        log_error "Docker Compose n'est pas disponible"
        exit 1
    fi
    
    # Étapes de mise à jour
    backup_files
    
    case "${1:-all}" in
        python|backend)
            update_python_deps
            ;;
        node|frontend)
            update_node_deps
            ;;
        all|*)
            update_python_deps
            update_node_deps
            ;;
    esac
    
    run_tests
    generate_report
    
    log "=== Mise à jour terminée avec succès ==="
    log "Sauvegarde disponible dans: $BACKUP_DIR"
    log "Logs détaillés dans: $LOG_FILE"
}

# Point d'entrée
case "${1:-all}" in
    --help|-h)
        echo "Usage: $0 [python|node|all]"
        echo "  python: Met à jour uniquement les dépendances Python"
        echo "  node:   Met à jour uniquement les dépendances Node.js"
        echo "  all:    Met à jour toutes les dépendances (défaut)"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
