# Dockerfile unifié Frontend - Multi-stage pour dev ET prod
FROM node:20-alpine AS base

# Stage de build (utilisé en production)
FROM base AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production=false --silent
COPY . .
RUN npm run build

# Stage de développement
FROM base AS development
WORKDIR /app
RUN npm install -g npm@latest
COPY package*.json ./
RUN npm ci --only=production=false --silent

# Script d'entrée pour gestion automatique des dépendances
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'if [ ! -d "node_modules" ] || [ ! "$(ls -A node_modules)" ]; then' >> /docker-entrypoint.sh && \
    echo '  echo "Installing dependencies..."' >> /docker-entrypoint.sh && \
    echo '  npm ci --silent' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
    echo 'exec "$@"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

COPY . .
EXPOSE 5174
ENV NODE_ENV=development

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5174"]

# Stage de production avec Nginx
FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html

# Configuration Nginx pour SPA
RUN echo 'server {' > /etc/nginx/conf.d/default.conf && \
    echo '    listen 3000;' >> /etc/nginx/conf.d/default.conf && \
    echo '    server_name localhost;' >> /etc/nginx/conf.d/default.conf && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    index index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    location / {' >> /etc/nginx/conf.d/default.conf && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '    location /api {' >> /etc/nginx/conf.d/default.conf && \
    echo '        proxy_pass http://backend:8000;' >> /etc/nginx/conf.d/default.conf && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/conf.d/default.conf && \
    echo '        proxy_set_header X-Real-IP $remote_addr;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

# Utilisateur non-root pour sécurité
RUN addgroup -g 1001 -S nodejs && \
    adduser -S vue -u 1001 -G nodejs && \
    chown -R vue:nodejs /usr/share/nginx/html

USER vue
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
