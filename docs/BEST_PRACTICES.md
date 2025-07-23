# Guide des Bonnes Pratiques - Redriva

## 🎯 Méthodologie de Développement

Ce document compile les bonnes pratiques observées et recommandées pour le développement sur Redriva.

---

## 🚀 Workflow de Développement

### 1. Démarrage d'une Session

```bash
# Vérification de l'état du projet
docker compose ps
docker compose logs --tail=50

# Démarrage/redémarrage propre
docker compose up --build -d

# Vérification santé
curl http://localhost:5174  # Frontend
curl http://localhost:8080/api/ping  # Backend
```

### 2. Développement Incrémental

**✅ Approche recommandée :**
1. **Une fonctionnalité à la fois** - Éviter les changements massifs
2. **Tests immédiatement** - Valider chaque étape
3. **Documentation au fur et à mesure** - Ne pas reporter
4. **Commit fréquents** - Granularité fine

**❌ Anti-patterns à éviter :**
- Modifications simultanées frontend + backend + infrastructure
- Tests reportés à la fin
- Documentation "je ferai plus tard"
- Gros commits monolithiques

### 3. Gestion des Erreurs

**Process de debugging :**
```bash
# 1. Identifier la couche (frontend/backend/infra)
docker compose logs frontend | tail -20
docker compose logs backend | tail -20

# 2. Isoler le problème
docker compose exec frontend npm run test
docker compose exec backend pytest

# 3. Fix itératif + validation
# Changement minimal → Test → Validation → Commit
```

---

## 🧪 Tests et Validation

### Frontend Vue.js

```bash
# Tests unitaires (composables)
docker compose exec frontend npm run test -- composables

# Tests complets avec watch
docker compose exec frontend npm run test:watch

# Interface web des tests
docker compose exec frontend npm run test:ui
```

**Pattern de test recommandé :**
```typescript
describe('useFeature', () => {
  beforeEach(() => {
    // Reset de l'état global
  })
  
  it('should handle basic case', () => {
    // Test du cas nominal
  })
  
  it('should handle error case', () => {
    // Test des cas d'erreur
  })
})
```

### Backend FastAPI

```python
# Tests API
docker compose exec backend pytest tests/

# Tests avec coverage
docker compose exec backend pytest --cov=app tests/
```

---

## 📦 Gestion des Dépendances

### Procédure Stricte (Docker First)

**Frontend :**
```bash
# ✅ BON : Via Docker
docker compose exec frontend npm install package-name
docker compose build frontend

# ❌ INTERDIT : Direct sur l'hôte
cd frontend && npm install  # NON !
```

**Backend :**
```bash
# ✅ BON : Modification + rebuild
echo "nouvelle-dependance==1.0.0" >> backend/requirements.txt
docker compose build backend

# ❌ INTERDIT : pip install direct
pip install nouvelle-dependance  # NON !
```

### Reset Complet (En cas de problème)

```bash
# Procédure de reset total
docker compose down --rmi all
rm -rf frontend/node_modules frontend/package-lock.json
docker compose up --build -d
```

---

## 🎨 Standards de Code

### TypeScript (Frontend)

```typescript
// ✅ BON : Types stricts
interface UserData {
  id: number
  name: string
  email?: string
}

const processUser = (user: UserData): string => {
  return user.name.toUpperCase()
}

// ❌ INTERDIT : Types lâches
const processUser = (user: any) => {  // NON !
  return user.name.toUpperCase()
}
```

### Python (Backend)

```python
# ✅ BON : Types + validation
from pydantic import BaseModel
from typing import Optional

class UserCreate(BaseModel):
    name: str
    email: Optional[str] = None

@app.post("/users", response_model=UserResponse)
async def create_user(user: UserCreate):
    # Logique validée par Pydantic
    pass

# ❌ INTERDIT : Pas de validation
@app.post("/users")
async def create_user(request):  # NON !
    data = await request.json()  # Dangereux
```

---

## 🔄 Migrations et Évolutions

### Migrations Database

```sql
-- migrations/002_add_feature.sql
-- Description: Ajout fonctionnalité X
-- Date: 2025-07-23

ALTER TABLE torrents ADD COLUMN status TEXT DEFAULT 'pending';
CREATE INDEX idx_torrents_status ON torrents(status);
```

### Évolutions Frontend

```typescript
// Backward compatibility
interface AppState {
  // Anciens champs (conservés)
  isLoading: boolean
  error: string | null
  
  // Nouveaux champs (optionnels)
  feature?: NewFeatureState
}
```

### Évolutions API

```python
# Versioning des endpoints
@app.get("/api/v1/torrents")  # Ancienne version
@app.get("/api/v2/torrents")  # Nouvelle version

# Ou paramètres optionnels
@app.get("/api/torrents")
async def get_torrents(
    include_metadata: bool = False  # Nouveau paramètre
):
    pass
```

---

## 🔒 Sécurité et Secrets

### Gestion des Variables d'Environnement

```bash
# ✅ BON : Fichiers .env
# .env (jamais commité)
REAL_DEBRID_TOKEN=secret_token
DATABASE_URL=sqlite:///data/prod.db

# .env.example (commité)
REAL_DEBRID_TOKEN=your_token_here
DATABASE_URL=sqlite:///data/redriva.db
```

### Validation côté Backend

```python
# ✅ BON : Validation stricte
@app.post("/api/torrents")
async def add_torrent(
    torrent: TorrentCreate,
    user: User = Depends(get_current_user)  # Auth required
):
    # Validation métier
    if not torrent.magnet_link.startswith('magnet:'):
        raise HTTPException(400, "Invalid magnet link")
```

---

## 📊 Monitoring et Observabilité

### Logs Structurés

```python
# Backend
import structlog
logger = structlog.get_logger()

logger.info("Torrent added", 
    torrent_id=torrent.id,
    user_id=user.id,
    size_bytes=torrent.size
)
```

```typescript
// Frontend
console.info('API Call', {
  endpoint: '/api/torrents',
  method: 'GET',
  timestamp: new Date().toISOString()
})
```

### Métriques

```python
# Compteurs Prometheus
from prometheus_client import Counter, Histogram

api_calls = Counter('api_calls_total', 'Total API calls', ['endpoint'])
request_duration = Histogram('request_duration_seconds', 'Request duration')

@api_calls.labels(endpoint='/torrents').inc()
```

---

## 🎯 Checklist Qualité

### Avant Chaque Commit

- [ ] Tests unitaires passent
- [ ] Pas d'erreurs TypeScript/Linter
- [ ] Logs propres (pas de console.error non gérées)
- [ ] Variables d'environnement documentées
- [ ] Types à jour

### Avant Chaque Release

- [ ] Tests E2E complets
- [ ] Build production réussit
- [ ] Documentation mise à jour
- [ ] Migration testée
- [ ] Performance validée

### Code Review (Auto-évaluation)

- [ ] Code lisible et auto-documenté
- [ ] Gestion d'erreurs complète
- [ ] Sécurité validée (pas de secrets exposés)
- [ ] Backward compatibility respectée
- [ ] Architecture cohérente

---

## 🚨 Situations de Crise

### Build Cassé

```bash
# 1. Identifier la couche
docker compose build frontend 2>&1 | grep ERROR
docker compose build backend 2>&1 | grep ERROR

# 2. Rollback possible
git log --oneline -5
git checkout HEAD~1  # Dernier commit fonctionnel

# 3. Fix minimal
# Changement le plus petit possible
# Test immédiat
```

### Dépendances Conflictuelles

```bash
# Frontend
rm -rf frontend/node_modules frontend/package-lock.json
docker compose build frontend

# Backend  
docker compose down
docker image rm redriva-backend
docker compose build backend
```

### Données Corrompues

```bash
# Backup automatique
cp data/redriva.db data/redriva.db.backup.$(date +%Y%m%d_%H%M%S)

# Reset propre
docker compose down
rm -rf data/
docker compose up -d
```

---

## 💡 Astuces Productivité

### Aliases Docker

```bash
# ~/.bashrc ou ~/.zshrc
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcb='docker compose build'
alias dce='docker compose exec'
```

### Scripts Utiles

```bash
# scripts/dev.sh
#!/bin/bash
echo "🚀 Starting Redriva development environment..."
docker compose up --build -d
echo "✅ Frontend: http://localhost:5174"
echo "✅ Backend: http://localhost:8080/api"
echo "✅ API Docs: http://localhost:8080/docs"
```

### VSCode Configuration

```json
// .vscode/settings.json
{
  "typescript.preferences.importModuleSpecifier": "relative",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```

---

## 📈 Métriques de Réussite

### Indicateurs Techniques

- **Build Success Rate** : > 95%
- **Test Coverage** : > 80% (frontend), > 90% (backend)
- **TypeScript Strict** : 0 erreurs
- **Security Audit** : 0 vulnérabilités critiques

### Indicateurs Qualité

- **Hot Reload** : < 3 secondes
- **Build Production** : < 2 minutes
- **API Response Time** : < 200ms (P95)
- **Bundle Size** : < 1MB gzippé

### Indicateurs Processus

- **Commit Frequency** : Multiple par jour
- **Test Execution** : Avant chaque commit
- **Documentation** : À jour en temps réel
- **Code Review** : 100% auto-évaluation

---

*Guide maintenu par l'équipe Redriva*  
*Dernière mise à jour : 23 juillet 2025*
