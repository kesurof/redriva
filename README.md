
# Redriva – Gestionnaire Real-Debrid moderne

Redriva est une application web complète pour gérer, visualiser et automatiser vos torr## Structure du projet
- `frontend/` : code source Vue.js 3 + Vuetify (UI, composants, vues)
- `backend/` : code source FastAPI (API, modèles, sécurité)
- `docs/` : documentation technique, guides, FAQ, déploiement
- `tests/` : tests unitaires, intégration, E2E
- `scripts/` : scripts utilitaires, maintenance
- `config/` : fichiers de configuration et secrets (jamais committer)
- `logs/` : logs applicatifs persistants
- `data/` : base de données et données persistantes
- `systemd/` : fichiers d'unités systemd (déploiement classique)léchargements Real-Debrid, avec une interface moderne, sécurisée et évolutive.

## 🚀 Fonctionnalités principales

### Interface Utilisateur
- 📊 **Tableau de bord** : Statistiques en temps réel, filtres avancés, alertes automatiques
- 📋 **File d'attente intelligente** : Gestion des priorités avec actions groupées et polling automatique
- 🎯 **Gestion des torrents** : Ajout/suppression, visualisation détaillée, scraper intégré
- 🌍 **Expérience utilisateur** : Interface responsive, dark mode, internationalisation (i18n)

### Sécurité et Production
- 🔒 **Sécurité avancée** : Tokens sécurisés, rate limiting, logs d'audit complets
- 📈 **Monitoring** : Métriques Prometheus, surveillance des performances
- 🔧 **Maintenance** : Scripts d'automatisation, mises à jour sécurisées
- 🛡️ **Audits** : Vérification automatique des vulnérabilités

### DevOps et Qualité
- ✅ **Tests complets** : Tests unitaires, intégration, E2E avec Playwright
- 🔄 **CI/CD** : Workflows GitHub Actions, déploiement automatisé
- 📚 **Documentation** : Guides complets, API documentée, FAQ
- 🐳 **Containerisation** : Images Docker optimisées, orchestration

## 📁 Structure du projet

```
redriva/
├── frontend/               # Application Vue.js 3 + Vuetify (UI moderne)
│   ├── src/
│   │   ├── components/    # Composants réutilisables
│   │   ├── views/         # Pages et vues
│   │   ├── composables/   # Stores et logique réactive
│   │   └── main.ts        # Point d'entrée principal
│   ├── Dockerfile         # Image de production
│   └── nginx.conf.template # Configuration Nginx sécurisée
├── backend/               # API FastAPI (serveur robuste)
│   ├── app.py             # Application principale
│   ├── services/          # Services métier
│   │   ├── monitoring.py  # Métriques Prometheus
│   │   └── realdebrid.py  # Intégration Real-Debrid
│   ├── database/          # Gestion des données
│   └── Dockerfile         # Image de production
├── scripts/               # Scripts d'automatisation
│   ├── deploy-unified.sh  # Déploiement orchestré
│   ├── security-audit.sh  # Audit de sécurité
│   ├── update-deps.sh     # Mise à jour des dépendances
│   ├── performance-test.sh # Tests de performance
│   ├── validate.sh        # Validation complète
│   └── README.md          # Documentation des scripts
├── .github/workflows/     # CI/CD GitHub Actions
│   └── security-audit.yml # Workflow de sécurité
├── docs/                  # Documentation technique
└── docker-compose.yml     # Orchestration complète
```

## ⚡ Démarrage rapide

### Validation et déploiement automatique
```bash
# 1. Validation complète du projet
./scripts/validate.sh

# 2. Déploiement unifié (recommandé)
./scripts/deploy-unified.sh deploy

# 3. Accès à l'application
# Frontend: http://localhost:3000
# API: http://localhost:8000
# Métriques: http://localhost:8000/metrics
```

### Déploiement manuel
```bash
# Construction et démarrage
docker compose up -d --build

# Vérification des services
docker compose ps
curl http://localhost:8000/health
```

## 🔧 Scripts d'Automatisation

Redriva inclut une suite complète de scripts pour automatiser la maintenance, la sécurité et le déploiement :

### Scripts Principaux
| Script | Description | Usage |
|--------|-------------|-------|
| `validate.sh` | Validation complète du projet | `./scripts/validate.sh` |
| `deploy-unified.sh` | Déploiement orchestré | `./scripts/deploy-unified.sh deploy` |
| `security-audit.sh` | Audit de sécurité automatisé | `./scripts/security-audit.sh` |
| `update-deps.sh` | Mise à jour des dépendances | `./scripts/update-deps.sh` |
| `performance-test.sh` | Tests de performance | `./scripts/performance-test.sh` |

### Workflows Automatisés

**Développement :**
```bash
# Audit + Déploiement dev + Tests
./scripts/security-audit.sh
./scripts/deploy-unified.sh deploy --environment development
./scripts/performance-test.sh --load-only
```

**Production :**
```bash
# Validation complète + Déploiement sécurisé
./scripts/validate.sh
./scripts/deploy-unified.sh deploy --performance-tests
```

**Maintenance mensuelle :**
```bash
# Mise à jour + Audit + Tests
./scripts/update-deps.sh
./scripts/security-audit.sh
./scripts/performance-test.sh
```

📖 **Documentation complète :** [`scripts/README.md`](scripts/README.md)naire Real-Debrid moderne

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


## Procédure post-build Docker (serveur de test)

Après avoir build les images Docker, suivez ces étapes pour lancer et vérifier Redriva :

### 1. Configurer les variables d’environnement
- Vérifiez que le fichier `config/.env` contient bien la variable `RD_TOKEN` (token Real-Debrid) côté backend.
- Vérifiez les autres variables nécessaires (chemins, options spécifiques).

### 2. Lancer les services
Dans le dossier du projet :
```sh
docker compose up -d
```
Cela démarre les services backend et frontend en mode détaché.

### 3. Vérifier l’état des services
```sh
docker compose ps
```
Les deux services doivent être en statut `running` ou `healthy`.

### 4. Accéder à l’application
- **Frontend** : [http://localhost:4173](http://localhost:4173) (ou l’IP/nom du serveur si distant)
- **Backend (API)** : [http://localhost:8000/api/ping](http://localhost:8000/api/ping)

### 5. Logs et débogage
Pour consulter les logs en temps réel :
```sh
docker compose logs -f
```

### 6. Arrêter les services
Pour arrêter proprement :
```sh
docker compose down
```

### 7. Checklist post-déploiement
- Vérifiez que l’interface frontend s’affiche et communique bien avec le backend.
- Testez une action clé (connexion, affichage des torrents, etc.).
- Contrôlez les logs pour détecter d’éventuelles erreurs ou warnings.

---

### Prérequis
- Docker et Docker Compose installés
- Un token Real-Debrid valide (à placer dans `config/.env`)

### Déploiement local complet
1. Clonez le dépôt et placez-vous à la racine du projet :
   ```sh
   git clone https://github.com/kesurof/redriva.git
   cd redriva
   ```
2. Éditez le fichier `config/.env` et renseignez votre token Real-Debrid :
   ```sh
   nano config/.env
   # ou utilisez votre éditeur préféré
   # Remplacez la valeur de RD_TOKEN=... par votre token
   ```
3. Lancez la stack complète (backend + frontend) :
   ```sh
   docker compose build
   docker compose up -d
   ```
4. Vérifiez que les services sont bien démarrés :
   ```sh
   docker compose ps
   docker compose logs -f frontend
   docker compose logs -f backend
   ```
5. Accédez à l’interface web :
   - Frontend : [http://localhost:5173](http://localhost:5173)
   - API backend : [http://localhost:8000](http://localhost:8000)

> Les données (SQLite) et logs sont persistés dans les dossiers `data/` et `logs/` montés en volume.

### Déploiement production/cloud (recommandé)
1. **Reverse proxy HTTPS** : ajoutez un service nginx/caddy/traefik dans `docker-compose.yml` pour :
   - Terminer TLS (HTTPS)
   - Router `/api` vers le backend (8000), `/` vers le frontend (5173 ou 3000)
   - Exemple de config nginx : voir `docs/DEPLOIEMENT.md`
2. **Variables d’environnement** : ne jamais commiter de secrets, utilisez `config/.env` monté en volume ou injecté par CI/CD.
3. **Build & déploiement CI/CD** :
   - Utilisez GitHub Actions ou GitLab CI pour builder les images, lancer les tests, et déployer automatiquement sur le serveur cible.
   - Voir `.github/workflows/deploy.yml` pour un exemple.
4. **Mise à jour** :
   ```sh
   git pull
   docker compose build
   docker compose up -d
   ```
5. **Sauvegardes** : sauvegardez régulièrement `data/` (base SQLite) et `logs/`.

### Conseils avancés
- Pour un déploiement systemd classique, voir `systemd/redriva.service` et la doc `docs/DEPLOIEMENT.md`.
- Pour un déploiement cloud scalable, adaptez les ports, variables et volumes dans `docker-compose.yml`.
- Pour un déploiement multi-utilisateurs, voir la roadmap et les guides d’authentification dans `docs/`.

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

## 📚 Documentation

- [Guide d'installation](docs/INSTALL.md)
- [Guide d'utilisation](docs/USAGE.md)
- [Contribution](docs/CONTRIBUTING.md)
- [Dépannage](docs/TROUBLESHOOTING.md)
- [Déploiement](docs/DEPLOIEMENT.md)

Pour toute question, consultez la documentation dans le dossier `docs/` ou ouvrez une issue.

---
**Sécurité : ne commitez jamais de secrets ou de tokens dans le dépôt.**
