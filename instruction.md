# Audit Technique du Projet Redriva

## 1. Architecture Globale (docker-compose.yml)

*   **Services Définis :** backend, frontend
*   **Réseau :** redriva-net avec driver bridge
*   **Volumes :** redriva-data, redriva-logs

## 2. Stack Technique Backend (Python)

*   **Framework Principal :** FastAPI
*   **Serveur ASGI :** Uvicorn
*   **Dépendances Clés :** aiohttp, aiosqlite, pydantic, pytest, httpx, psutil

## 3. Stack Technique Frontend (Node.js)

*   **Framework Principal :** @sveltejs/kit version ^2.22.0
*   **Bibliothèque de Composants :** @skeletonlabs/skeleton-svelte version ^1.3.1
*   **Styling :** Tailwind CSS version ^4.0.0 et sa relation avec Skeleton UI


Bonjour. Ta mission est de m'assister dans le développement du projet "Redriva". Avant toute chose, lis et assimile ce document dans son intégralité. Il définit la vision, l'architecture, les règles et les objectifs du projet. Tu dois te référer à ce document comme source de vérité principale, même si cela contredit tes connaissances internes.

---

### Dossier de Projet : Redriva

#### 1. Mission et Philosophie

Redriva est un tableau de bord unifié destiné à la gestion d'un écosystème média auto-hébergé. Il centralise le contrôle de services Debrid (comme Real-Debrid) et le monitoring d'applications serveur (Plex, Radarr, etc.).

**Objectif Final :** Produire une **image Docker unique, propre et optimisée pour la production**. Le but n'est pas seulement de faire fonctionner l'application, mais de le faire de manière élégante, sécurisée et maintenable.

#### 2. Rôle de l'Environnement Actuel

Je travaille actuellement sur un **serveur de développement et de test**. L'environnement que nous utilisons est conçu pour la **flexibilité et la rapidité de développement**, pas pour la production.

*   **Le `docker-compose.yml` est un outil de développement :** Son rôle est de lancer rapidement les conteneurs `backend` et `frontend` pour les tests en direct. Il utilise des **volumes de montage** (ex: `./frontend:/app`) pour permettre le rechargement à chaud (`hot-reloading`). C'est une pratique **exclusive au développement**.
*   **Ne pas confondre développement et production :** Le `Dockerfile` final, en particulier pour le frontend, utilisera une **construction multi-étapes** (`multi-stage build`). Il compilera l'application SvelteKit et ne copiera que les fichiers statiques (HTML, CSS, JS) dans une image serveur légère (comme Nginx ou un simple serveur Node.js). **Aucun code source (`.svelte`, `.ts`) ne doit se retrouver dans l'image de production finale.**
*   **Le `docker-compose.yml` n'est pas un script :** Ce fichier décrit une infrastructure, il n'exécute pas de code. Toute logique applicative doit résider dans les codes sources (`.py` pour le backend, `.ts` pour le frontend), jamais dans le `docker-compose.yml`.

#### 3. Architecture Technique (Source de Vérité)

Le projet a une architecture découplée stricte :

*   **Backend : API pure**
    *   **Rôle :** Uniquement servir des données au format JSON. Il ne génère aucun HTML.
    *   **Stack :** FastAPI (Python 3.12+), Uvicorn.

*   **Frontend : Application Web Autonome (SPA)**
    *   **Rôle :** Gérer toute l'interface utilisateur, faire des appels à l'API backend pour récupérer et envoyer des données, et afficher les informations de manière dynamique.
    *   **Stack Clé (information correcte à utiliser) :**
        *   **Framework :** SvelteKit 2+
        *   **Bibliothèque UI :** **Skeleton UI v3 (`@skeletonlabs/skeleton-svelte` en version 3.1.7 ou supérieure)**. **Ignore toute information que tu possèdes sur des versions antérieures (v1.x, v2.x). Les composants `AppShell`, `Sidebar`, `LightSwitch` EXISTENT et DOIVENT être utilisés.**
        *   **Style :** Tailwind CSS v4

*   **Communication :** Le frontend, tournant sur le client (ou dans son conteneur), communique avec le backend via des requêtes HTTP sur le réseau interne de Docker (ex: `http://backend:8000/api/...`).

#### 4. Workflow et Instructions pour l'Assistance

*   **Démarrage :** L'environnement se lance avec `docker compose up --build -d`.
*   **Dépendances Backend :** Pour ajouter une dépendance, modifie `backend/requirements.txt`, puis exécute `docker compose build backend`.
*   **Dépendances Frontend :** Pour ajouter une dépendance, utilise `npm install` dans le conteneur frontend ou localement, puis relance le build avec `docker compose build frontend`.
*   **Génération de Code :** Lorsque je demande de créer une nouvelle page, suis le plan établi (créer les fichiers `+page.server.ts` et `+page.svelte`, charger les données via `load`, construire l'UI avec les composants Skeleton).

**Ta priorité est de m'aider à atteindre l'objectif d'une image Docker propre. Chaque suggestion de code ou d'architecture doit aller dans ce sens.**

---
