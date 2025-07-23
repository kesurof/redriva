# Architecture Redriva

## 📋 Vue d'ensemble

Redriva est un tableau de bord unifié pour la gestion d'un écosystème média auto-hébergé, développé avec une architecture moderne découplée.

**Stack Technique Actuel (juillet 2025) :**
- **Frontend :** Vue.js 3 + Vuetify + TypeScript
- **Backend :** FastAPI + Python 3.12
- **Infrastructure :** Docker + Nginx + Redis

---

## 🏗️ Architecture Technique

### Frontend : Application Vue.js 3

```
frontend/
├── src/
│   ├── components/       # Composants réutilisables Vuetify
│   ├── views/            # Pages de l'application  
│   ├── composables/      # Stores et logique réactive
│   ├── router/           # Configuration Vue Router
│   └── plugins/          # Configuration Vuetify et thèmes
├── Dockerfile            # Image de développement
└── Dockerfile.prod       # Image de production multi-stage
```

**Fonctionnalités :**
- ✅ Interface Material Design moderne (Vuetify)
- ✅ Système de thèmes avancé (skeleton/wintry + dark/light)
- ✅ Architecture Composition API réactive
- ✅ Tests unitaires complets (Vitest + Vue Test Utils)
- ✅ Hot reload en développement
- ✅ Build optimisé pour production

### Backend : API FastAPI

```
backend/
├── app.py                # Application principale
├── services/             # Services métier
│   ├── monitoring.py     # Métriques Prometheus  
│   ├── queue_service.py  # Gestion file d'attente
│   └── realdebrid.py     # Intégration Real-Debrid
├── database/             # Couche persistance
└── migrations/           # Scripts de migration DB
```

**Fonctionnalités :**
- ✅ API REST pure (JSON uniquement)
- ✅ Authentification Real-Debrid sécurisée
- ✅ Monitoring Prometheus intégré
- ✅ Queue Redis pour tâches asynchrones
- ✅ Logging structuré et observabilité

### Infrastructure Docker

**Développement :**
```yaml
# docker-compose.yml
services:
  frontend:    # Vue.js sur port 5174
  backend:     # FastAPI sur port 8080
  redis:       # Cache et queue
```

**Production :**
```yaml  
# docker-compose.prod.yml
services:
  proxy:       # Nginx reverse proxy (port 3000)
  frontend:    # Vue.js optimisé
  backend:     # FastAPI avec workers
  redis:       # Redis persistant
  worker:      # Workers background
```

---

## 🎯 Fonctionnalités Principales

### Gestion des Médias
- **Dashboard unifié** : Vue d'ensemble système + services + torrents
- **Gestion torrents** : Ajout/suppression, monitoring statuts
- **File d'attente** : Priorisation et gestion jobs background
- **Real-Debrid** : Intégration complète API + authentification

### Interface Utilisateur
- **Design responsive** : Mobile-first avec Vuetify
- **Thèmes adaptatifs** : 2 variantes (skeleton/wintry) + modes clair/sombre
- **Navigation fluide** : Vue Router avec lazy loading
- **Notifications temps réel** : Système de feedback utilisateur

### Sécurité & Performance
- **Token sécurisé** : Real-Debrid jamais exposé côté client
- **Rate limiting** : Protection API et resources
- **Monitoring** : Métriques Prometheus + logs structurés
- **Optimisations** : Images Docker multi-stage, cache Redis

---

## 🚀 Déploiement

### Développement Local

```bash
# Démarrage rapide
docker compose up --build -d

# URLs d'accès
Frontend: http://localhost:5174
Backend:  http://localhost:8080/api
```

### Production

```bash
# Déploiement optimisé
docker compose -f docker-compose.prod.yml up -d

# URL d'accès unifiée
Application: http://localhost:3000
```

### Variables d'Environnement

```bash
# Configuration Real-Debrid
REAL_DEBRID_API_KEY=your_api_key

# Configuration base données
DATABASE_URL=sqlite:///data/redriva.db

# Configuration Redis  
REDIS_URL=redis://redis:6379/0
```

---

## 🔧 Développement

### Frontend Vue.js

```bash
cd frontend/

# Installation dépendances
npm install

# Développement avec hot reload
npm run dev

# Tests unitaires
npm run test

# Build production
npm run build
```

### Backend FastAPI

```bash
cd backend/

# Installation dépendances
pip install -r requirements.txt

# Développement avec reload
uvicorn app:app --reload --host 0.0.0.0 --port 8000

# Tests
pytest

# Migrations
python -m alembic upgrade head
```

---

## 📊 Métriques et Monitoring

### Endpoints de Monitoring

- `/api/ping` : Health check basic
- `/api/metrics` : Métriques Prometheus
- `/api/system/status` : Statut système détaillé

### Dashboards Disponibles

- **Application** : Vue.js interface principale
- **API Documentation** : `/api/docs` (Swagger UI)
- **Métriques** : Compatible Grafana + Prometheus

---

## 🎭 Migration Historique

**Juillet 2025 :** Migration complète SvelteKit → Vue.js 3
- ✅ **100% équivalence fonctionnelle** maintenue
- ✅ **Architecture moderne** Vue.js + Composition API
- ✅ **Tests complets** 74+ tests unitaires
- ✅ **Images Docker optimisées** pour production
- ✅ **Documentation mise à jour**

**Bénéfices obtenus :**
- Écosystème Vue.js plus vaste et mature
- Composants Vuetify Material Design
- Performance améliorée (bundle splitting)
- Maintenance simplifiée

---

*Dernière mise à jour : 23 juillet 2025*  
*Version : 2.0 (Vue.js)*  
*Responsable : Équipe Redriva*
