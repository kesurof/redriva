FROM node:20-alpine AS build
WORKDIR /app

# Copie des fichiers nécessaires
COPY package.json ./
COPY src ./src
COPY svelte.config.js ./
COPY vite.config.js ./
COPY tailwind.config.cjs ./

# Ajout automatique de l'adapter-static si absent
ENV PATH="./node_modules/.bin:$PATH"
RUN npm install && npm install @sveltejs/adapter-static --save-dev
RUN npx vite --version
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/build ./build
RUN npm install -g serve
EXPOSE 5173
CMD ["serve", "-s", "build", "-l", "5173"]