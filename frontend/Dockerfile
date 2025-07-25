# Multi-stage build pour SvelteKit
FROM node:20-alpine AS base

WORKDIR /app

# Copier les fichiers de configuration
COPY package*.json ./
COPY svelte.config.js ./
COPY vite.config.ts ./
COPY tsconfig.json ./

# Installer les dépendances (utiliser install car pas de package-lock.json en développement)
RUN npm install

# Stage de développement
FROM base AS development

# Copier tout le code source
COPY . .

# Exposer le port de développement
EXPOSE 5174

# Commande par défaut pour le développement
CMD ["npm", "run", "dev"]

# Stage de build pour production
FROM base AS build

# Copier le code source
COPY . .

# Construire l'application
RUN npm run build

# Production stage avec nginx
FROM nginx:alpine AS production

# Copier les fichiers construits
COPY --from=build /app/build /usr/share/nginx/html

# Copier la configuration nginx personnalisée
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Variables d'environnement pour nginx
ENV NGINX_HOST=localhost
ENV NGINX_PORT=80

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
