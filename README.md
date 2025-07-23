# 🎬 Redriva - Gestionnaire Real-Debrid Moderne

> **Tableau de bord unifié pour la gestion d'un écosystème média auto-hébergé**

Redriva est une application web moderne qui simplifie la gestion de vos téléchargements Real-Debrid avec une interface élégante et des fonctionnalités avancées de monitoring.

## ✨ Fonctionnalités

- 🎯 **Interface moderne** - Vue.js 3 + Vuetify Material Design
- 🔄 **Gestion des torrents** - Ajout, suivi et téléchargement automatisé
- 📊 **Monitoring en temps réel** - Métriques Prometheus intégrées
- 🔐 **Authentification sécurisée** - Intégration Real-Debrid OAuth
- 🐳 **Déploiement simplifié** - Docker avec scripts ultra-simplifiés
- ⚡ **Performance optimisée** - Cache Redis et workers asynchrones

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
# 🌐 Interface: http://localhost:5174
# 🔧 API: http://localhost:8080/api
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

## 🛠️ Commandes Essentielles

### Développement
```bash
./scripts/dev.sh start      # 🚀 Démarrer l'environnement
./scripts/dev.sh stop       # ⏹️  Arrêter l'environnement
./scripts/dev.sh logs       # 📋 Voir les logs en temps réel
./scripts/dev.sh shell      # 🐚 Accéder au shell backend
./scripts/dev.sh test       # 🧪 Lancer tous les tests
./scripts/dev.sh rebuild    # 🔄 Reconstruire complètement
```

### Production
```bash
./scripts/deploy.sh deploy  # 🚀 Déployer en production
./scripts/deploy.sh status  # 📊 Voir le statut des services
./scripts/deploy.sh logs    # 📋 Logs de production
./scripts/deploy.sh stop    # ⏹️  Arrêter la production
```

## 🏗️ Architecture

Redriva utilise une **architecture unifiée révolutionnaire** basée sur la philosophie **"Zéro Réécriture de Code"** :

### Stack Technique
```
Frontend  → Vue.js 3 + Vuetify + TypeScript
Backend   → FastAPI + Python 3.12 + SQLite
Cache     → Redis + ARQ (jobs asynchrones)
Proxy     → Nginx (production)
Deploy    → Docker + Scripts simplifiés
```

### Principe Fondamental
- **Le même code** s'exécute en développement ET en production
- **Seule la configuration** Docker change
- **Un seul Dockerfile** par service (multi-stage)
- **Complexité divisée par 3** grâce aux scripts unifiés

```
📁 Structure Simplifiée
redriva/
├── frontend/           # Interface Vue.js + Vuetify
├── backend/            # API FastAPI + logique métier
├── scripts/            # Scripts dev.sh + deploy.sh
├── docs/               # Documentation complète
├── docker-compose.yml  # Configuration développement
└── docker-compose.prod.yml # Configuration production
```

## 📱 Pages Disponibles

| Page | URL | Description |
|------|-----|-------------|
| **Dashboard** | `/` | Tableau de bord principal avec vue d'ensemble |
| **Torrents** | `/torrents` | Gestion et suivi des téléchargements |
| **Services** | `/services` | Monitoring des services connectés |
| **Paramètres** | `/settings` | Configuration et préférences |
| **Démonstration** | `/demo` | Tests et démonstrations des fonctionnalités |

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

```bash
# Tests Frontend (Vue.js + Vitest)
./scripts/dev.sh shell frontend
npm run test

# Tests Backend (Python + Pytest)
./scripts/dev.sh shell
python -m pytest

# Qualité du code
./scripts/dev.sh lint

# Tests complets
./scripts/dev.sh test
```

## 🚨 Dépannage

### Problèmes Courants

**Services ne démarrent pas :**
```bash
./scripts/dev.sh rebuild
```

**Erreurs de dépendances :**
```bash
./scripts/dev.sh shell frontend
npm install
# Puis reconstruire
docker compose build frontend
```

**Base de données corrompue :**
```bash
./scripts/dev.sh db:reset
```

**Nettoyage complet :**
```bash
docker compose down --rmi all
rm -rf frontend/node_modules
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
- ✅ **Validation stricte** - Toutes les entrées validées
- ✅ **Logs structurés** - Observabilité complète
- ✅ **Tests automatisés** - Qualité garantie

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[Installation](docs/INSTALL.md)** | Guide d'installation détaillé |
| **[Architecture](docs/ARCHITECTURE.md)** | Architecture technique complète |
| **[Guide de Développement](docs/AI_DEVELOPMENT_GUIDE.md)** | Standards et bonnes pratiques |
| **[Déploiement](docs/DEPLOIEMENT.md)** | Procédures de déploiement |
| **[Contribution](docs/CONTRIBUTING.md)** | Guide de contribution |
| **[API](docs/USAGE.md)** | Documentation de l'API |

## 🤝 Contribution

Nous accueillons toutes les contributions ! Consultez notre [Guide de Contribution](docs/CONTRIBUTING.md) pour commencer.

### Workflow de Contribution
1. Fork du projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Développer avec `./scripts/dev.sh`
4. Tester avec `./scripts/dev.sh test`
5. Commit (`git commit -m 'Add AmazingFeature'`)
6. Push (`git push origin feature/AmazingFeature`)
7. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🌟 Remerciements

- **[Real-Debrid](https://real-debrid.com/)** - Service de téléchargement premium
- **[Vue.js](https://vuejs.org/)** - Framework frontend réactif
- **[Vuetify](https://vuetifyjs.com/)** - Composants Material Design
- **[FastAPI](https://fastapi.tiangolo.com/)** - Framework API moderne
- **[Docker](https://docker.com/)** - Conteneurisation simplifiée

---

<div align="center">

**Redriva** - *Révolutionnant la gestion Real-Debrid*

[🌐 Site Web](https://github.com/kesurof/redriva) • [📖 Documentation](docs/) • [🐛 Issues](https://github.com/kesurof/redriva/issues) • [💬 Discussions](https://github.com/kesurof/redriva/discussions)

</div>
