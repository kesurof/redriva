# Instructions AI de Développement - Redriva

## 📋 Vue d'ensemble pour l'Assistant IA

Ce document contient les instructions essentielles pour un assistant IA travaillant sur le projet **Redriva**. Il documente la philosophie, l'architecture, les règles et les méthodes de développement à respecter absolument.

**🎯 Mission principale :** Assister le développement de Redriva en respectant sa philosophie "Zéro Réécriture de Code" et son architecture découplée stricte.

---

## 🏗️ Architecture et Principes Fondamentaux

### Philosophie "Zéro Réécriture de Code"

**RÈGLE ABSOLUE :** Le code applicatif (Python, Vue.js) est identique pour le développement et la production. Seul l'emballage (Dockerfile) change.

```
Analogie du moteur :
- Code applicatif = Moteur (écrit une seule fois)
- Développement = Châssis de test (volumes Docker + hot reload) 
- Production = Carrosserie optimisée (build multi-stage)
```

### Stack Technique (Source de Vérité)

```
Frontend: Vue.js 3 + Vuetify + TypeScript
├── Framework: Vue.js 3 avec Composition API
├── UI Library: Vuetify v3 (Material Design)
├── Styling: Intégré dans Vuetify (pas de Tailwind)
├── Router: Vue Router v4
├── State: Composables Vue (pas de Pinia/Vuex)
├── Tests: Vitest + Vue Test Utils
└── Build: Vite + TypeScript strict

Backend: FastAPI + Python 3.12
├── API: FastAPI pure (JSON uniquement, pas de HTML)
├── Database: SQLite + Migrations SQL  
├── Queue: Redis + ARQ pour jobs asynchrones
├── Monitoring: Prometheus metrics intégrées
├── Auth: Real-Debrid OAuth sécurisé
└── Logging: Structlog pour observabilité
```

### Communication Frontend ↔ Backend

```
Frontend (Conteneur) → API HTTP → Backend (Conteneur)
Exemple: http://backend:8000/api/...
```

---

## 🛠️ Méthodologie de Développement

### Workflow Docker (OBLIGATOIRE)

```bash
# Démarrage environnement
docker compose up --build -d

# Gestion dépendances Backend
1. Éditer backend/requirements.txt
2. docker compose build backend

# Gestion dépendances Frontend  
1. docker compose exec frontend npm install <paquet>
2. docker compose build frontend
```

### Structure des Dossiers (À RESPECTER)

```
redriva/
├── frontend/                 # Vue.js 3 + Vuetify
│   ├── src/
│   │   ├── components/       # Composants réutilisables
│   │   ├── views/           # Pages principales  
│   │   ├── composables/     # Stores Vue (state management)
│   │   ├── router/          # Vue Router config
│   │   ├── plugins/         # Vuetify + thèmes
│   │   └── test/           # Tests Vitest
│   ├── Dockerfile           # Dev (volumes)
│   └── Dockerfile.prod      # Production (multi-stage)
├── backend/                 # FastAPI
│   ├── app.py              # Point d'entrée
│   ├── services/           # Logique métier
│   ├── database/           # Persistance + migrations
│   └── requirements.txt    # Dépendances Python
├── proxy/                  # Nginx reverse proxy
├── docs/                   # Documentation
└── docker-compose.yml      # Environnement principal
```

---

## 🎨 Standards de Code

### Frontend Vue.js 3

**Composables (State Management) :**
```typescript
// ✅ BON : Composition API + réactivité
export function useAppStore() {
  const state = reactive<AppState>({
    isLoading: false,
    error: null
  })
  
  const setLoading = (loading: boolean) => {
    state.isLoading = loading
  }
  
  return { 
    // État réactif
    ...toRefs(state),
    // Actions
    setLoading
  }
}
```

**Composants Vue.js :**
```vue
<!-- ✅ BON : Composition API + TypeScript -->
<template>
  <v-card>
    <v-card-title>{{ title }}</v-card-title>
    <v-card-text>{{ content }}</v-card-text>
  </v-card>
</template>

<script setup lang="ts">
interface Props {
  title: string
  content: string
}

const props = defineProps<Props>()
</script>
```

**Thèmes Vuetify :**
```typescript
// ✅ BON : Système de thèmes avancé
const themes = {
  skeleton: {
    dark: false,
    colors: {
      primary: '#0FBA81',
      secondary: '#4F46E5'
    }
  },
  wintry: {
    dark: false, 
    colors: {
      primary: '#0369A1',
      secondary: '#7C2D92'
    }
  }
}
```

### Backend FastAPI

**Structure des endpoints :**
```python
# ✅ BON : API pure, pas de HTML
@app.get("/api/torrents", response_model=List[TorrentResponse])
async def get_torrents():
    return await torrent_service.get_all()

# ❌ INTERDIT : Retourner du HTML
@app.get("/page")
async def get_page():
    return HTMLResponse("<html>...")  # NON !
```

**Gestion d'erreurs :**
```python
# ✅ BON : Exceptions structurées
from fastapi import HTTPException

if not torrent:
    raise HTTPException(
        status_code=404, 
        detail="Torrent not found"
    )
```

---

## 📝 Génération de Code

### Plan Standard pour Nouvelles Pages

```
1. Backend (si nécessaire) :
   - Endpoint API dans app.py
   - Service métier dans services/
   - Tests unitaires

2. Frontend Vue.js :
   - Composable pour state (composables/)
   - Vue principale (views/)  
   - Composants si nécessaire (components/)
   - Tests Vitest (test/)

3. Intégration :
   - Route Vue Router
   - Navigation mise à jour
   - Tests E2E si critique
```

### Composants Vuetify Standards

```typescript
// StatCard : Statistiques
interface StatCardProps {
  title: string
  value: string | number
  icon?: string
  variant?: 'primary' | 'secondary' | 'success' | 'warning' | 'error'
  trend?: 'up' | 'down' | 'stable'
}

// ServiceCard : État des services
interface ServiceCardProps {
  name: string
  status: 'online' | 'offline' | 'warning'
  url?: string
  version?: string
}

// TorrentCard : Gestion torrents
interface TorrentCardProps {
  torrent: Torrent
  onPause?: () => void
  onResume?: () => void  
  onDelete?: () => void
}
```

---

## 🧪 Tests et Qualité

### Tests Frontend (Vitest)

```typescript
// ✅ BON : Tests composables
import { describe, it, expect, beforeEach } from 'vitest'
import { useAppStore } from '@/composables/useAppStore'

describe('useAppStore', () => {
  it('should initialize with correct state', () => {
    const { isLoading, error } = useAppStore()
    
    expect(isLoading.value).toBe(false)
    expect(error.value).toBe(null)
  })
})
```

**Commandes de test :**
```bash
# Dans le conteneur frontend
npm run test        # Tests simples
npm run test:watch  # Mode watch
npm run test:ui     # Interface web
```

### Tests Backend (Pytest)

```python
# ✅ BON : Tests API
import pytest
from fastapi.testclient import TestClient

def test_get_torrents(client: TestClient):
    response = client.get("/api/torrents")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
```

---

## 🔒 Sécurité et Authentification

### Real-Debrid (CRITIQUE)

```python
# ✅ BON : Token jamais côté client
# Backend uniquement
REAL_DEBRID_TOKEN = os.getenv("REAL_DEBRID_TOKEN")

# ❌ INTERDIT : Exposer le token
# Jamais dans les réponses API
# Jamais dans le localStorage frontend
```

### Variables d'Environnement

```bash
# .env (backend)
REAL_DEBRID_TOKEN=your_token_here
DATABASE_URL=sqlite:///data/redriva.db
REDIS_URL=redis://redis:6379/0

# Variables frontend (Vite)
VITE_API_URL=http://localhost:8080
```

---

## 🎯 Patterns de Développement

### Gestion d'État Réactive

```typescript
// ✅ BON : Composable avec persistance
export function useThemeStore() {
  const themeName = ref(localStorage.getItem('theme') || 'skeleton')
  const isDark = ref(localStorage.getItem('isDark') === 'true')
  
  // Synchronisation avec Vuetify
  watch([themeName, isDark], () => {
    vuetify.theme.global.name.value = `${themeName.value}${isDark.value ? 'Dark' : 'Light'}`
    localStorage.setItem('theme', themeName.value)
    localStorage.setItem('isDark', isDark.value.toString())
  })
  
  return { themeName, isDark, toggleDark }
}
```

### Appels API (Frontend)

```typescript
// ✅ BON : Fetch avec gestion d'erreurs
export function useApi() {
  const baseURL = import.meta.env.VITE_API_URL
  
  const fetchAPI = async <T>(endpoint: string): Promise<T> => {
    try {
      const response = await fetch(`${baseURL}${endpoint}`)
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      return await response.json()
    } catch (error) {
      console.error('API Error:', error)
      throw error
    }
  }
  
  return { fetchAPI }
}
```

### Notifications (User Feedback)

```typescript
// ✅ BON : Système de notifications
export function useNotificationStore() {
  const notifications = ref<Notification[]>([])
  
  const success = (message: string) => {
    add({ type: 'success', message, duration: 5000 })
  }
  
  const error = (message: string) => {
    add({ type: 'error', message, duration: 8000 })
  }
  
  return { notifications, success, error }
}
```

---

## 📦 Déploiement et Production

### Images Docker Production

```dockerfile
# ✅ BON : Multi-stage build
# Dockerfile.prod (frontend)
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/conf.d/default.conf
EXPOSE 80
```

### Configuration Nginx

```nginx
# ✅ BON : Proxy API préservé
location / {
    try_files $uri $uri/ /index.html;
}

location /api {
    proxy_pass http://backend:8000;
    proxy_set_header Host $host;
}
```

---

## 🚨 Règles Critiques (À NE JAMAIS VIOLER)

### ❌ INTERDICTIONS ABSOLUES

1. **Mélanger les responsabilités :**
   ```typescript
   // ❌ INTERDIT : HTML dans le backend
   // ❌ INTERDIT : Logique métier dans les composants Vue
   ```

2. **Exposer les secrets :**
   ```typescript
   // ❌ INTERDIT : Token Real-Debrid côté client
   localStorage.setItem('rd_token', token) // NON !
   ```

3. **Casser l'isolation Docker :**
   ```bash
   # ❌ INTERDIT : npm install direct sur l'hôte
   cd frontend && npm install  # NON !
   
   # ✅ BON : Via Docker
   docker compose exec frontend npm install
   ```

4. **Ignorer les types TypeScript :**
   ```typescript
   // ❌ INTERDIT : any, ignorer les erreurs
   const data: any = response  // NON !
   
   // ✅ BON : Types stricts
   const data: TorrentResponse = response
   ```

### ✅ OBLIGATIONS

1. **Tests pour chaque composable :**
   ```typescript
   // Obligatoire pour chaque nouveau composable
   describe('useNewFeature', () => {
     it('should work correctly', () => {
       // Tests...
     })
   })
   ```

2. **Documentation des APIs :**
   ```python
   # Obligatoire pour chaque endpoint
   @app.post("/api/endpoint", response_model=ResponseModel)
   async def create_something(data: RequestModel):
       """Description claire de l'endpoint."""
   ```

3. **Gestion d'erreurs systématique :**
   ```typescript
   // Obligatoire dans tous les appels API
   try {
     const result = await api.call()
   } catch (error) {
     notificationStore.error('Erreur détaillée')
   }
   ```

---

## 🔧 Outils et Commandes

### Développement Quotidien

```bash
# Démarrage complet
docker compose up --build -d

# Logs en temps réel
docker compose logs -f frontend
docker compose logs -f backend

# Tests
docker compose exec frontend npm run test
docker compose exec backend pytest

# Reconstruction après changements
docker compose build frontend
docker compose build backend
```

### Debugging

```bash
# Shell dans les conteneurs
docker compose exec frontend sh
docker compose exec backend bash

# Reset complet environnement
docker compose down --rmi all
rm -rf frontend/node_modules
docker compose up --build -d
```

### Production

```bash
# Build et déploiement
docker compose -f docker-compose.prod.yml up --build -d

# Health checks
curl http://localhost:3000/api/ping
curl http://localhost:3000/api/metrics
```

---

## 📚 Ressources et Références

### Documentation Officielle
- [Vue.js 3](https://vuejs.org/guide/)
- [Vuetify 3](https://vuetifyjs.com/en/)
- [FastAPI](https://fastapi.tiangolo.com/)
- [Vitest](https://vitest.dev/)

### Architecture Redriva
- [Architecture complète](ARCHITECTURE.md)
- [Guide d'installation](INSTALL.md)
- [Guide d'utilisation](USAGE.md)

### Patterns et Exemples
```
frontend/src/composables/    # Exemples de composables
frontend/src/components/     # Composants Vuetify
frontend/src/test/          # Tests de référence
backend/services/           # Services backend
```

---

## 🎯 Checklist pour Nouvelles Fonctionnalités

### Avant de Commencer
- [ ] Comprendre le besoin utilisateur
- [ ] Identifier les composants affectés (frontend/backend)
- [ ] Vérifier la cohérence avec l'architecture existante

### Développement Backend
- [ ] Endpoint FastAPI avec types Pydantic
- [ ] Service métier séparé
- [ ] Gestion d'erreurs HTTP appropriée
- [ ] Tests unitaires pour la logique

### Développement Frontend  
- [ ] Composable Vue pour le state management
- [ ] Composants Vuetify réutilisables
- [ ] Types TypeScript stricts
- [ ] Tests Vitest pour la logique

### Intégration
- [ ] Route Vue Router configurée
- [ ] Navigation mise à jour
- [ ] Gestion d'erreurs UI (notifications)
- [ ] Test E2E pour le parcours complet

### Qualité
- [ ] Code review interne
- [ ] Tests automatisés passent
- [ ] Documentation mise à jour
- [ ] Performance validée

---

## 💡 Conseils pour l'Assistant IA

### Approche Méthodologique

1. **Toujours commencer par comprendre** l'existant avant de proposer
2. **Respecter les patterns** établis plutôt que d'inventer
3. **Tester immédiatement** chaque modification
4. **Documenter clairement** les changements complexes

### Communication

1. **Expliquer les choix** techniques et les alternatives
2. **Proposer des solutions complètes** (frontend + backend si nécessaire)
3. **Anticiper les impacts** sur l'écosystème existant
4. **Alerter sur les breaking changes** potentiels

### Debugging

1. **Utiliser les logs Docker** pour diagnostiquer
2. **Vérifier la cohérence** entre les environnements
3. **Tester dans l'ordre** : composables → composants → intégration
4. **Isoler les problèmes** (frontend vs backend vs infrastructure)

---

*Document maintenu par l'équipe Redriva*  
*Version : 2.0 (Vue.js 3)*  
*Dernière mise à jour : 23 juillet 2025*
