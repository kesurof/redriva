FROM node:20-alpine AS build
WORKDIR /app
COPY package.json ./
COPY src ./src
COPY svelte.config.js ./
COPY vite.config.js ./
COPY tailwind.config.cjs ./
COPY .npmrc ./
ENV PATH="./node_modules/.bin:$PATH"
RUN npm install
RUN npm run build
FROM node:20-alpine
WORKDIR /app
COPY --from=build /app .
ENV NODE_ENV=production
RUN npm install --omit=dev
EXPOSE 4173
CMD ["npm", "run", "preview", "--", "--port", "4173", "--host"]