# Scripts d'Automatisation Redriva

Ce dossier contient tous les scripts d'automatisation pour le projet Redriva, permettant de gérer le déploiement, la sécurité, les performances et la maintenance de l'application.

## 📁 Structure des Scripts

```
scripts/
├── deploy-unified.sh     # Script de déploiement unifié principal
├── security-audit.sh    # Audit de sécurité automatisé
├── update-deps.sh       # Mise à jour automatique des dépendances
├── performance-test.sh  # Tests de performance et de charge
└── README.md           # Ce fichier
```

## 🚀 Scripts Principaux

### 1. Script de Déploiement Unifié (`deploy-unified.sh`)

**Le script principal pour orchestrer tous les aspects du déploiement.**

```bash
# Déploiement complet (recommandé)
./scripts/deploy-unified.sh deploy

# Construction des images uniquement
./scripts/deploy-unified.sh build

# Tests uniquement
./scripts/deploy-unified.sh test

# Nettoyage de l'environnement
./scripts/deploy-unified.sh cleanup
```

#### Options avancées :
```bash
# Déploiement en environnement de développement
./scripts/deploy-unified.sh deploy --environment development

# Déploiement sans tests (non recommandé en production)
./scripts/deploy-unified.sh deploy --skip-tests

# Déploiement avec tests de performance
./scripts/deploy-unified.sh deploy --performance-tests

# Nettoyage complet avec suppression des images
./scripts/deploy-unified.sh cleanup --clean-images
```

### 2. Audit de Sécurité (`security-audit.sh`)

**Vérifie la sécurité des dépendances, configurations et bonnes pratiques.**

```bash
# Audit complet
./scripts/security-audit.sh

# Audit des dépendances uniquement
./scripts/security-audit.sh deps

# Audit de la configuration Docker
./scripts/security-audit.sh docker

# Audit des configurations (secrets, headers)
./scripts/security-audit.sh config
```

#### Ce qui est vérifié :
- ✅ Vulnérabilités dans les dépendances Python (pip-audit)
- ✅ Vulnérabilités dans les dépendances Node.js (npm audit)
- ✅ Configuration de sécurité Docker
- ✅ En-têtes de sécurité HTTP
- ✅ Gestion des secrets et variables d'environnement
- ✅ Permissions des fichiers
- ✅ Sécurité des workflows CI/CD

### 3. Mise à Jour des Dépendances (`update-deps.sh`)

**Met à jour automatiquement les dépendances avec sauvegarde et tests.**

```bash
# Mise à jour complète (Python + Node.js)
./scripts/update-deps.sh

# Mise à jour Python uniquement
./scripts/update-deps.sh python

# Mise à jour Node.js uniquement
./scripts/update-deps.sh node
```

#### Processus automatisé :
1. 📦 Sauvegarde des fichiers de dépendances actuels
2. 🔍 Audit de sécurité avant mise à jour
3. ⬆️ Mise à jour des packages sécurisés
4. 🧪 Tests de fonctionnement
5. 📊 Audit de sécurité après mise à jour
6. 📝 Génération d'un rapport détaillé

### 4. Tests de Performance (`performance-test.sh`)

**Évalue les performances de l'application et l'utilisation des ressources.**

```bash
# Tests complets de performance
./scripts/performance-test.sh

# Tests de charge uniquement
./scripts/performance-test.sh --load-only

# Tests de ressources système
./scripts/performance-test.sh --resource-only

# Tests de temps de réponse
./scripts/performance-test.sh --response-only
```

#### Métriques collectées :
- 📈 Requêtes par seconde
- ⏱️ Temps de réponse moyen
- 💾 Utilisation CPU et mémoire
- 🔧 Charge système
- 📊 Statistiques par endpoint

## 🔧 Configuration

### Variables d'Environnement

Les scripts utilisent les variables d'environnement suivantes :

```bash
# Configuration générale
export ENVIRONMENT="production"        # ou "development"
export VERSION="v1.0.0"               # Version à déployer

# Configuration Docker Registry (pour CI/CD)
export REGISTRY="ghcr.io"
export NAMESPACE="kesurof"
export REGISTRY_USERNAME="votre-username"
export REGISTRY_TOKEN="votre-token"

# Options de déploiement
export SKIP_TESTS="false"
export SKIP_BACKUP="false"
export CLEAN_IMAGES="false"
export RUN_PERFORMANCE_TESTS="false"
export AUTO_ROLLBACK="false"
```

### Fichiers Générés

Les scripts génèrent des fichiers de logs et rapports dans les dossiers suivants :

```
├── backups/                 # Sauvegardes automatiques
│   ├── deps-YYYYMMDD-HHMMSS/
│   └── deploy-YYYYMMDD-HHMMSS/
├── logs/                    # Logs des scripts
│   ├── update-deps-*.log
│   └── deploy-*.log
├── performance-results/     # Résultats des tests de performance
│   ├── performance-report-*.md
│   ├── resources-*.csv
│   └── metrics-*.json
└── reports/                 # Rapports de déploiement
    ├── deploy-*.md
    └── security-audit-*.md
```

## 🎯 Workflows Recommandés

### Développement Local
```bash
# 1. Audit de sécurité avant développement
./scripts/security-audit.sh

# 2. Déploiement en mode développement
./scripts/deploy-unified.sh deploy --environment development

# 3. Tests de performance (optionnel)
./scripts/performance-test.sh --load-only
```

### Production
```bash
# 1. Mise à jour des dépendances (hebdomadaire)
./scripts/update-deps.sh

# 2. Audit de sécurité complet
./scripts/security-audit.sh

# 3. Déploiement avec tous les tests
./scripts/deploy-unified.sh deploy --performance-tests

# 4. Surveillance post-déploiement
./scripts/performance-test.sh --resource-only
```

### Maintenance Mensuelle
```bash
# 1. Nettoyage complet de l'environnement
./scripts/deploy-unified.sh cleanup --clean-images

# 2. Mise à jour complète des dépendances
./scripts/update-deps.sh

# 3. Audit de sécurité et rapport
./scripts/security-audit.sh

# 4. Tests de performance complets
./scripts/performance-test.sh
```

## 🔒 Sécurité et Bonnes Pratiques

### Permissions
Tous les scripts sont configurés avec les permissions appropriées :
```bash
chmod +x scripts/*.sh
```

### Logs et Audit Trail
- 📝 Tous les scripts génèrent des logs détaillés
- 🕐 Horodatage de toutes les opérations
- 💾 Sauvegarde automatique avant modifications
- 📊 Rapports de synthèse au format Markdown

### Gestion d'Erreur
- ⚠️ Arrêt immédiat en cas d'erreur (`set -e`)
- 🔄 Rollback automatique en option
- 📋 Messages d'erreur détaillés avec codes couleur
- 🛡️ Vérification des prérequis avant exécution

## 🆘 Dépannage

### Problèmes Courants

#### Docker non accessible
```bash
# Vérifier que Docker est démarré
sudo systemctl start docker
sudo systemctl enable docker

# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER
# Puis se reconnecter
```

#### Permissions insuffisantes
```bash
# Rendre tous les scripts exécutables
chmod +x scripts/*.sh

# Vérifier les permissions Docker
docker info
```

#### Échec des tests de connectivité
```bash
# Vérifier que les services sont démarrés
docker compose ps

# Vérifier les logs
docker compose logs

# Vérifier la connectivité réseau
curl -v http://localhost:8000/health
```

#### Problèmes de mémoire
```bash
# Nettoyer Docker
docker system prune -f

# Augmenter les limites dans docker-compose.yml
# Surveiller avec htop ou docker stats
```

## 📚 Intégration CI/CD

### GitHub Actions

Les scripts sont intégrés dans le workflow GitHub Actions défini dans `.github/workflows/security-audit.yml` :

- 🔄 Exécution automatique des audits de sécurité
- 📅 Mise à jour automatique des dépendances (hebdomadaire)
- 🏗️ Construction et tests automatiques
- 📝 Création automatique de Pull Requests

### Utilisation en Production

```bash
# Variables d'environnement pour la production
export ENVIRONMENT="production"
export PUSH_IMAGES="true"
export REGISTRY_USERNAME="${GITHUB_ACTOR}"
export REGISTRY_TOKEN="${GITHUB_TOKEN}"

# Déploiement en production
./scripts/deploy-unified.sh deploy
```

## 📞 Support

En cas de problème avec les scripts :

1. 📋 Consulter les logs générés dans le dossier `logs/`
2. 🔍 Vérifier les prérequis (Docker, Docker Compose, git)
3. 🧪 Tester individuellement chaque composant
4. 📊 Consulter les rapports de performance et sécurité
5. 🔄 Utiliser les sauvegardes pour restaurer un état stable

Les scripts sont conçus pour être robustes et fournir des informations détaillées en cas d'erreur.
