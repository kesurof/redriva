# Guide d’installation Redriva

## Prérequis
- Python 3.10+
- Node.js (si frontend Next.js/SvelteKit)
- pip, venv, git

## Installation

```bash
git clone <repo>
cd redriva
python3 -m venv venv
source /home/${USER}/scripts/rdm/redriva/venv/bin/activate
pip install fastapi uvicorn requests
# Pour le frontend : npm install (dans src/)
```

## Lancement du backend

```bash
uvicorn backend.app:app --reload
```

## Lancement du frontend

```bash
cd src/
npm run dev
```

## Tests

```bash
pytest tests/
```
