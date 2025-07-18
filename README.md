
# Redriva – Gestionnaire Real-Debrid moderne

Redriva est une application web complète pour gérer, visualiser et automatiser vos torrents et téléchargements Real-Debrid, avec une interface moderne, sécurisée et évolutive.

## Fonctionnalités principales
- Tableau de bord (stats, filtres, alertes, logs, quotas)
- File d’attente et gestion des priorités (ajout, suppression, actions, polling)
- Ajout/suppression de torrents, visualisation détaillée
- Scraper intégré, gestion en masse, détection liens morts
- Internationalisation (i18n), dark mode, responsive
- Sécurité avancée (token jamais côté client, logs, rate limiting)
- Tests unitaires, E2E, CI/CD, documentation complète

## Structure du projet
- `frontend/` : code source SvelteKit (UI, composants, pages)
- `backend/` : code source FastAPI (API, modèles, sécurité)
- `docs/` : documentation technique, guides, FAQ, déploiement
- `tests/` : tests unitaires, intégration, E2E
- `scripts/` : scripts utilitaires, maintenance
- `config/` : fichiers de configuration et secrets (jamais committer)
- `logs/` : logs applicatifs persistants
- `data/` : base de données et données persistantes
- `systemd/` : fichiers d’unités systemd (déploiement classique)

## Déploiement rapide (Docker Compose recommandé)
1. Clonez le dépôt et placez-vous à la racine.
2. Copiez le fichier `.env` d’exemple dans `config/` et renseignez votre token Real-Debrid.
3. Lancez :
   ```sh
   docker compose up -d
   ```
4. Accédez à l’interface web sur [http://localhost:5173](http://localhost:5173)
5. L’API backend est disponible sur [http://localhost:8000](http://localhost:8000)

> Les données et logs sont persistés dans les dossiers `data/` et `logs/`.

## Déploiement cloud & production
- Ajoutez un reverse proxy (nginx/caddy) dans `docker-compose.yml` pour HTTPS et le routage `/api`.
- Utilisez le playbook Ansible (`ansible/`) pour automatiser l’installation, la configuration et le déploiement.
- Mettez en place un pipeline CI/CD (ex : `.github/workflows/deploy.yml`) pour build, test et déploiement auto.
- Voir `docs/DEPLOIEMENT.md` pour tous les scénarios (local, systemd, cloud).

## Maintenance & debug
- Les logs applicatifs sont dans `logs/` (backend, worker, erreurs)
- Les données sont dans `data/` (SQLite, fichiers)
- Pour voir les logs Docker :
  ```sh
  docker compose logs
  ```
- Pour mettre à jour :
  ```sh
  git pull && docker compose build && docker compose up -d
  ```
- Voir la FAQ et le troubleshooting dans `docs/`

## Contribution & ajout de fonctionnalités
- Forkez le dépôt, créez une branche dédiée (`feature/xxx` ou `fix/xxx`)
- Respectez la structure, documentez vos changements, ajoutez des tests
- Toute évolution de déploiement doit être testée et documentée (`docs/DEPLOIEMENT.md`)
- Voir le guide complet dans `docs/CONTRIBUTING.md`

## Support & documentation
- Consultez la documentation technique et la FAQ dans `docs/`
- Ouvrez une issue pour toute question ou bug

---
**Sécurité : ne commitez jamais de secrets ou de tokens dans le dépôt.**
