# Guide d’installation Redriva

## Prérequis
- Docker et Docker Compose (recommandé)
- (Optionnel) Python 3.10+, Node.js 18+, pip, venv, git (pour installation manuelle)

## Installation rapide (Docker Compose recommandé)

```bash
git clone <repo>
cd redriva
cp config/.env.example config/.env  # puis renseignez votre token RD
docker compose up -d
```

Accédez à l’interface web sur [http://localhost:5173](http://localhost:5173)
L’API backend est disponible sur [http://localhost:8000](http://localhost:8000)

## Installation manuelle (optionnelle, pour dev avancé)

```bash
git clone <repo>
cd redriva
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd frontend
npm install && npm run build
```

### Lancement du backend
```bash
uvicorn backend.app:app --reload
```

### Lancement du frontend
```bash
cd frontend
npx serve -l 5173 build
```

## Tests
```bash
pytest tests/
# ou npm run test dans frontend/
```

## Debug & support
- Consultez les logs dans `logs/` ou avec `docker compose logs`
- Voir la FAQ et le troubleshooting dans `docs/`

---
Pour le déploiement cloud, la maintenance et la sécurité, voir `docs/DEPLOIEMENT.md` et le README.
