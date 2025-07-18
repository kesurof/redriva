
# Étape de build
FROM node:18-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* ./
COPY src ./src
COPY tailwind.config.cjs ./
RUN npm install && npm run build

# Étape de déploiement
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/build ./build
RUN npm install -g serve
EXPOSE 5173
CMD ["serve", "-s", "build", "-l", "5173"]
