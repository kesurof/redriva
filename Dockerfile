# Dockerfile pour déploiement autonome Redriva (backend + frontend)

FROM python:3.10-slim

# Backend
WORKDIR /app
COPY backend/ backend/
COPY config/ config/
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Frontend (SvelteKit build)
COPY frontend/ frontend/
WORKDIR /app/frontend
RUN apt-get update && apt-get install -y nodejs npm && npm install && npm run build

# Retour au backend pour lancement
WORKDIR /app
EXPOSE 8000
CMD ["python3", "backend/app.py"]
