# Dockerfile pour le développement du frontend SvelteKit
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-alpine

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier le code source
COPY . .

# Exposer le port
EXPOSE 5173

# Variables d'environnement
ENV NODE_ENV=development

# Commande pour démarrer en mode développement
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
