#!/bin/bash

# Script d'audit de sécurité pour Redriva
# Vérifie les dépendances, configurations et bonnes pratiques

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Audit des dépendances Backend
audit_backend_deps() {
    log_section "Audit des dépendances Backend (Python)"
    
    if [ -f "backend/requirements.txt" ]; then
        log_info "Vérification des vulnérabilités Python avec pip-audit..."
        
        if command_exists pip-audit; then
            pip-audit -r backend/requirements.txt || log_warn "Des vulnérabilités ont été détectées"
        else
            log_warn "pip-audit n'est pas installé. Installation recommandée: pip install pip-audit"
        fi
    else
        log_error "Fichier backend/requirements.txt non trouvé"
    fi
}

# Audit des dépendances Frontend
audit_frontend_deps() {
    log_section "Audit des dépendances Frontend (Node.js)"
    
    if [ -f "frontend/package.json" ]; then
        log_info "Vérification des vulnérabilités Node.js avec npm audit..."
        
        cd frontend
        if npm audit --audit-level moderate; then
            log_info "Aucune vulnérabilité critique détectée"
        else
            log_warn "Des vulnérabilités ont été détectées. Exécutez 'npm audit fix' pour les corriger"
        fi
        cd ..
    else
        log_error "Fichier frontend/package.json non trouvé"
    fi
}

# Vérification des configurations Docker
audit_docker_security() {
    log_section "Audit de sécurité Docker"
    
    # Vérifier les Dockerfiles
    for dockerfile in backend/Dockerfile.prod frontend/Dockerfile.prod; do
        if [ -f "$dockerfile" ]; then
            log_info "Vérification de $dockerfile..."
            
            # Vérifier si l'utilisateur root est utilisé
            if grep -q "USER root" "$dockerfile"; then
                log_error "$dockerfile utilise l'utilisateur root"
            else
                log_info "$dockerfile utilise un utilisateur non-root ✓"
            fi
            
            # Vérifier si des secrets sont exposés
            if grep -qE "(API_KEY|PASSWORD|SECRET|TOKEN)" "$dockerfile"; then
                log_warn "$dockerfile pourrait contenir des secrets exposés"
            fi
        fi
    done
    
    # Vérifier docker-compose.prod.yml
    if [ -f "docker-compose.prod.yml" ]; then
        log_info "Vérification de docker-compose.prod.yml..."
        
        # Vérifier si des ports sont exposés inutilement
        if grep -q "ports:" docker-compose.prod.yml; then
            log_info "Ports exposés détectés - vérifiez qu'ils sont nécessaires"
        fi
        
        # Vérifier la configuration des réseaux
        if grep -q "networks:" docker-compose.prod.yml; then
            log_info "Configuration réseau détectée ✓"
        else
            log_warn "Aucune configuration réseau - considérez l'isolation des services"
        fi
    fi
}

# Vérification des en-têtes de sécurité
audit_security_headers() {
    log_section "Audit des en-têtes de sécurité"
    
    if [ -f "frontend/nginx.conf.template" ]; then
        log_info "Vérification de la configuration Nginx..."
        
        security_headers=(
            "X-Frame-Options"
            "X-Content-Type-Options"
            "X-XSS-Protection"
            "Strict-Transport-Security"
            "Content-Security-Policy"
        )
        
        for header in "${security_headers[@]}"; do
            if grep -q "$header" frontend/nginx.conf.template; then
                log_info "$header configuré ✓"
            else
                log_warn "$header manquant"
            fi
        done
    fi
}

# Vérification des secrets et variables d'environnement
audit_secrets() {
    log_section "Audit des secrets"
    
    # Vérifier s'il y a des fichiers .env dans le repo
    if find . -name ".env*" -not -path "./.git/*" | grep -q .; then
        log_warn "Fichiers .env détectés dans le repository:"
        find . -name ".env*" -not -path "./.git/*"
        log_warn "Assurez-vous qu'ils sont dans .gitignore"
    else
        log_info "Aucun fichier .env dans le repository ✓"
    fi
    
    # Vérifier .gitignore
    if [ -f ".gitignore" ]; then
        if grep -q ".env" .gitignore; then
            log_info ".env est dans .gitignore ✓"
        else
            log_warn ".env n'est pas dans .gitignore"
        fi
    fi
}

# Vérification des permissions des fichiers
audit_file_permissions() {
    log_section "Audit des permissions des fichiers"
    
    # Vérifier les scripts exécutables
    for script in deploy.sh scripts/*.sh; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                log_info "$script est exécutable ✓"
            else
                log_warn "$script n'est pas exécutable"
            fi
        fi
    done
}

# Audit de la configuration CI/CD
audit_cicd() {
    log_section "Audit CI/CD"
    
    if [ -d ".github/workflows" ]; then
        log_info "Workflows GitHub Actions détectés"
        
        for workflow in .github/workflows/*.yml .github/workflows/*.yaml; do
            if [ -f "$workflow" ]; then
                log_info "Vérification de $workflow..."
                
                # Vérifier si des secrets sont utilisés
                if grep -q "secrets\." "$workflow"; then
                    log_info "Utilisation de secrets GitHub détectée ✓"
                fi
                
                # Vérifier la sécurité des actions
                if grep -qE "uses:.*@main|uses:.*@master" "$workflow"; then
                    log_warn "Actions utilisant des tags non-fixes détectées dans $workflow"
                fi
            fi
        done
    fi
}

# Génération du rapport
generate_report() {
    log_section "Génération du rapport d'audit"
    
    report_file="security-audit-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$report_file" << EOF
# Rapport d'Audit de Sécurité Redriva

**Date:** $(date)
**Version:** $(git describe --tags --always 2>/dev/null || echo "unknown")

## Résumé

Ce rapport contient les résultats de l'audit de sécurité automatisé pour le projet Redriva.

## Actions Recommandées

1. **Dépendances:** Exécuter \`npm audit fix\` et \`pip-audit --fix\`
2. **Docker:** Vérifier que tous les services utilisent des utilisateurs non-root
3. **Secrets:** S'assurer qu'aucun secret n'est commité dans le repository
4. **Monitoring:** Activer le monitoring des métriques de sécurité

## Détails

Consultez les logs d'exécution de ce script pour les détails complets.

## Prochaines Étapes

- [ ] Corriger les vulnérabilités identifiées
- [ ] Mettre à jour les dépendances obsolètes
- [ ] Valider la configuration de sécurité
- [ ] Programmer un audit régulier (mensuel)

EOF

    log_info "Rapport généré: $report_file"
}

# Fonction principale
main() {
    log_info "Démarrage de l'audit de sécurité Redriva"
    log_info "Date: $(date)"
    
    audit_backend_deps
    audit_frontend_deps
    audit_docker_security
    audit_security_headers
    audit_secrets
    audit_file_permissions
    audit_cicd
    generate_report
    
    log_info "Audit de sécurité terminé"
}

# Vérifier les arguments
case "${1:-full}" in
    deps)
        audit_backend_deps
        audit_frontend_deps
        ;;
    docker)
        audit_docker_security
        ;;
    config)
        audit_security_headers
        audit_secrets
        ;;
    cicd)
        audit_cicd
        ;;
    full|*)
        main
        ;;
esac
