# Roadmap de correction globale Redriva (conforme instruction_stack)

## 1. Frontend (SvelteKit, Vite, TailwindCSS)

### 1.1. Scripts et dépendances
- Fixer la version de SvelteKit (`@sveltejs/kit`) et de Vite dans `package.json` pour garantir la compatibilité.
- Mettre à jour le script `"build"` pour utiliser `"vite build"` si la CLI SvelteKit ne fournit plus la commande `build`.
- Ajouter/mettre à jour `"@sveltejs/vite-plugin-svelte"` en version compatible Svelte 5 (ex : `^4.0.0-next.6` si warning).
- Supprimer et régénérer `package-lock.json` après chaque changement de dépendance majeur.

### 1.2. Structure et conventions
- Organiser les composants dans `src/lib/components/` avec sous-dossiers pour les composants complexes.
- Vérifier la présence et la conformité de `src/app.html` (doit contenir `%sveltekit.head%` et `%sveltekit.body%`).
- S’assurer que tous les fichiers Svelte respectent la syntaxe (HTML en dehors des blocs `<script>`).

### 1.3. Accessibilité et i18n
- Utiliser des balises sémantiques et vérifier l’accessibilité (a11y).
- Préparer l’internationalisation avec une librairie adaptée (ex : svelte-i18n).

### 1.4. Tests et CI
- Mettre en place des tests unitaires et E2E (ex : Playwright).
- Ajouter un workflow CI pour lint, build et tests.

---

## 2. Backend (FastAPI, Python 3.10, SQLite)

### 2.1. Structure et dépendances
- Organiser le code en routers, schemas, services.
- Utiliser des modèles Pydantic pour la validation.
- S’assurer que tous les accès à la base SQLite sont asynchrones (`aiosqlite` recommandé).
- Maintenir `requirements.txt` à jour.

### 2.2. Sécurité
- Stocker les tokens et secrets côté serveur, jamais côté client.
- Charger les secrets via variables d’environnement ou fichiers de config non versionnés.
- Ajouter un système de rate limiting et monitoring des accès.

### 2.3. Tests et documentation
- Ajouter des tests unitaires (pytest).
- Documenter l’API avec OpenAPI/Swagger (FastAPI le fait automatiquement).

---

## 3. Docker & DevOps

### 3.1. Dockerfiles
- Utiliser des builds multi-stage pour le frontend et le backend.
- Toujours partir d’une image officielle à jour (`node:20-alpine`, `python:3.10-slim`).
- Exclure `node_modules`, `.venv`, `.git` via `.dockerignore`.
- Exécuter les applications avec un utilisateur non-root.

### 3.2. Docker Compose
- Orchestrer les services frontend et backend.
- Utiliser des volumes pour la persistance (ex : base SQLite).
- Charger les variables d’environnement via `env_file`.

### 3.3. Déploiement
- Prévoir un service systemd utilisateur pour le lancement automatique.
- Documenter le déploiement dans le README.

---

## 4. Organisation & Qualité

### 4.1. Séparation claire
- Garder `frontend` et `backend` totalement séparés.
- Communication uniquement via API REST.

### 4.2. Scripts d’automatisation
- Placer les scripts de maintenance dans `scripts`.
- Ajouter des scripts pour backup, nettoyage, génération de données de test.

### 4.3. Documentation
- Rédiger un README détaillé.
- Documenter chaque endpoint, chaque composant clé, et les procédures d’installation/déploiement.

---

## 5. Points de contrôle spécifiques

- Vérifier la cohérence des versions (SvelteKit, Vite, vite-plugin-svelte, Svelte).
- Vérifier la présence de tous les fichiers critiques (`src/app.html`, `.env`, `requirements.txt`, etc.).
- Vérifier la conformité des Dockerfile (pas d’installation Node via apt, pas de chemins absolus, utilisateur non-root).
- Vérifier la conformité des scripts Python (type hints, logging, gestion des erreurs, asynchrone).
- Vérifier la conformité à l’accessibilité et à l’internationalisation.

---

## 6. Roadmap de correction

1. Corriger les dépendances et scripts du frontend (package.json, app.html, vite-plugin-svelte).
2. Corriger la structure et la sécurité du backend (FastAPI, gestion des tokens, accès DB).
3. Corriger et harmoniser tous les Dockerfile (multi-stage, images officielles, non-root).
4. Mettre en place ou corriger la CI/CD (lint, tests, build).
5. Vérifier la documentation et l’onboarding.
6. Ajouter ou corriger les scripts d’automatisation.
7. Faire une passe finale sur l’accessibilité, l’i18n et la sécurité.

---

Ce plan garantit la robustesse, la maintenabilité et la conformité du projet Redriva avec les standards modernes et les instructions fournies.
