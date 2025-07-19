# Migration vers SvelteKit + FastAPI

## Architecture actuelle

```
redriva/
├── backend/          # FastAPI backend (port 8080 → 8000)
├── frontend/         # SvelteKit frontend (port 5173)
├── config/          # Configuration partagée
├── data/            # Données persistantes
├── logs/            # Logs applicatifs
└── scripts/         # Scripts utilitaires
```

## Services Docker

### Backend (FastAPI)
- **Port**: 8080 → 8000 (mappé)
- **Build**: `./backend/Dockerfile`
- **Volumes**: Code source + data + logs
- **Health check**: `/api/ping`

### Frontend (SvelteKit)
- **Port**: 5173
- **Build**: `./frontend/Dockerfile`
- **Proxy API**: `/api` → `http://backend:8000`
- **Dépendance**: backend

## Démarrage

```bash
# Build des images
./scripts/build.sh

# Démarrage des services
docker-compose up -d

# Logs
docker-compose logs -f frontend
docker-compose logs -f backend
```

## URLs

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **API Docs**: http://localhost:8080/docs

## Configuration

- **Frontend**: `frontend/vite.config.js` (proxy API)
- **Backend**: `backend/src/` (structure existante)
- **Environment**: `config/.env`

## Prochaines étapes

1. [ ] Migrer les pages principales vers SvelteKit
2. [ ] Implémenter les stores Svelte pour la gestion d'état
3. [ ] Créer les composants UI réutilisables
4. [ ] Migrer les fonctionnalités HTMX vers SvelteKit
5. [ ] Tests E2E avec Playwright
