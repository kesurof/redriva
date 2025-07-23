# Dockerfile unifié pour Redriva Backend
# Compatible développement ET production via docker-compose

FROM python:3.12-slim

# Variables d'environnement optimisées
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

# Créer un utilisateur non-root pour la sécurité
RUN groupadd -r redriva && useradd -r -g redriva redriva

# Installer les dépendances système essentielles
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Répertoire de travail
WORKDIR /app

# Copier le fichier des dépendances
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copier le code source
COPY . .

# Créer les répertoires nécessaires et définir les permissions
RUN mkdir -p /app/data /app/logs \
    && chown -R redriva:redriva /app

# Exposer le port
EXPOSE 8000

# Basculer vers l'utilisateur non-root
USER redriva

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/api/ping || exit 1

# Commande par défaut (peut être surchargée par docker-compose)
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
