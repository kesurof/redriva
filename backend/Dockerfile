# Utiliser une image Python slim comme base
FROM python:3.10-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Installer les dépendances système
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copier le fichier des dépendances. Le chemin est simple car on est dans le contexte "backend"
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Copier TOUT le code de l'application (app.py, persistence.py, etc.)
# C'est simple : copier tout ce qui est dans le contexte "." vers le WORKDIR "."
COPY . .

# Exposer le port de l'application
EXPOSE 8000

# La commande de démarrage est maintenant dans docker-compose.yml pour plus de flexibilité
