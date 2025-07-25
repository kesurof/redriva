# 🎬 Redriva - Gestionnaire Real-Debrid Moderne

> **Tableau de bord unifié pour la gestion d'un écosystème média auto-hébergé**

Redriva est une application web moderne qui simplifie la gestion de vos téléchargements Real-Debrid avec une interface élégante et des fonctionnalités avancées de monitoring.

## ✨ Fonctionnalités

- 🎯 **Interface moderne** - SvelteKit + TailwindCSS + TypeScript
- 🔄 **Gestion des torrents** - Ajout, suivi et téléchargement automatisé
- 📊 **Monitoring en temps réel** - Métriques et statistiques intégrées
- 🔐 **Authentification sécurisée** - Intégration Real-Debrid OAuth
- 🐳 **Déploiement simplifié** - Docker avec configuration "Zéro Réécriture"
- ⚡ **Performance optimisée** - SvelteKit pour des performances exceptionnelles
- 🎨 **Thèmes personnalisables** - Mode sombre/clair et couleurs personnalisées

## 🚀 Démarrage Rapide

### Prérequis
- Docker et Docker Compose
- Token Real-Debrid ([obtenir ici](https://real-debrid.com/apitoken))

### Installation Express (Développement)

```bash
# 1. Cloner le projet
git clone https://github.com/kesurof/redriva.git
cd redriva

# 2. Configuration (optionnelle)
cp .env.example .env
# Éditer .env avec votre token Real-Debrid

# 3. Démarrage en une commande
./scripts/dev.sh start

# 4. Accès immédiat
# 🌐 Interface SvelteKit: http://localhost:5174
# 🔧 API Backend: http://localhost:8080/api
```

### Déploiement Production

```bash
# 1. Configuration production
cp .env.prod.example .env.prod
# Éditer .env.prod avec vos valeurs

# 2. Déploiement en une commande
./scripts/deploy.sh deploy

# 3. Accès sécurisé
# 🌐 Application: http://localhost:3000
```

## 🛠️ Architecture "Zéro Réécriture"

Redriva respecte strictement la philosophie **"Zéro Réécriture de Code"** :

### Principe Fondamental
- **❌ JAMAIS d'installation locale** - Docker obligatoire
- **Même code, configurations différentes** - Développement et production utilisent les mêmes sources
- **Scripts unifiés** - `./scripts/dev.sh` et `./scripts/deploy.sh` pour tout contrôler
- **Un seul Dockerfile** par service avec multi-stage build
- **Configuration par environnement** - Variables d'environnement pour adapter le comportement

### Commandes Essentielles

#### Développement
```bash
./scripts/dev.sh start            # 🚀 Démarrer l'environnement
./scripts/dev.sh stop             # ⏹️  Arrêter l'environnement  
./scripts/dev.sh logs             # 📋 Voir les logs en temps réel
./scripts/dev.sh shell            # 🐚 Accéder au shell backend
./scripts/dev.sh shell frontend   # 🐚 Accéder au shell frontend
./scripts/dev.sh test             # 🧪 Lancer tous les tests
./scripts/dev.sh rebuild          # 🔄 Reconstruire complètement
./scripts/dev.sh clear-cache      # 🧹 Effacer le cache Docker (backend)
./scripts/dev.sh clear-cache all  # 🧹 Effacer le cache de tous les services

## 🛠️ Architecture "Zéro Réécriture"

Redriva respecte strictement la philosophie **"Zéro Réécriture de Code"** :

### Principe Fondamental
- **Même code, configurations différentes** - Développement et production utilisent les mêmes sources
- **Docker uniquement** - Aucune installation locale requise
- **Un seul Dockerfile** par service avec multi-stage build
- **Configuration par environnement** - Variables d'environnement pour adapter le comportement

### Commandes Essentielles

#### Développement
```bash
docker compose up -d              # 🚀 Démarrer l'environnement
docker compose down               # ⏹️  Arrêter l'environnement  
docker compose logs -f            # 📋 Voir les logs en temps réel
docker compose exec backend bash  # 🐚 Accéder au shell backend
docker compose exec frontend sh   # 🐚 Accéder au shell frontend
docker compose up -d --build      # � Reconstruire complètement

Redriva utilise une **architecture unifiée révolutionnaire** basée sur la philosophie **"Zéro Réécriture de Code"** :

### Stack Technique
```
Frontend  → SvelteKit + TailwindCSS + TypeScript
Backend   → FastAPI + Python 3.12 + SQLite
Deploy    → Docker + Configuration par environnement
```

### Principe Fondamental
- **Le même code** s'exécute en développement ET en production
- **Seule la configuration** Docker change
- **Un seul Dockerfile** par service (multi-stage)
- **❌ JAMAIS d'installation locale** - Docker obligatoire
- **Complexité divisée par 3** grâce à l'approche unifiée

```
📁 Structure Simplifiée
redriva/
├── frontend/           # Application SvelteKit + TailwindCSS
├── backend/            # API FastAPI + logique métier
├── scripts/            # Scripts dev.sh + deploy.sh (OBLIGATOIRES)
├── docs/               # Documentation complète
├── docker-compose.yml  # Configuration développement
└── docker-compose.prod.yml # Configuration production
```

## 📱 Pages Disponibles

| Page | URL | Description |
|------|-----|-------------|
| **Dashboard** | `/` | Tableau de bord principal avec statistiques |
| **Torrents** | `/torrents` | Gestion complète des téléchargements |
| **Services** | `/services` | Monitoring des services connectés |
| **Thèmes** | `/themes` | Personnalisation interface et couleurs |
| **Paramètres** | `/settings` | Configuration et préférences |

## 🔧 Configuration

### Variables d'Environnement

**Développement (`.env`) :**
```bash
# Real-Debrid
RD_TOKEN=votre_token_real_debrid

# Base de données
DB_PATH=./data/redriva.db

# Redis
REDIS_URL=redis://redis:6379/0

# Logs
LOG_LEVEL=DEBUG
```

**Production (`.env.prod`) :**
```bash
# Real-Debrid (OBLIGATOIRE)
RD_TOKEN=votre_token_real_debrid

# Production optimisée
ENVIRONMENT=production
LOG_LEVEL=INFO
DB_PATH=/app/data/redriva.db
REDIS_URL=redis://redis:6379/0
```

### Ports par Défaut

| Service | Développement | Production |
|---------|---------------|------------|
| **Frontend** | `5174` | `3000` (via proxy) |
| **Backend** | `8080` | `3000/api` (via proxy) |
| **Redis** | `6379` (interne) | `6379` (interne) |

## 🧪 Tests et Qualité

### Frontend (SvelteKit)
```bash
# Accéder au conteneur frontend via script
./scripts/dev.sh shell frontend

# Tests unitaires (Vitest)
npm run test

# Tests en mode watch
npm run test:watch

# Couverture de code
npm run test:coverage

# Vérification TypeScript
npm run check

# Linting et formatage
npm run lint
npm run format
```

### Backend (FastAPI)
```bash
# Accéder au conteneur backend via script
./scripts/dev.sh shell

# Tests Python (Pytest)
python -m pytest

# Tests avec couverture
python -m pytest --cov=app

# Linting Python
flake8 app/
```

## 🚨 Dépannage

### Problèmes Courants

**Services ne démarrent pas :**
```bash
./scripts/dev.sh rebuild
```

**Variables d'environnement modifiées :**
```bash
# Effacer le cache pour prendre en compte les nouveaux tokens
./scripts/dev.sh clear-cache backend
```

**Erreurs de dépendances frontend :**
```bash
./scripts/dev.sh shell frontend
npm install
# Puis reconstruire sans cache
./scripts/dev.sh clear-cache frontend
```

**Cache Docker corrompu :**
```bash
# Effacer tous les caches et reconstruire
./scripts/dev.sh clear-cache all
```

**Base de données corrompue :**
```bash
./scripts/dev.sh db:reset
```

**Nettoyage complet du projet :**
```bash
./scripts/dev.sh stop
./scripts/dev.sh clear-cache all
./scripts/dev.sh start
```

### Logs et Monitoring

```bash
# Logs en temps réel
./scripts/dev.sh logs

# Logs spécifiques
./scripts/dev.sh logs backend
./scripts/dev.sh logs frontend

# Monitoring des performances
./scripts/dev.sh monitor
```

## 🔒 Sécurité

- ✅ **Tokens sécurisés** - Variables d'environnement uniquement
- ✅ **Réseau isolé** - Backend inaccessible directement
- ✅ **Validation stricte** - Pydantic + TypeScript
- ✅ **CORS configuré** - Protection contre les attaques XSS
- ✅ **Docker isolation** - Containérisation complète
- ✅ **Pas d'installation locale** - Principe "Zéro Réécriture"

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[Migration SvelteKit](README_SVELTEKIT.md)** | Guide complet de migration Vue.js → SvelteKit |
| **[Architecture](docs/ARCHITECTURE.md)** | Architecture technique "Zéro Réécriture" |
| **[Instructions IA](docs/AI_INSTRUCTIONS.md)** | Instructions complètes pour assistant IA |
| **[API](docs/USAGE.md)** | Documentation de l'API backend |

## 🤝 Contribution

Nous accueillons toutes les contributions ! Consultez notre [Guide de Contribution](docs/CONTRIBUTING.md) pour commencer.

### Workflow de Contribution
1. Fork du projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Développer avec `./scripts/dev.sh start`
4. Tester avec `./scripts/dev.sh test`
5. Commit (`git commit -m 'Add AmazingFeature'`)
6. Push (`git push origin feature/AmazingFeature`)
7. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🌟 Remerciements

- **[SvelteKit](https://kit.svelte.dev/)** - Framework full-stack moderne
- **[TailwindCSS](https://tailwindcss.com/)** - Framework CSS utilitaire
- **[TypeScript](https://www.typescriptlang.org/)** - JavaScript avec types
- **[Real-Debrid](https://real-debrid.com/)** - Service de téléchargement premium
- **[FastAPI](https://fastapi.tiangolo.com/)** - Framework API moderne
- **[Docker](https://docker.com/)** - Conteneurisation "Zéro Réécriture"

---

<div align="center">

**Redriva 2.0** - *Maintenant avec SvelteKit et architecture "Zéro Réécriture"*


[🌐 Site Web](https://github.com/kesurof/redriva) • [📖 Documentation](docs/) • [🐛 Issues](https://github.com/kesurof/redriva/issues) • [💬 Discussions](https://github.com/kesurof/redriva/discussions)

</div>
