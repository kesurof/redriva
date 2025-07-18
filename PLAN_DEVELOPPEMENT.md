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
- Dockerfile complet pour déploiement autonome
- Documentation procédure de déploiement (Docker, systemd, etc.)

---

Prochaine étape :
- Déploiement (Dockerfile, documentation procédure Docker/systemd)

