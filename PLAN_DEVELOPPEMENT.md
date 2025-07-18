# Plan de développement Redriva

## 1. Sécurité & Backend
- [x] Gestion sécurisée du token Real-Debrid (stockage serveur, variable d’environnement, jamais côté client)
- [x] Ajout d’un système de logs structurés (logs/)
- [x] Rate limiting sur les endpoints sensibles

## 2. API & Fonctionnalités
- Endpoints REST manquants :
  - Ajout de torrent (POST /api/torrents)
  - Suppression de torrent (DELETE /api/torrents/{id})
  - Détail d’un torrent (GET /api/torrents/{id})
- [x] Intégration de la récupération réelle des torrents via l’API Real-Debrid
- [x] Gestion des erreurs et réponses normalisées

## 3. Persistance & Données
- Étendre le modèle SQLite (dates, liens, statut détaillé…)
- Script de migration/init base si évolution du schéma
- Purge/archivage des torrents obsolètes

## 4. Tests & Qualité
- Tests unitaires pour endpoints et persistance (tests/)
- Linter (flake8) et formatage (black)
- Badge de couverture de tests dans le README

## 5. Documentation & Onboarding
- Compléter le README (exemples API, captures, installation)
- Section troubleshooting et FAQ
- Documentation OpenAPI/Swagger


- [x] Structure SvelteKit avec svelte-i18n et TailwindCSS
- [x] Premiers composants UI (table, modal, loader, notifications)

## 6. Frontend
- [x] Structure SvelteKit avec svelte-i18n et TailwindCSS
- [x] Premiers composants UI (table, modal, loader, notifications)
- [x] Intégration API Redriva (fetch des torrents, ajout via modal)
- [x] Page /torrents : affichage liste, ajout (CRUD partiel)
- [ ] Suppression et détail de torrent (UI + API)
- [ ] Pages /downloads, /scraper, /settings (squelettes)
- [ ] Dark mode toggle et responsive complet
- [ ] Feedbacks visuels avancés, gestion erreurs, loaders contextuels
- [ ] Internationalisation complète (toutes chaînes, notifications, erreurs)
- [ ] Tests E2E (Playwright) pour les parcours critiques
- [ ] Documentation UI : guide de contribution, conventions, exemples d’intégration

### Prochaines étapes Frontend

1. Finaliser CRUD torrents (suppression, détail)
   - Ajouter la suppression de torrent côté UI (bouton, appel API DELETE)
   - Afficher le détail d’un torrent (modal ou panneau latéral, appel API GET /api/torrents/{id})
2. Créer les pages /downloads, /scraper, /settings (squelettes)
   - Générer les routes et composants de base pour chaque page
3. Ajouter le dark mode toggle et améliorer le responsive
   - Intégrer un switch dark/light, vérifier le rendu mobile/tablette
4. Compléter l’internationalisation et les feedbacks UX
   - Traduire toutes les chaînes, notifications, erreurs
   - Ajouter des loaders contextuels et des toasts pour chaque action
5. Ajouter des tests E2E (Playwright) pour les parcours critiques
   - Tester l’ajout, la suppression, la navigation, l’affichage des erreurs
6. Documenter l’UI : guide de contribution, conventions, exemples d’intégration
- [x] Intégration API Redriva (fetch des torrents, ajout via modal)
- [x] Page /torrents : affichage liste, ajout (CRUD partiel)
- [ ] Suppression et détail de torrent (UI + API)
- [ ] Pages /downloads, /scraper, /settings (squelettes)
- [ ] Dark mode toggle et responsive complet
- [ ] Feedbacks visuels avancés, gestion erreurs, loaders contextuels
- [ ] Internationalisation complète (toutes chaînes, notifications, erreurs)
- [ ] Tests E2E (Playwright) pour les parcours critiques
- [ ] Documentation UI : guide de contribution, conventions, exemples d’intégration

### Prochaines étapes Frontend

1. Finaliser CRUD torrents (suppression, détail)
   - Ajouter la suppression de torrent côté UI (bouton, appel API DELETE)
   - Afficher le détail d’un torrent (modal ou panneau latéral, appel API GET /api/torrents/{id})
2. Créer les pages /downloads, /scraper, /settings (squelettes)
   - Générer les routes et composants de base pour chaque page
3. Ajouter le dark mode toggle et améliorer le responsive
   - Intégrer un switch dark/light, vérifier le rendu mobile/tablette
4. Compléter l’internationalisation et les feedbacks UX
   - Traduire toutes les chaînes, notifications, erreurs
   - Ajouter des loaders contextuels et des toasts pour chaque action
5. Ajouter des tests E2E (Playwright) pour les parcours critiques
   - Tester l’ajout, la suppression, la navigation, l’affichage des erreurs
6. Documenter l’UI : guide de contribution, conventions, exemples d’intégration

## 7. Observabilité & Maintenance
- Monitoring (Sentry, logs d’audit)
- Dashboard d’administration (état jobs, logs, quotas)

## 8. Déploiement
- Dockerfile complet pour déploiement autonome
- Documentation procédure de déploiement (Docker, systemd, etc.)

---

Ce plan sera mis à jour au fil de l’avancement du projet.
