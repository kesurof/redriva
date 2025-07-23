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

### 🧹 Fonction Clear-Cache (NOUVELLE - Juillet 2025)

**Fonction essentielle** pour effacer le cache Docker et reconstruire sans cache. Particulièrement utile pour :
- Changements de variables d'environnement (tokens Real-Debrid)
- Problèmes de cache Docker corrompus
- Modifications de configuration

#### Syntaxe et Options

```bash
# Effacer le cache du backend (défaut)
./scripts/dev.sh clear-cache

# Effacer le cache du frontend
./scripts/dev.sh clear-cache frontend

# Effacer le cache de tous les services
./scripts/dev.sh clear-cache all
```

#### Équivalences Docker

| Commande Clear-Cache | Équivalent Docker Compose |
|---------------------|---------------------------|
| `clear-cache` | `docker compose down && docker compose build --no-cache backend && docker compose up -d` |
| `clear-cache frontend` | `docker compose down && docker compose build --no-cache frontend && docker compose up -d` |
| `clear-cache all` | `docker compose down && docker compose build --no-cache && docker compose up -d` |

#### Cas d'Usage Principaux

**1. Token Real-Debrid modifié :**
```bash
# 1. Modifier le token dans .env
echo "REALDEBRID_API_TOKEN=nouveau_token" >> .env

# 2. Reconstruire sans cache pour prendre en compte
./scripts/dev.sh clear-cache backend

# 3. Vérifier l'authentification
curl -s http://localhost:8080/api/auth/status | jq
```

**2. Problèmes de dépendances :**
```bash
# Après modification package.json ou requirements.txt
./scripts/dev.sh clear-cache frontend  # ou backend

# Vérification
./scripts/dev.sh status
```

**3. Cache Docker corrompu :**
```bash
# Quand des erreurs étranges persistent
./scripts/dev.sh clear-cache all
```

**⚠️ Attention :** Cette opération prend plus de temps (20-30s par service) car elle télécharge toutes les dépendances.

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

### 🎨 Bonnes Pratiques Vuetify (OBLIGATOIRES)

#### Principe Fondamental
**INTERDICTION ABSOLUE d'utiliser du CSS custom** - Utiliser UNIQUEMENT les ressources natives Vuetify pour respecter la philosophie "Zéro Réécriture".

#### 1. Classes Utilitaires Vuetify (Remplacent le CSS)

```vue
<!-- ✅ CORRECT - Classes Vuetify natives -->
<template>
  <v-card 
    elevation="3"
    class="ma-4 pa-6 rounded-lg"
  >
    <v-card-title class="d-flex justify-space-between align-center pb-4">
      <h3 class="text-h6 font-weight-bold">{{ title }}</h3>
      <v-chip 
        color="success" 
        variant="tonal" 
        size="small"
        class="text-uppercase"
      >
        En ligne
      </v-chip>
    </v-card-title>
    
    <v-card-text class="px-6 py-0">
      <v-row dense>
        <v-col cols="12" sm="6" md="4">
          <!-- Contenu responsive -->
        </v-col>
      </v-row>
    </v-card-text>
    
    <v-card-actions class="px-6 pt-4">
      <v-spacer />
      <v-btn-group variant="outlined" divided density="comfortable">
        <v-btn color="primary" prepend-icon="mdi-open-in-new">
          Ouvrir
        </v-btn>
        <v-btn color="warning" prepend-icon="mdi-restart">
          Redémarrer
        </v-btn>
      </v-btn-group>
    </v-card-actions>
  </v-card>
</template>

<!-- ❌ INTERDIT - CSS custom -->
<style scoped>
.custom-card {
  margin: 16px;
  padding: 24px;
  /* PAS DE CSS CUSTOM ! */
}
</style>
```

#### 2. Système de Thèmes Vuetify

```javascript
// plugins/vuetify.ts - Configuration des thèmes
import { createVuetify } from 'vuetify'

const customThemes = {
  redrivaLight: {
    dark: false,
    colors: {
      primary: '#1976D2',
      secondary: '#424242',
      success: '#4CAF50',
      warning: '#FF9800',
      error: '#FF5252',
      info: '#2196F3',
      surface: '#FFFFFF',
      background: '#F5F5F5'
    }
  },
  redrivaDark: {
    dark: true,
    colors: {
      primary: '#2196F3',
      secondary: '#616161',
      success: '#4CAF50',
      warning: '#FF9800',
      error: '#FF5252',
      info: '#2196F3',
      surface: '#121212',
      background: '#0D1117'
    }
  }
}

export default createVuetify({
  theme: {
    defaultTheme: 'redrivaLight',
    themes: customThemes
  },
  defaults: {
    VCard: { elevation: 2, rounded: 'lg' },
    VBtn: { rounded: 'lg', elevation: 1 },
    VChip: { rounded: 'lg' }
  }
})
```

#### 3. Composant ThemeSwitcher Moderne

```vue
<!-- components/ThemeSwitcher.vue -->
<template>
  <v-menu offset-y>
    <template #activator="{ props }">
      <v-btn v-bind="props" icon variant="text" size="large">
        <v-icon>{{ themeIcon }}</v-icon>
      </v-btn>
    </template>

    <v-card min-width="280" elevation="8">
      <v-card-title class="pa-4">
        <v-icon start>mdi-palette</v-icon>
        Apparence
      </v-card-title>
      <v-divider />
      <v-list density="comfortable">
        <v-list-item
          v-for="theme in availableThemes"
          :key="theme.value"
          :active="currentTheme === theme.value"
          @click="setTheme(theme.value)"
        >
          <template #prepend>
            <v-avatar :color="theme.primaryColor" size="24" class="mr-3">
              <v-icon color="white" size="small">{{ theme.icon }}</v-icon>
            </v-avatar>
          </template>
          <v-list-item-title>{{ theme.name }}</v-list-item-title>
          <v-list-item-subtitle>{{ theme.description }}</v-list-item-subtitle>
          <template #append>
            <v-icon v-if="currentTheme === theme.value" color="success">
              mdi-check
            </v-icon>
          </template>
        </v-list-item>
      </v-list>
    </v-card>
  </v-menu>
</template>
```

#### 4. Classes d'Espacement et Positionnement

```vue
<!-- Système d'espacement Vuetify (remplace margin/padding CSS) -->
<div class="ma-4">        <!-- margin: 16px (all) -->
<div class="pa-6">        <!-- padding: 24px (all) -->
<div class="mx-2 my-3">   <!-- margin-x: 8px, margin-y: 12px -->
<div class="pt-4 pb-2">   <!-- padding-top: 16px, padding-bottom: 8px -->

<!-- Flexbox et Grid Vuetify -->
<div class="d-flex justify-space-between align-center">
<div class="d-flex flex-column gap-4">
<div class="text-center">
<div class="w-100 h-100">

<!-- Responsive -->
<v-col cols="12" sm="6" md="4" lg="3">
<div class="d-none d-sm-flex">     <!-- Hidden on mobile -->
<div class="d-flex d-md-none">     <!-- Hidden on desktop -->
```

#### 5. Composants Modernes à Privilégier

```vue
<!-- ✅ Boutons d'Action Modernes -->
<v-btn-group variant="outlined" divided density="comfortable">
  <v-btn color="primary" prepend-icon="mdi-open-in-new">Ouvrir</v-btn>
  <v-btn color="warning" prepend-icon="mdi-restart">Redémarrer</v-btn>
</v-btn-group>

<!-- ✅ FAB (Floating Action Button) -->
<v-btn 
  icon="mdi-plus" 
  color="primary" 
  elevation="6"
  size="large"
  class="fab-fixed"
/>

<!-- ✅ Indicateurs de Statut -->
<v-chip 
  :color="statusColor" 
  variant="tonal" 
  prepend-icon="mdi-circle"
  size="small"
>
  {{ statusText }}
</v-chip>

<!-- ✅ Cartes avec Actions -->
<v-card elevation="3" class="rounded-lg">
  <v-card-title class="d-flex justify-space-between align-center">
    <span>Titre</span>
    <v-menu>
      <template #activator="{ props }">
        <v-btn v-bind="props" icon="mdi-dots-vertical" variant="text" />
      </template>
      <v-list>
        <v-list-item @click="action1">Action 1</v-list-item>
        <v-list-item @click="action2">Action 2</v-list-item>
      </v-list>
    </v-menu>
  </v-card-title>
</v-card>

<!-- ✅ Formulaires avec Validation -->
<v-form ref="form" v-model="valid">
  <v-text-field
    v-model="name"
    label="Nom"
    :rules="nameRules"
    variant="outlined"
    density="comfortable"
  />
  <v-btn 
    :disabled="!valid" 
    color="primary" 
    @click="submit"
  >
    Valider
  </v-btn>
</v-form>
```

#### 6. Variables de Thème et Couleurs

```vue
<!-- Utilisation des variables de thème Vuetify -->
<template>
  <div 
    class="bg-primary text-on-primary pa-4"
    style="background: rgb(var(--v-theme-surface-variant))"
  >
    <!-- Contenu avec couleurs de thème -->
  </div>
</template>

<!-- Classes de couleur Vuetify -->
<div class="text-primary bg-surface">
<div class="text-success bg-success-lighten-4">
<div class="text-error bg-error-darken-2">
```

#### 7. Animations et Transitions Vuetify

```vue
<!-- ✅ Transitions natives Vuetify -->
<v-expand-transition>
  <div v-show="show">Contenu qui s'expanse</div>
</v-expand-transition>

<v-fade-transition>
  <div v-show="show">Contenu qui apparaît en fade</div>
</v-fade-transition>

<v-scale-transition>
  <div v-show="show">Contenu avec effet d'échelle</div>
</v-scale-transition>

<!-- ✅ Hover effects avec classes -->
<v-card 
  class="elevation-hover"
  style="transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1)"
  @mouseenter="elevation = 8"
  @mouseleave="elevation = 2"
>
```

#### ⚠️ Interdictions Absolues

```vue
<!-- ❌ NE JAMAIS FAIRE -->
<style scoped>
.custom-button {
  background: #1976D2;
  padding: 12px 24px;
  border-radius: 8px;
}
</style>

<!-- ❌ NE JAMAIS FAIRE -->
<div style="margin: 16px; padding: 24px;">

<!-- ❌ NE JAMAIS FAIRE -->
<div class="custom-grid">
  <!-- Layout custom au lieu de v-row/v-col -->
</div>
```

#### ✅ Remplacement Vuetify Correct

```vue
<!-- ✅ TOUJOURS FAIRE -->
<v-btn 
  color="primary" 
  class="px-6 py-3 rounded-lg"
  elevation="2"
>
  Bouton Moderne
</v-btn>

<!-- ✅ TOUJOURS FAIRE -->
<div class="ma-4 pa-6">

<!-- ✅ TOUJOURS FAIRE -->
<v-row>
  <v-col cols="12" sm="6" md="4">
    <!-- Layout responsive Vuetify -->
  </v-col>
</v-row>
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
- **Écrire du CSS custom** (utiliser UNIQUEMENT les classes Vuetify natives)
- **Utiliser des styles inline** (`style="margin: 16px"` → `class="ma-4"`)
- Utiliser Skeleton UI ou Tailwind CSS (utiliser UNIQUEMENT Vuetify)
- **Créer des composants stylés manuellement** (utiliser les composants Vuetify natifs)
- **Ignorer le système de thème Vuetify** (utiliser les variables de thème)
- Mélanger les approches state management (utiliser UNIQUEMENT les composables Vue)
- Créer des endpoints qui retournent du HTML (API doit être JSON pur)
- Modifier les fichiers de configuration production sans tester
- Créer des Dockerfiles multiples par service (un seul Dockerfile unifié)
- Utiliser les commandes Docker Compose complexes quand les scripts simplifiés existent
- Ignorer les scripts `dev.sh` et `deploy.sh` au profit de commandes manuelles

### ✅ Toujours faire :
- Utiliser Docker pour toutes les opérations
- **Utiliser EXCLUSIVEMENT les classes utilitaires Vuetify** (`ma-4`, `pa-6`, `d-flex`, etc.)
- **Privilégier les composants Vuetify natifs** (`v-btn-group`, `v-chip`, `v-menu`, etc.)
- **Respecter le système de thème Vuetify** (couleurs, élévations, bordures)
- **Utiliser les transitions Vuetify natives** (`v-fade-transition`, `v-scale-transition`)
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
./scripts/dev.sh start            # Démarrer l'environnement
./scripts/dev.sh stop             # Arrêter l'environnement
./scripts/dev.sh restart          # Redémarrer l'environnement
./scripts/dev.sh rebuild          # Reconstruire les images et redémarrer
./scripts/dev.sh clear-cache      # Effacer le cache Docker (backend)
./scripts/dev.sh clear-cache all  # Effacer le cache de tous les services
./scripts/dev.sh status           # Voir l'état des services
./scripts/dev.sh logs             # Afficher tous les logs
./scripts/dev.sh logs backend     # Logs du backend uniquement
./scripts/dev.sh logs frontend    # Logs du frontend uniquement
./scripts/dev.sh shell            # Shell dans le backend
./scripts/dev.sh shell frontend   # Shell dans le frontend
./scripts/dev.sh monitor          # Monitoring en temps réel
./scripts/dev.sh test             # Lancer tous les tests
./scripts/dev.sh lint             # Vérifier la qualité du code
./scripts/dev.sh db:reset         # Remettre à zéro la base de données
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
2. **Utiliser UNIQUEMENT les ressources natives Vuetify** (classes, composants, thèmes)
3. **INTERDIRE ABSOLUMENT le CSS custom** - Remplacer par les classes Vuetify
4. **Maintenir la compatibilité Docker** pour tous les changements
5. **Privilégier les scripts simplifiés** (`./scripts/dev.sh`, `./scripts/deploy.sh`)
6. **Utiliser le système de thèmes Vuetify** pour la personnalisation
7. **Tester immédiatement** toute modification proposée
8. **Documenter** les changements importants
9. **Préparer le terrain** pour les images Docker de production optimisées

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
