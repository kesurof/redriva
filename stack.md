# Résumé technique du projet Redriva

---

## 1. Stack technique complète et versions

| Composant      | Technologie/Librairie         | Version déclarée                |
|----------------|------------------------------|---------------------------------|
| **Frontend**   | SvelteKit                    | 1.29.2 *(package.json)*         |
|                | Svelte                       | 4.2.8 *(package.json)*          |
|                | TailwindCSS                  | 3.4.1 *(package.json)*          |
|                | Node.js                      | 20.11.1 *(Dockerfile)*          |
|                | svelte-i18n                  | 4.4.8 *(package.json)*          |
|                | Vite                         | 5.2.8 *(package.json)*          |
| **Backend**    | Python                       | 3.10.12 *(Dockerfile/venv)*     |
|                | FastAPI                      | 0.110.2 *(requirements.txt)*    |
|                | Uvicorn                      | 0.29.0 *(requirements.txt)*     |
|                | aiosqlite                    | 0.20.0 *(requirements.txt)*     |
|                | aiohttp                      | 3.9.5 *(requirements.txt)*      |
|                | Pydantic                     | 2.7.1 *(requirements.txt)*      |
| **Base de données** | SQLite                   | 3.37+ (via Python stdlib)       |
| **Outils**     | Docker                       | 24.x *(prérequis)*              |
|                | Docker Compose               | 2.x *(prérequis)*               |
|                | pytest                       | 8.2.1 *(requirements.txt)*      |
|                | serve (frontend preview)     | 14.2.0 *(package.json)*         |

*Pour la liste exhaustive, voir `package.json` et `requirements.txt`.*

---

## 2. But principal de l’application

> **Redriva** est une application web permettant de gérer, visualiser et automatiser les torrents et téléchargements d’un compte Real-Debrid via une interface moderne, sécurisée et responsive.

---

## 3. Structure des dossiers principaux

| Dossier        | Rôle                                                                                  |
|----------------|---------------------------------------------------------------------------------------|
| `frontend/`    | Code source SvelteKit (UI, pages, composants, i18n, Tailwind, scripts npm)            |
| `backend/`     | Code source FastAPI (API REST, logique métier, persistance, workers, scripts Python)  |
| `config/`      | Fichiers de configuration (ex : `.env` pour secrets et tokens, non versionné)         |
| `data/`        | Données persistantes (base SQLite, fichiers de travail)                               |
| `logs/`        | Logs applicatifs (backend, worker, erreurs)                                           |
| `docs/`        | Documentation technique, guides d’installation, usage, déploiement, FAQ               |
| `scripts/`     | Scripts utilitaires (maintenance, synchronisation, inventaire)                        |
| `systemd/`     | Fichiers d’unités systemd pour déploiement classique                                  |
| `tests/`       | Tests unitaires et d’intégration (backend, frontend)                                  |

---

## 4. Commandes d’installation et de lancement (développement)

### Méthode recommandée : Docker Compose

```bash
git clone https://github.com/kesurof/redriva.git
cd redriva
cp config/.env.example config/.env   # puis renseignez votre token RD
docker compose up -d
```
- Frontend : http://localhost:5173
- Backend : http://localhost:8000

### Méthode manuelle (développement avancé)

**Backend :**
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn backend.app:app --reload
```

**Frontend :**
```bash
cd frontend
npm install
npm run dev
```
- Frontend : http://localhost:5173

---

## 5. Dépendances en doublon, obsolètes ou inutilisées

- **Aucune dépendance en doublon** repérée dans les fichiers principaux.
- **Pas de dépendance obsolète** majeure détectée (toutes les versions sont récentes).
- **Conseil** : vérifier régulièrement les alertes de sécurité npm/pip et mettre à jour Tailwind/SvelteKit si besoin.

---

**Sources :**  
- `README.md`  
- `docs/INSTALL.md`  
- `frontend/package.json`  
- `requirements.txt`  
- `Dockerfile`  
- `frontend/Dockerfile`  

Pour plus de détails, voir la documentation dans le dossier `docs/`.
