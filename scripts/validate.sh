#!/bin/bash

# Script de validation finale simplifié pour Redriva

set +e  # Ne pas s'arrêter aux erreurs

# Configuration
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
VALIDATION_LOG="validation-$TIMESTAMP.log"
REPORT_FILE="validation-report-$TIMESTAMP.md"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Compteurs de résultats
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
    echo "[$(date +'%H:%M:%S')] $1" >> "$VALIDATION_LOG"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARN:${NC} $1"
    echo "[$(date +'%H:%M:%S')] WARN: $1" >> "$VALIDATION_LOG"
}

log_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1"
    echo "[$(date +'%H:%M:%S')] ERROR: $1" >> "$VALIDATION_LOG"
}

log_info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO:${NC} $1"
    echo "[$(date +'%H:%M:%S')] INFO: $1" >> "$VALIDATION_LOG"
}

log_step() {
    echo -e "\n${PURPLE}==== $1 ====${NC}"
    echo "" >> "$VALIDATION_LOG"
    echo "==== $1 ====" >> "$VALIDATION_LOG"
}

# Fonction pour exécuter un test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TOTAL_TESTS++))
    log_info "Test: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        log "✅ PASS: $test_name"
        ((PASSED_TESTS++))
        return 0
    else
        log_error "❌ FAIL: $test_name"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Validation de la structure du projet
validate_project_structure() {
    log_step "Validation de la structure du projet"
    
    local required_files=(
        "docker-compose.yml"
        "backend/Dockerfile"
        "backend/app.py"
        "backend/requirements.txt"
        "frontend/Dockerfile"
        "frontend/package.json"
        "frontend/svelte.config.js"
        "scripts/security-audit.sh"
        "scripts/update-deps.sh"
        "scripts/performance-test.sh"
        "scripts/deploy-unified.sh"
        ".github/workflows/security-audit.yml"
    )
    
    for file in "${required_files[@]}"; do
        run_test "Fichier $file existe" "[ -f '$file' ]"
    done
    
    local required_dirs=(
        "backend"
        "frontend"
        "scripts"
        ".github/workflows"
    )
    
    for dir in "${required_dirs[@]}"; do
        run_test "Dossier $dir existe" "[ -d '$dir' ]"
    done
}

# Validation de la configuration Docker
validate_docker_config() {
    log_step "Validation de la configuration Docker"
    
    # Vérifier Docker
    run_test "Docker est accessible" "docker info"
    run_test "Docker Compose est accessible" "docker compose version"
    
    # Vérifier les Dockerfiles
    run_test "Dockerfile backend existe" "[ -f 'backend/Dockerfile' ]"
    run_test "Dockerfile frontend existe" "[ -f 'frontend/Dockerfile' ]"
    
    # Vérifier docker-compose.yml
    run_test "docker-compose.yml valide" "docker compose config"
}

# Validation des dépendances
validate_dependencies() {
    log_step "Validation des dépendances"
    
    # Backend Python
    if [ -f "backend/requirements.txt" ]; then
        local python_deps=("fastapi" "uvicorn" "prometheus-client")
        for dep in "${python_deps[@]}"; do
            run_test "Dépendance Python $dep présente" "grep -q '$dep' backend/requirements.txt"
        done
    fi
    
    # Frontend Node.js
    if [ -f "frontend/package.json" ]; then
        local node_deps=("svelte" "@sveltejs/kit" "vite" "tailwindcss")
        for dep in "${node_deps[@]}"; do
            run_test "Dépendance Node.js $dep présente" "grep -q '$dep' frontend/package.json"
        done
    fi
}

# Validation des scripts
validate_scripts() {
    log_step "Validation des scripts"
    
    local scripts=(
        "scripts/security-audit.sh"
        "scripts/update-deps.sh"
        "scripts/performance-test.sh"
        "scripts/deploy-unified.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            run_test "Script $script exécutable" "[ -x '$script' ]"
            run_test "Script $script syntaxe correcte" "bash -n '$script'"
        fi
    done
}

# Validation de la sécurité
validate_security() {
    log_step "Validation de la sécurité"
    
    # Vérifier .gitignore
    if [ -f ".gitignore" ]; then
        run_test ".env dans .gitignore" "grep -q '.env' .gitignore"
        run_test "node_modules dans .gitignore" "grep -q 'node_modules' .gitignore"
        run_test "__pycache__ dans .gitignore" "grep -q '__pycache__' .gitignore"
    fi
    
    # Vérifier les en-têtes de sécurité dans Nginx
    if [ -f "frontend/nginx.conf.template" ]; then
        local security_headers=("X-Frame-Options" "X-Content-Type-Options" "Strict-Transport-Security")
        for header in "${security_headers[@]}"; do
            run_test "En-tête sécurité $header configuré" "grep -q '$header' frontend/nginx.conf.template"
        done
    fi
}

# Génération du rapport final
generate_report() {
    log_step "Génération du rapport de validation"
    
    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    
    cat > "$REPORT_FILE" << EOF
# Rapport de Validation Redriva

**Date:** $(date)
**Commit:** $(git rev-parse HEAD 2>/dev/null || echo 'unknown')

## Résumé Exécutif

- **Tests exécutés:** $TOTAL_TESTS
- **Tests réussis:** $PASSED_TESTS ✅
- **Tests échoués:** $FAILED_TESTS ❌
- **Taux de réussite:** $success_rate%

## Statut Global

$([ $success_rate -ge 90 ] && echo "🟢 **VALIDATION RÉUSSIE** - Le projet est prêt pour le déploiement" || echo "🔴 **VALIDATION ÉCHOUÉE** - Des corrections sont nécessaires")

## Logs Détaillés

Consultez le fichier: \`$VALIDATION_LOG\`

EOF

    log "📋 Rapport généré: $REPORT_FILE"
}

# Affichage des résultats finaux
show_results() {
    echo ""
    echo "=============================="
    echo "   RÉSULTATS DE VALIDATION"
    echo "=============================="
    echo ""
    echo "Tests exécutés: $TOTAL_TESTS"
    echo "Tests réussis:  $PASSED_TESTS ✅"
    echo "Tests échoués:  $FAILED_TESTS ❌"
    echo ""
    
    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    
    echo "Taux de réussite: $success_rate%"
    echo ""
    
    if [ $success_rate -ge 90 ]; then
        echo -e "${GREEN}🎉 VALIDATION RÉUSSIE${NC}"
        echo "Le projet Redriva est prêt pour le déploiement !"
        echo ""
        echo "Prochaines étapes:"
        echo "  1. Déployer: ./scripts/deploy-unified.sh deploy"
        echo "  2. Surveiller: ./scripts/performance-test.sh"
    else
        echo -e "${RED}❌ VALIDATION ÉCHOUÉE${NC}"
        echo "Des corrections sont nécessaires avant le déploiement."
        echo ""
        echo "Actions requises:"
        echo "  1. Consulter: $VALIDATION_LOG"
        echo "  2. Corriger les problèmes identifiés"
        echo "  3. Relancer: $0"
    fi
    
    echo ""
    echo "Rapports générés:"
    echo "  • Détaillé: $REPORT_FILE"
    echo "  • Logs: $VALIDATION_LOG"
    echo ""
}

# Fonction principale
main() {
    log_step "VALIDATION FINALE REDRIVA"
    log_info "Début de la validation complète"
    
    # Tests de validation
    validate_project_structure
    validate_docker_config
    validate_dependencies
    validate_scripts
    validate_security
    
    # Générer le rapport
    generate_report
    show_results
    
    # Code de sortie basé sur le taux de réussite
    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    
    if [ $success_rate -ge 90 ]; then
        exit 0
    else
        exit 1
    fi
}

# Point d'entrée
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    cat << EOF
Usage: $0 [OPTIONS]

Script de validation finale pour Redriva.
Teste l'intégration complète et valide le fonctionnement.

Options:
  --help, -h    Afficher cette aide

Le script génère:
  - validation-TIMESTAMP.log     (logs détaillés)
  - validation-report-TIMESTAMP.md (rapport de synthèse)

EOF
    exit 0
fi

# Exécution
main "$@"
