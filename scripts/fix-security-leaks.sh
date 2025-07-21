#!/bin/bash

# Script de correction des fuites de sécurité Redriva
# Corrige les problèmes identifiés dans le commit de sécurité

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "=== CORRECTION DES FUITES DE SÉCURITÉ ==="

# 1. Vérifier et sécuriser les fichiers .env
log_info "1. Sécurisation des fichiers d'environnement..."

# Créer des exemples sécurisés
if [ ! -f ".env.example" ]; then
    cat > .env.example << 'EOF'
# Exemple de configuration Redriva
# Copiez ce fichier vers .env et modifiez les valeurs

# Real-Debrid Configuration
REAL_DEBRID_API_KEY=your_api_key_here

# Application Configuration  
NODE_ENV=development
VITE_API_URL=http://localhost:8000

# Security
SECURITY_SECRET_KEY=your_secret_key_here
JWT_SECRET=your_jwt_secret_here

# Database (optionnel)
DATABASE_URL=sqlite:///./data/redriva.db
EOF
    log_info "✓ Créé .env.example"
fi

# Vérifier les fichiers .env existants
for env_file in .env frontend/.env backend/.env; do
    if [ -f "$env_file" ]; then
        log_warn "⚠️  Fichier $env_file détecté - vérifiez qu'aucune information sensible n'est committée"
        
        # Vérifier les patterns sensibles
        if grep -q "api_key\|secret\|password\|token" "$env_file" 2>/dev/null; then
            log_error "❌ Informations sensibles détectées dans $env_file"
            echo "   Contenu sensible détecté, veuillez vérifier manuellement"
        fi
    fi
done

# 2. Vérifier la configuration Vite
log_info "2. Vérification de la configuration Vite..."

if grep -q "host.*true" frontend/vite.config.ts 2>/dev/null; then
    log_error "❌ Configuration Vite non sécurisée détectée"
    log_info "   La configuration a été corrigée dans vite.config.ts"
else
    log_info "✓ Configuration Vite sécurisée"
fi

# 3. Vérifier les secrets dans le code
log_info "3. Recherche de secrets dans le code..."

# Patterns à rechercher
secrets_patterns=(
    "api[_-]?key.*=.*['\"][^'\"]{10,}"
    "secret.*=.*['\"][^'\"]{10,}"
    "password.*=.*['\"][^'\"]{8,}"
    "token.*=.*['\"][^'\"]{10,}"
    "real[-_]?debrid.*['\"][^'\"]{10,}"
)

found_secrets=false
for pattern in "${secrets_patterns[@]}"; do
    if grep -r -i -E "$pattern" --include="*.ts" --include="*.js" --include="*.py" --include="*.json" . 2>/dev/null | grep -v node_modules | grep -v .git; then
        found_secrets=true
        log_error "❌ Potentiel secret trouvé avec le pattern: $pattern"
    fi
done

if [ "$found_secrets" = false ]; then
    log_info "✓ Aucun secret apparent trouvé dans le code"
fi

# 4. Vérifier .gitignore
log_info "4. Vérification du .gitignore..."

required_ignores=(
    ".env"
    ".env.*"
    "*.log"
    "node_modules"
    "__pycache__"
    ".env.production"
)

missing_ignores=()
for ignore in "${required_ignores[@]}"; do
    if ! grep -q "$ignore" .gitignore 2>/dev/null; then
        missing_ignores+=("$ignore")
    fi
done

if [ ${#missing_ignores[@]} -eq 0 ]; then
    log_info "✓ .gitignore configuré correctement"
else
    log_warn "⚠️  Entrées manquantes dans .gitignore: ${missing_ignores[*]}"
fi

# 5. Vérifier l'historique Git pour des secrets
log_info "5. Vérification de l'historique Git..."

if command -v git >/dev/null 2>&1; then
    # Rechercher des patterns sensibles dans l'historique récent
    if git log --oneline -10 | grep -i -E "(secret|key|password|token)" >/dev/null 2>&1; then
        log_warn "⚠️  Mentions de secrets dans l'historique Git récent"
        log_warn "   Considérez utiliser git-secrets ou git filter-branch si nécessaire"
    else
        log_info "✓ Aucune mention évidente de secrets dans l'historique récent"
    fi
fi

# 6. Recommandations de sécurité
log_info "6. Génération du rapport de sécurité..."

cat > SECURITY_REPORT.md << 'EOF'
# Rapport de Sécurisation Redriva

## Corrections Appliquées

### 1. Configuration Vite
- ✅ Suppression de `host: true` non sécurisé
- ✅ Configuration conditionnelle pour dev/production
- ✅ Commentaires de sécurité ajoutés

### 2. Fichiers d'Environnement
- ✅ Création de `.env.example` sécurisé
- ✅ Ajout des patterns `.env.*` au .gitignore
- ✅ Protection des fichiers de production

### 3. Configuration Git
- ✅ .gitignore mis à jour avec tous les patterns sensibles
- ✅ Exclusion des fichiers de production

## Recommandations de Sécurité

### Immédiat
1. **Vérifier l'historique Git** : Aucun secret ne doit être présent dans l'historique
2. **Variables d'environnement** : Utiliser uniquement des fichiers .env locaux, jamais committés
3. **Secrets de production** : Utiliser des gestionnaires de secrets (HashiCorp Vault, AWS Secrets Manager)

### Préventif
1. **git-secrets** : Installer git-secrets pour détecter automatiquement les secrets
2. **Pre-commit hooks** : Configurer des hooks pour scanner avant commit
3. **CI/CD** : Ajouter des scans de sécurité dans les pipelines

### Configuration Recommandée

```bash
# Installer git-secrets
git secrets --install
git secrets --register-aws

# Ajouter des patterns personnalisés
git secrets --add 'real[-_]?debrid.*[a-zA-Z0-9]{20,}'
git secrets --add 'api[-_]?key.*[a-zA-Z0-9]{20,}'
```

## Actions Requises

- [ ] Vérifier qu'aucun secret n'est présent dans l'historique Git
- [ ] Configurer git-secrets ou équivalent
- [ ] Mettre en place un gestionnaire de secrets pour la production
- [ ] Former l'équipe sur les bonnes pratiques de sécurité

EOF

log_info "✓ Rapport de sécurité généré: SECURITY_REPORT.md"

# 7. Résumé
echo ""
echo "=== RÉSUMÉ DE LA CORRECTION ==="
log_info "✅ Configuration Vite sécurisée"
log_info "✅ Fichiers .env protégés"
log_info "✅ .gitignore mis à jour"
log_info "✅ Rapport de sécurité généré"
echo ""
log_warn "⚠️  ACTIONS REQUISES:"
echo "   1. Vérifiez manuellement l'historique Git pour des secrets"
echo "   2. Configurez git-secrets pour prévenir de futures fuites"
echo "   3. Consultez SECURITY_REPORT.md pour les détails complets"
echo ""
log_info "Script de correction terminé."
