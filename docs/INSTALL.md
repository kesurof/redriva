# Guide # Guide d'Installation Redriva

## 📋 Prérequis
- **Docker & Docker Compose** (v2.0+) - Installation recommandée
- **Git** pour cloner le repository
- **jq** (optionnel) pour le parsing JSON dans les scripts
- (Optionnel) Python 3.10+, Node.js 20+ pour le développement manuel

## 🚀 Installation Rapide (Recommandée)

### Option 1 : Installation automatisée avec script

```bash
# Cloner le repository
git clone https://github.com/kesurof/redriva.git
cd redriva

# Lancer l'installation automatisée
./build-complete.sh
```

Le script s'occupe de :
- ✅ Vérifier les prérequis
- ✅ Construire les images Docker optimisées
- ✅ Gérer automatiquement les dépendances npm/pip
- ✅ Démarrer tous les services
- ✅ Effectuer les tests de santé
- ✅ Afficher les URLs d'accès

### Option 2 : Installation manuelle Docker Compose

```bash
# Cloner et naviguer
git clone https://github.com/kesurof/redriva.git
cd redriva

# Copier la configuration (optionnel)
cp .env.example .env  # puis éditez si nécessaire

# Build et démarrage
docker compose up --build -d
```

## 🌐 Accès aux Services

Une fois l'installation terminée :

- **🖥️ Interface Web** : [http://localhost:5174](http://localhost:5174)
- **🔧 API Backend** : [http://localhost:8080](http://localhost:8080)
- **📊 API Documentation** : [http://localhost:8080/docs](http://localhost:8080/docs)
- **🔍 Health Check** : [http://localhost:8080/api/ping](http://localhost:8080/api/ping)

## 🔧 Accès via SSH (Tests à distance)

Pour tester depuis votre machine locale via SSH :

```bash
# Tunnel SSH pour rediriger les ports
ssh -L 5174:localhost:5174 -L 8080:localhost:8080 user@votre-serveur

# Puis accédez localement :
# Frontend: http://localhost:5174
# Backend:  http://localhost:8080
```

## 🛠️ Gestion des Services

### Commandes utiles

```bash
# Voir l'état des services
docker compose ps

# Suivre les logs en temps réel
docker compose logs -f

# Logs d'un service spécifique
docker compose logs frontend -f
docker compose logs backend -f

# Redémarrer les services
docker compose restart

# Arrêter les services
docker compose down

# Reset complet avec nettoyage
./build-complete.sh --clean
```

### Reconstruction après modifications

```bash
# Après modification du code backend
docker compose build backend
docker compose up -d

# Après modification du code frontend
docker compose build frontend
docker compose up -d

# Reconstruction complète
docker compose build --no-cache
docker compose up -d
``` <repo>
cd redriva
cp config/.env.example config/.env  # puis renseignez votre token RD
docker compose up -d
```

Accédez à l'interface web sur [http://localhost:5174](http://localhost:5174)
L'API backend est disponible sur [http://localhost:8000](http://localhost:8000)ation Redriva

## Prérequis
- Docker et Docker Compose (recommandé)
- (Optionnel) Python 3.10+, Node.js 18+, pip, venv, git (pour installation manuelle)

## Installation rapide (Docker Compose recommandé)

```bash
git clone <repo>
cd redriva
cp config/.env.example config/.env  # puis renseignez votre token RD
docker compose up -d
```

Accédez à l’interface web sur [http://localhost:5173](http://localhost:5173)
L’API backend est disponible sur [http://localhost:8000](http://localhost:8000)

## 🏗️ Installation Manuelle (Développement Avancé)

Pour les développeurs souhaitant une installation sans Docker :

### Backend (Python/FastAPI)

```bash
# Cloner le repository
git clone https://github.com/kesurof/redriva.git
cd redriva

# Créer un environnement virtuel
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# ou : venv\Scripts\activate  # Windows

# Installer les dépendances
pip install -r backend/requirements.txt

# Lancer le backend
cd backend
uvicorn app:app --reload --host 0.0.0.0 --port 8080
```

### Frontend (Vue.js/Vite)

```bash
# Dans un nouveau terminal
cd redriva/frontend

# Installer les dépendances
npm install

# Mode développement
npm run dev

# Ou build pour production
npm run build
npx serve -s dist -l 5174
```

## 🏭 Déploiement Production

### Images Docker optimisées

Le projet inclut des Dockerfiles de production multi-étapes :

```bash
# Build des images de production
docker build -f frontend/Dockerfile.prod -t redriva-frontend:prod ./frontend
docker build -f backend/Dockerfile.prod -t redriva-backend:prod ./backend

# Déploiement avec docker-compose de production
docker compose -f docker-compose.prod.yml up -d
```

### Caractéristiques de production

- **🔒 Sécurité** : Utilisateurs non-root, permissions minimales
- **⚡ Performance** : Images Alpine Linux optimisées
- **📈 Monitoring** : Health checks et métriques intégrées
- **🛡️ Nginx** : Serveur web sécurisé pour le frontend
- **🔄 Hot reload** : Désactivé en production pour les performances

## 🧪 Tests et Validation

### Tests automatisés

```bash
# Tests backend
cd backend
pytest tests/ -v

# Tests frontend
cd frontend
npm run test

# Tests de bout en bout
npm run test:e2e
```

### Validation de l'installation

```bash
# Test de santé backend
curl http://localhost:8080/api/ping

# Test frontend
curl http://localhost:5174/

# Vérification avec le script
./build-complete.sh  # inclut les tests de validation
```

## 🔧 Configuration Avancée

### Variables d'environnement

Créez un fichier `.env` à la racine du projet :

```bash
# Copier le template
cp .env.example .env
```

Principales variables à configurer :

```env
# Real-Debrid (optionnel pour les tests)
REAL_DEBRID_API_KEY=your_api_key_here

# Base de données (SQLite par défaut)
DATABASE_URL=sqlite:///./data/redriva.db

# Sécurité
SECRET_KEY=your-super-secret-key-here
CORS_ORIGINS=http://localhost:5174

# Ports (si modification nécessaire)
BACKEND_PORT=8080
FRONTEND_PORT=5174

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/redriva.log

# Monitoring (optionnel)
ENABLE_METRICS=true
```

### Configuration Nginx (Production)

Le template `frontend/nginx.conf.template` est automatiquement configuré avec :

- **Gzip compression** pour les performances
- **Headers de sécurité** (HSTS, CSP, etc.)
- **Cache optimal** pour les assets statiques
- **Proxy reverse** vers l'API backend
- **Rate limiting** pour la protection

### Persistence des données

Les données sont automatiquement persistées dans :

```
redriva/
├── data/           # Base de données SQLite
├── logs/           # Logs applicatifs
└── backups/        # Sauvegardes automatiques
```

## 🚨 Dépannage

### Problèmes courants

**1. Port déjà utilisé**
```bash
# Vérifier les ports en cours d'utilisation
sudo netstat -tulpn | grep -E ':5174|:8080'

# Changer les ports dans docker-compose.yml
```

**2. Erreurs de permissions Docker**
```bash
# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker
```

**3. Dépendances npm non installées**
```bash
# Le script build-complete.sh gère cela automatiquement
./build-complete.sh

# Ou manuellement
docker compose run --rm frontend npm install
docker compose build frontend
```

**4. Erreurs de compilation TypeScript**
```bash
# Forcer la reconstruction complète
docker compose build --no-cache frontend
docker compose up -d
```

### Logs de débogage

```bash
# Voir tous les logs
docker compose logs -f

# Logs détaillés d'un service
docker compose logs frontend -f --tail=50

# Logs système
journalctl -u docker -f
```

### Reset complet

```bash
# Arrêt et nettoyage complet
./build-complete.sh --clean

# Ou manuellement
docker compose down --volumes --rmi all
docker system prune -af
```

## 📚 Ressources Supplémentaires

- **📖 Documentation API** : [http://localhost:8080/docs](http://localhost:8080/docs)
- **🔍 Troubleshooting** : [`docs/TROUBLESHOOTING.md`](./TROUBLESHOOTING.md)
- **🚀 Déploiement** : [`docs/DEPLOIEMENT.md`](./DEPLOIEMENT.md)
- **🏗️ Architecture** : [`docs/ARCHITECTURE.md`](./ARCHITECTURE.md)
- **🤝 Contribution** : [`docs/CONTRIBUTING.md`](./CONTRIBUTING.md)

## 💡 Support

- **Issues GitHub** : [Repository Issues](https://github.com/kesurof/redriva/issues)
- **Discussions** : [Repository Discussions](https://github.com/kesurof/redriva/discussions)
- **Wiki** : Documentation communautaire

---

## 🎯 Installation Réussie !

Après installation, vous devriez voir :

```
🎉 Build complet terminé avec succès !
======================================
📊 Services disponibles:
   • Backend API:  http://localhost:8080
   • Frontend:     http://localhost:5174
```

**Prochaines étapes :**
1. 🌐 Accédez à l'interface web sur [http://localhost:5174](http://localhost:5174)
2. 🔧 Configurez vos services dans la page Settings
3. 📚 Consultez la documentation API sur [http://localhost:8080/docs](http://localhost:8080/docs)
4. 🚀 Explorez les fonctionnalités du dashboard

**Bonne utilisation de Redriva ! 🎉**
