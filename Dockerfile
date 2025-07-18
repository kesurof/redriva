
# Dockerfile pour déploiement autonome Redriva (backend FastAPI + build frontend)
# Utilise Python 3.10 slim, installe les dépendances, expose le port 8000
# Les volumes /config, /logs, /data sont montés pour la persistance
# Le token Real-Debrid N'EST JAMAIS inclus dans l'image, il doit être passé via variable d'environnement ou volume

FROM python:3.10-slim

WORKDIR /app

# Backend
COPY backend/ backend/
COPY config/ config/
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Frontend (SvelteKit build)
COPY frontend/ frontend/
WORKDIR /app/frontend
RUN apt-get update && apt-get install -y nodejs npm && npm install && npm run build

# (Optionnel) Servir le frontend avec un serveur statique (ex: nginx) si besoin
# (À adapter selon la structure finale du frontend)

# Retour au backend pour lancement
WORKDIR /app
EXPOSE 8000

# Lancement FastAPI en production avec Uvicorn
CMD ["python3", "-m", "uvicorn", "backend.app:app", "--host", "0.0.0.0", "--port", "8000", "--log-level", "info"]
