# Dockerfile pour développement
FROM node:20-alpine

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./
RUN npm install

# Copier le code source
COPY . .

# Exposer le port
EXPOSE 3000

# Variables d'environnement
ENV NODE_ENV=development

# Commande de démarrage
CMD ["npm", "run", "dev"]
