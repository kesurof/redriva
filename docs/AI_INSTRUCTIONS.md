# Instructions Complètes pour Assistant IA - Projet Redriva

## 📋 Mission et Contexte

Tu es un assistant IA expert chargé d'assister dans le développement du projet **Redriva**, un tableau de bord unifié pour la gestion d'un écosystème média auto-hébergé. 

**RÈGLE ABSOLUE :** Ce document est ta source de vérité. Tu dois obligatoirement suivre les instructions et principes décrits, même si cela contredit tes connaissances internes.

---

## 🎯 Philosophie Fondamentale : "Zéro Réécriture de Code"

### Principe Clé
Le code applicatif (Python, Vue.js) est **identique** pour le développement et la production. Seul son "emballage" (configuration Docker) change.

**Analogie du moteur :**
- **Code applicatif (le moteur) :** Écrit une seule fois
- **Environnement de développement (châssis de test) :** Volumes Docker + hot reload
- **Environnement de production (carrosserie optimisée) :** Dockerfile multi-stage, optimisé et sécurisé

### Objectif Final
Produire des **images Docker uniques, propres et optimisées pour la production**, construites et publiées automatiquement via GitHub Actions pour un déploiement facile par tout utilisateur.

### ✅ Simplification Accomplie (Juillet 2025)

**Révolution de l'architecture :** Le projet a été drastiquement simplifié selon la philosophie "Zéro Réécriture" :

**Supprimé (complexité inutile) :**
- ❌ Multiples Dockerfiles par service (`Dockerfile.prod`)
- ❌ Scripts de déploiement complexes (12 scripts → 2 scripts)
- ❌ Duplications de configuration
- ❌ Maintenance double

**Unifié (approche révolutionnaire) :**
- ✅ **Un seul Dockerfile** par service (multi-stage)
- ✅ **Scripts ultra-simplifiés** : `dev.sh` et `deploy.sh`
- ✅ **Configuration via Docker Compose** uniquement
- ✅ **Workflow fluide** : Installation en une commande

**Résultat :** Complexité divisée par 3, maintenance simplifiée, respect parfait de la philosophie "Zéro Réécriture".

---

## 🏗️ Architecture Technique (Source de Vérité)

### Stack Frontend
```
Framework: Vue.js 3 avec Composition API
UI Library: Vuetify v3 (Material Design) - PAS de Skeleton UI ou Tailwind
Styling: Intégré dans Vuetify uniquement
Router: Vue Router v4
State Management: Composables Vue (PAS de Pinia/Vuex)
Tests: Vitest + Vue Test Utils
Build: Vite + TypeScript strict
Port développement: 5174
```

### Stack Backend
```
Framework: FastAPI (API pure JSON, AUCUN HTML)
Language: Python 3.12+
Server: Uvicorn
Database: SQLite + migrations SQL manuelles
Queue: Redis + ARQ pour jobs asynchrones
Monitoring: Prometheus metrics intégrées
Auth: Real-Debrid OAuth
Logging: Structlog
Port développement: 8080
```

### Infrastructure
```
Conteneurisation: Docker + Docker Compose
Reverse Proxy: Nginx (production)
Cache/Queue: Redis 7-alpine
CI/CD: GitHub Actions (à venir)
```

---

## 📁 Structure des Dossiers (À RESPECTER STRICTEMENT)

```
redriva/
├── frontend/                     # Application Vue.js 3
│   ├── src/
│   │   ├── components/           # Composants réutilisables Vuetify
│   │   ├── views/               # Pages principales de l'application
│   │   ├── composables/         # Stores Vue (state management)
│   │   ├── router/              # Configuration Vue Router
│   │   ├── plugins/             # Configuration Vuetify + thèmes
│   │   ├── services/            # Services API
│   │   ├── types/               # Types TypeScript
│   │   └── test/               # Tests Vitest
│   ├── Dockerfile              # Multi-stage UNIFIÉ (dev + production)
│   ├── package.json
│   └── vite.config.ts
├── backend/                     # API FastAPI
│   ├── app.py                  # Point d'entrée principal
│   ├── services/               # Logique métier (monitoring, queue, etc.)
│   ├── database/               # Persistance + migrations SQL
│   ├── migrations/             # Scripts SQL de migration
│   ├── requirements.txt        # Dépendances Python
│   └── Dockerfile              # Image UNIFIÉE dev/prod
├── scripts/                    # Scripts simplifiés
│   ├── dev.sh                  # Script développement ultra-simplifié
│   └── deploy.sh               # Script production ultra-simplifié
├── proxy/                      # Configuration Nginx (production)
├── docs/                       # Documentation complète
│   └── nouvelle docs/          # Documentation mise à jour
├── docker-compose.yml          # Environnement développement
├── docker-compose.prod.yml     # Configuration production
└── .env                        # Variables d'environnement (NON versionné)
```

---

## 🛠️ Workflow de Développement (OBLIGATOIRE)

### Démarrage de l'Environnement

**Méthode Recommandée (Scripts Simplifiés) :**
```bash
# Démarrage complet avec scripts optimisés
./scripts/dev.sh start

# Vérification du statut
./scripts/dev.sh status

# Voir les logs en temps réel
./scripts/dev.sh logs
```

**Méthode Alternative (Docker Compose Direct) :**
```bash
# Démarrage environnement développement
docker compose up --build -d

# Vérification santé
curl http://localhost:5174  # Frontend
curl http://localhost:8080/api/ping  # Backend
```

### Gestion des Dépendances

#### Backend (Python)
```bash
# 1. Éditer backend/requirements.txt
# 2. Reconstruire l'image
docker compose build backend
```

#### Frontend (Node.js)
```bash
# JAMAIS exécuter npm install directement sur la machine locale
# Toujours utiliser le conteneur :

# Méthode 1: Via scripts simplifiés (RECOMMANDÉ)
./scripts/dev.sh shell frontend
# Puis dans le shell du conteneur: npm install <nom-du-paquet>

# Méthode 2: Via docker compose
docker compose run --rm frontend npm install <nom-du-paquet>

# Puis reconstruire
docker compose build frontend
```

### Procédure de Développement d'une Page

**Toujours suivre cette séquence :**

1. **Créer les fichiers de la page :**
   - `src/views/NomPage.vue` (interface utilisateur)
   - Ajouter la route dans `src/router/index.ts`

2. **Dans le composant Vue :**
   - Utiliser la Composition API (`<script setup lang="ts">`)
   - Faire les appels API via `useApi()` composable
   - Construire l'interface avec les composants Vuetify

3. **Tester immédiatement :**
   - Vérifier le fonctionnement en mode développement
   - Ajouter des tests unitaires si nécessaire

---

## 🎨 Standards de Code (À RESPECTER ABSOLUMENT)

### Frontend Vue.js 3

```vue
<!-- Template de base pour une page -->
<template>
  <v-container>
    <v-row>
      <v-col>
        <v-card>
          <v-card-title>{{ title }}</v-card-title>
          <v-card-text>
            <!-- Contenu avec composants Vuetify -->
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'

// Props et état local
const title = ref('Nom de la Page')
const { apiCall } = useApi()

// Logique de la page
onMounted(async () => {
  // Appels API au montage
})
</script>
```

### Backend FastAPI

```python
# Structure d'un endpoint
from fastapi import APIRouter, HTTPException
from typing import List, Dict, Any

router = APIRouter(prefix="/api", tags=["nom_service"])

@router.get("/endpoint")
async def get_data() -> Dict[str, Any]:
    """Documentation de l'endpoint."""
    try:
        # Logique métier
        return {"status": "success", "data": []}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---

## 🔄 Communication Frontend ↔ Backend

### URL de Communication
- **Développement :** `http://localhost:8080/api/...`
- **Conteneur à conteneur :** `http://backend:8000/api/...`

### Format des Réponses API
```typescript
// Format standard des réponses
interface ApiResponse<T> {
  status: 'success' | 'error'
  data?: T
  message?: string
  error?: string
}
```

---

## 🧪 Gestion des Tests

### Frontend (Vitest)
```bash
# Exécuter les tests dans le conteneur
docker compose exec frontend npm run test

# Tests en mode watch
docker compose exec frontend npm run test:watch
```

### Backend (Pytest)
```bash
# Exécuter les tests Python
docker compose exec backend pytest

# Avec couverture
docker compose exec backend pytest --cov
```

---

## 🚀 Pages Existantes (État Actuel)

Voici les pages actuellement disponibles dans l'application :

1. **Dashboard** (`/`) - Tableau de bord principal
2. **Services** (`/services`) - Liste des services monitored
3. **Torrents** (`/torrents`) - Liste des torrents
4. **TorrentDetail** (`/torrents/:id`) - Détails d'un torrent
5. **Demo** (`/demo`) - Page de démonstration
6. **ComposablesDemo** (`/composables`) - Démonstration des composables
7. **ComponentsDemo** (`/components`) - Démonstration des composants
8. **Settings** (`/settings`) - Paramètres de l'application

---

## ⚠️ Anti-Patterns à Éviter Absolument

### ❌ Ne JAMAIS faire :
- Exécuter `npm install` directement sur la machine locale
- Utiliser Skeleton UI ou Tailwind CSS (utiliser UNIQUEMENT Vuetify)
- Mélanger les approches state management (utiliser UNIQUEMENT les composables Vue)
- Créer des endpoints qui retournent du HTML (API doit être JSON pur)
- Modifier les fichiers de configuration production sans tester
- Créer des Dockerfiles multiples par service (un seul Dockerfile unifié)
- Utiliser les commandes Docker Compose complexes quand les scripts simplifiés existent
- Ignorer les scripts `dev.sh` et `deploy.sh` au profit de commandes manuelles

### ✅ Toujours faire :
- Utiliser Docker pour toutes les opérations
- Privilégier les scripts simplifiés (`./scripts/dev.sh`, `./scripts/deploy.sh`)
- Suivre la philosophie "Zéro Réécriture"
- Respecter la structure des dossiers unifiée
- Tester chaque modification avec `./scripts/dev.sh test`
- Utiliser `./scripts/dev.sh logs` pour le debugging
- Documenter les changements significatifs
- Maintenir l'approche Dockerfile unifié (un seul par service)

---

## 🔧 Commandes Utiles pour l'Assistant

### Scripts Simplifiés (MÉTHODE RECOMMANDÉE)

#### Développement
```bash
./scripts/dev.sh start          # Démarrer l'environnement
./scripts/dev.sh stop           # Arrêter l'environnement
./scripts/dev.sh restart        # Redémarrer l'environnement
./scripts/dev.sh rebuild        # Reconstruire les images et redémarrer
./scripts/dev.sh status         # Voir l'état des services
./scripts/dev.sh logs           # Afficher tous les logs
./scripts/dev.sh logs backend   # Logs du backend uniquement
./scripts/dev.sh logs frontend  # Logs du frontend uniquement
./scripts/dev.sh shell          # Shell dans le backend
./scripts/dev.sh shell frontend # Shell dans le frontend
./scripts/dev.sh monitor        # Monitoring en temps réel
./scripts/dev.sh test           # Lancer tous les tests
./scripts/dev.sh lint           # Vérifier la qualité du code
./scripts/dev.sh db:reset       # Remettre à zéro la base de données
```

#### Production
```bash
./scripts/deploy.sh deploy      # Déployer en production
./scripts/deploy.sh stop        # Arrêter la production
./scripts/deploy.sh status      # Statut de la production
./scripts/deploy.sh logs        # Logs de production
```

### Debugging et Surveillance (Méthode Alternative)
```bash
# Voir les logs des services
docker compose logs frontend --follow
docker compose logs backend --follow

# État des conteneurs
docker compose ps

# Reconstruction complète
docker compose down --rmi all
docker compose up --build -d

# Nettoyage complet (en cas de problème)
docker compose down --rmi all
rm -rf frontend/node_modules frontend/package-lock.json
docker compose up --build -d
```

### Accès aux Conteneurs
```bash
# Méthode recommandée avec scripts
./scripts/dev.sh shell          # Shell dans le backend  
./scripts/dev.sh shell frontend # Shell dans le frontend

# Méthode alternative Docker Compose
docker compose exec frontend sh
docker compose exec backend bash

# Exécuter une commande ponctuelle
docker compose exec frontend npm run lint
docker compose exec backend python -m pytest
```

---

## 📚 Documentation de Référence

### Fichiers de Documentation Disponibles
- `ARCHITECTURE.md` - Architecture détaillée du projet
- `AI_DEVELOPMENT_GUIDE.md` - Guide de développement pour IA
- `BEST_PRACTICES.md` - Bonnes pratiques observées
- `CONTRIBUTING.md` - Guide de contribution
- `DEPLOIEMENT.md` - Procédures de déploiement
- `INSTALL.md` - Instructions d'installation
- `QUEUE.md` - Documentation du système de queue
- `USAGE.md` - Guide d'utilisation
- `nouvelle docs/SIMPLIFICATION-COMPLETE.md` - Simplification de l'architecture
- `nouvelle docs/HELP.md` - Guide d'utilisation des scripts
- `nouvelle docs/README.md` - Documentation mise à jour

### Technologies de Référence
- [Vue.js 3 Documentation](https://vuejs.org/)
- [Vuetify 3 Documentation](https://vuetifyjs.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## 🎯 Objectifs Prioritaires pour l'Assistant

1. **Respecter la philosophie "Zéro Réécriture"** dans toutes les suggestions
2. **Utiliser UNIQUEMENT Vuetify** pour l'interface utilisateur
3. **Maintenir la compatibilité Docker** pour tous les changements
4. **Privilégier les scripts simplifiés** (`./scripts/dev.sh`, `./scripts/deploy.sh`)
5. **Tester immédiatement** toute modification proposée
6. **Documenter** les changements importants
7. **Préparer le terrain** pour les images Docker de production optimisées

### 🔄 Workflow Recommandé pour l'Assistant

**Lors du développement d'une nouvelle fonctionnalité :**

1. **Analyser** la demande en respectant l'architecture unifiée
2. **Utiliser les scripts simplifiés** pour démarrer l'environnement
3. **Développer** en suivant les standards Vue.js 3 + Vuetify
4. **Tester** avec `./scripts/dev.sh test`
5. **Valider** le fonctionnement en temps réel
6. **Documenter** les changements si nécessaire

**En cas de problème :**

1. **Diagnostiquer** avec `./scripts/dev.sh logs`
2. **Accéder** aux conteneurs avec `./scripts/dev.sh shell`
3. **Reconstruire** si nécessaire avec `./scripts/dev.sh rebuild`
4. **Nettoyer** en dernier recours avec méthode Docker Compose directe

---

## 🔒 Sécurité et Bonnes Pratiques

- **JAMAIS** commiter de tokens ou secrets dans le code
- Utiliser les variables d'environnement via `.env`
- Valider toutes les entrées utilisateur
- Logs structurés pour l'observabilité
- Tests automatisés pour la stabilité

---

**Rappel Final :** Cette documentation est ta référence absolue. En cas de doute, reviens toujours à ces principes et cette architecture. L'objectif est de créer un projet production-ready avec une expérience de développement optimale.
