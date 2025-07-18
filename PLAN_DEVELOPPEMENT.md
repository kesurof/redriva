# Plan de développement Redriva

## 1. Sécurité & Backend
- [x] Gestion sécurisée du token Real-Debrid (stockage serveur, variable d’environnement, jamais côté client)
- [x] Ajout d’un système de logs structurés (logs/)
- [x] Rate limiting sur les endpoints sensibles

## 2. API & Fonctionnalités
- [x] Endpoints REST torrents (POST, DELETE, GET)
- [x] Intégration de la récupération réelle des torrents via l’API Real-Debrid
- [x] Gestion des erreurs et réponses normalisées

## 3. Persistance & Données
- [x] Modèle SQLite, migration/init, purge/archivage (évolutif)

## 4. Tests & Qualité
- [x] Tests unitaires pour endpoints et persistance (tests/)
- [x] Linter (flake8) et formatage (black)
- [x] Badge de couverture de tests dans le README

## 5. Documentation & Onboarding
- [x] README, exemples API, captures, installation
- [x] Section troubleshooting et FAQ
- [x] Documentation OpenAPI/Swagger

## 6. Frontend
- [x] SvelteKit avec svelte-i18n et TailwindCSS
- [x] Composants UI réutilisables (table, modal, loader, notifications, toast)
- [x] CRUD torrents complet (affichage, ajout, suppression, détail)
- [x] Pages /downloads, /scraper, /settings (squelettes)
- [x] Dark mode toggle et responsive complet
- [x] Internationalisation complète (toutes chaînes, notifications, erreurs)
- [x] Feedbacks visuels avancés, gestion erreurs, loaders contextuels
- [x] Tests E2E (Playwright) pour les parcours critiques
- [x] Documentation UI : guide de contribution, conventions, exemples d’intégration


## 7. Observabilité & Maintenance (en cours)
- Monitoring (Sentry, logs d’audit)
- Dashboard d’administration comprenant :
  - [x] Statistiques globales (nombre total de torrents, par statut, volume total téléchargé, téléchargements actifs)
  - [x] Graphiques & tendances (évolution du nombre de torrents, répartition des statuts, historique des volumes)
  - [x] Tableau des jobs/torrents récents (statut, progression, taille, date, actions rapides)
  - [x] Alertes & notifications (erreurs récentes, torrents en échec, liens morts, quotas)
  - [x] Recherche & filtres (nom, statut, date, taille, type)
  - [x] Utilisation des quotas (quota RD restant, slots utilisés/disponibles)
  - [x] Logs récents (actions utilisateur, logs système)
  - [x] Actions globales (ajout, rafraîchir, exporter)
  - [x] Informations système (version, état backend/API, dernier backup)
  - [x] Aide & support (FAQ, documentation, support)



## 8. Gestion des priorités & files d’attente (fait)
- [x] Modèle de file d’attente côté backend (table queue : id, torrent_id, priority, status, added_at, updated_at)
- [x] Endpoints API REST pour la file/priorités (GET/POST/PATCH/DELETE /api/queue)
- [x] Logique backend : gestion de l’ordre d’exécution, N téléchargements simultanés, priorités dynamiques (queue_worker.py)
- [x] Frontend : page « File d’attente » (table, ajout, actions ↑↓, suppression, feedbacks visuels)
- [x] Synchronisation automatique (polling)
- [x] Documentation d’usage et cas d’erreur (docs/QUEUE.md)

## 9. Déploiement (à faire)

- [x] Dockerfile complet pour déploiement autonome (backend et frontend)
- [x] Dockerfiles dédiés dans `backend/` et `frontend/`
- [x] Fichier `docker-compose.yml` à la racine
- [x] Fichier `.env` dans `config/` pour le token RD
- [x] Adaptation du frontend : tous les appels API utilisent la fonction `apiUrl` et la variable d’environnement `VITE_API_URL` (`import.meta.env.VITE_API_URL`)
- [x] Documentation procédure de déploiement (Docker, systemd, Docker Compose)
- [x] Démarrage automatisé avec `docker compose up -d`
- [x] Conseils sécurité, persistance, logs, arrêt, reverse proxy, documentation

**Reste à faire :**
- [ ] Monitoring avancé (Sentry, alertes, dashboards temps réel)
- [ ] Déploiement cloud (optionnel)
    - [ ] Ajouter un service reverse proxy (nginx ou caddy) dans `docker-compose.yml` avec configuration adaptée (HTTPS, routage /api)
    - [ ] Créer un dossier `ansible/` avec un playbook pour automatiser l'installation, le déploiement, la gestion des secrets et la configuration du proxy
    - [ ] Mettre en place un pipeline CI/CD (ex : `.github/workflows/deploy.yml`) pour build, test, push et déploiement auto
    - [ ] Documenter la procédure cloud dans `docs/DEPLOIEMENT.md` (prérequis, sécurité, troubleshooting, exemples)
    - [ ] Tester et valider le déploiement sur un cloud cible (VPS, AWS, GCP, etc.)
- [ ] Maintenance & synchronisation avancée
    - [ ] Ajouter une commande ou un script d’admin pour la synchronisation complète Real-Debrid → SQLite (inventaire, migration, audit)
        - [ ] Intégrer la récupération détaillée des torrents (endpoint /torrents/info/{id}) en batch asynchrone, avec gestion des quotas et erreurs
    - [ ] Améliorer la gestion avancée des quotas, erreurs et logs dans les workers (robustesse, alertes, logs structurés)
    - [ ] Ajouter une interface d’audit/maintenance (page dashboard ou endpoint admin) pour :
        - [ ] Lancer des synchronisations
        - [ ] Exporter les données (CSV, JSON…)
        - [ ] Suivre l’état de la base (nombre de torrents, détails, erreurs récentes)
    - [ ] Documenter ces fonctions dans `docs/DEPLOIEMENT.md` et `docs/MAINTENANCE.md`
- [ ] Améliorations continues selon retours utilisateurs et besoins production

---

Le projet est prêt pour un déploiement automatisé, sécurisé et reproductible.

5. Points critiques, dette technique, failles, limitations
Endpoints critiques : sync et update bien séparés, mais la logique de scraping et de bulk actions reste à fiabiliser
Sécurité : bonne gestion du token, mais pas d’audit automatisé des dépendances, ni de tests d’intrusion
Documentation : très bonne base, mais la documentation API (OpenAPI) et la FAQ pourraient être enrichies
Dépendances : pas de vérification automatique des vulnérabilités (Snyk, pip-audit)
Tests : couverture à renforcer côté backend, pas de tests de montée en charge
Code : globalement idiomatique, mais quelques duplications (gestion des états sync/update), et certains scripts utilitaires pourraient être factorisés
Internationalisation : bien prévue, mais certains messages restent hardcodés
CI/CD : pipeline à compléter pour automatiser lint, test, build, release
Accessibilité : dark mode, responsive, navigation clavier, mais à tester avec lecteurs d’écran

6. Recommandations et modernisations
Renforcer la couverture de tests backend (sync, update, queue, sécurité)
Automatiser l’audit des dépendances (Snyk, pip-audit, npm audit)
Compléter la documentation API (OpenAPI/Swagger, exemples d’appels)
Factoriser la gestion des états sync/update (DRY)
Ajouter un monitoring (Sentry, dashboards admin)
Prévoir l’extension multi-utilisateurs et multi-services
Automatiser la CI/CD (lint, test, build, release, badge coverage)
Ajouter des tests de charge et de robustesse
Renforcer l’accessibilité (tests réels, WCAG)
Documenter la stratégie de release et de migration
Prévoir des scripts de migration et de backup automatisés
Moderniser le frontend si besoin (SvelteKit v2, etc.)