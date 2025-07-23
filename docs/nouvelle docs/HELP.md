# Script d'Aide - Guide d'Utilisation Redriva

## Scripts Disponibles

### Script de Développement (`./scripts/dev.sh`)

**Commandes principales:**
```bash
./scripts/dev.sh start          # Démarre l'environnement de développement
./scripts/dev.sh stop           # Arrête l'environnement
./scripts/dev.sh restart        # Redémarre l'environnement
./scripts/dev.sh rebuild        # Reconstruit les images et redémarre
```

**Debug et monitoring:**
```bash
./scripts/dev.sh logs           # Affiche tous les logs
./scripts/dev.sh logs backend   # Logs du backend uniquement
./scripts/dev.sh logs frontend  # Logs du frontend uniquement
./scripts/dev.sh shell          # Shell dans le backend
./scripts/dev.sh shell frontend # Shell dans le frontend
./scripts/dev.sh monitor        # Monitoring en temps réel
```

**Tests et qualité:**
```bash
./scripts/dev.sh test           # Lance tous les tests
./scripts/dev.sh lint           # Vérifie la qualité du code
```

**Base de données:**
```bash
./scripts/dev.sh db:reset       # Remet à zéro la base de données
```

**Production:**
```bash
./scripts/dev.sh build:prod     # Construit les images de production
./scripts/dev.sh deploy:prod    # Déploie en production
```

### Script de Déploiement Production (`./scripts/deploy-prod.sh`)

```bash
./scripts/deploy-prod.sh        # Déploiement automatique avec backup et rollback
```

## Workflow de Développement Recommandé

### 1. Démarrage Initial
```bash
# Cloner le projet
git clone <repository-url>
cd redriva

# Copier la configuration
cp .env.example .env
cp .env.prod.example .env.prod

# Configurer les variables d'environnement
vim .env

# Démarrer l'environnement de développement
./scripts/dev.sh start
```

### 2. Développement Quotidien
```bash
# Démarrer la journée
./scripts/dev.sh start

# Voir les logs en temps réel
./scripts/dev.sh logs

# Tester après modifications
./scripts/dev.sh test

# Arrêter en fin de journée
./scripts/dev.sh stop
```

### 3. Debug et Dépannage
```bash
# Problème avec les conteneurs ?
./scripts/dev.sh rebuild

# Problème persistant ?
./scripts/dev.sh clean    # ATTENTION: supprime tout

# Accéder au shell pour debug
./scripts/dev.sh shell backend

# Surveiller les performances
./scripts/dev.sh monitor
```

### 4. Avant Commit
```bash
# Vérifier la qualité du code
./scripts/dev.sh lint

# Lancer tous les tests
./scripts/dev.sh test

# Si tout est vert, commit !
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push
```

## URLs de Développement

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **Documentation API**: http://localhost:8080/docs
- **Redis**: localhost:6379

## Structure des Services

### Backend (Port 8080)
- API REST avec FastAPI
- Queue Redis/ARQ pour les tâches asynchrones
- Base de données SQLite
- Intégration Real-Debrid

### Frontend (Port 5173)
- Interface SvelteKit
- Hot-reload activé
- Proxy API automatique

### Redis (Port 6379)
- Queue pour les tâches
- Cache pour les sessions

## Dépannage Rapide

### Service ne démarre pas
```bash
# Vérifier les logs
./scripts/dev.sh logs [service]

# Reconstruire si nécessaire
./scripts/dev.sh rebuild
```

### Base de données corrompue
```bash
./scripts/dev.sh db:reset
```

### Espace disque plein
```bash
./scripts/dev.sh clean
```

### Ports occupés
```bash
# Changer les ports dans docker-compose.yml
# Ou arrêter le service qui utilise le port
sudo netstat -tulpn | grep :8080
```

## Production

### Configuration
1. Copier `.env.prod.example` vers `.env.prod`
2. Configurer toutes les variables de production
3. Configurer les secrets GitHub pour CI/CD

### Déploiement
```bash
# Construction locale
./scripts/dev.sh build:prod

# Déploiement (si configuré)
./scripts/dev.sh deploy:prod
```

## Support

Pour plus d'aide, consultez:
- `docs/TROUBLESHOOTING.md` - Guide de dépannage détaillé
- `docs/INSTALL.md` - Installation complète
- `docs/USAGE.md` - Guide d'utilisation
- Issues GitHub du projet
