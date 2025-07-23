# 🚀 Guide d'Installation Redriva

## Prérequis Système

### Logiciels Requis
- **Docker** (v20.10+) et **Docker Compose** (v2.0+)
- **Git** pour cloner le repository
- **Navigateur moderne** (Chrome, Firefox, Safari, Edge)

### Comptes et Tokens
- **Compte Real-Debrid** actif ([s'inscrire](https://real-debrid.com/))
- **Token API Real-Debrid** ([obtenir ici](https://real-debrid.com/apitoken))

### Configuration Système Recommandée

**Développement :**
- RAM : 4 GB minimum, 8 GB recommandé
- Stockage : 10 GB d'espace libre
- Processeur : 2 cœurs minimum

**Production :**
- RAM : 2 GB minimum, 4 GB recommandé
- Stockage : 20 GB d'espace libre
- Processeur : 2 cœurs minimum
- Réseau : Connexion stable pour Real-Debrid

## Installation Développement

### 1. Clonage et Préparation

```bash
# Cloner le repository
git clone https://github.com/kesurof/redriva.git
cd redriva

# Vérifier Docker
docker --version
docker compose version
```

### 2. Configuration de Base

```bash
# Copier les fichiers de configuration
cp .env.example .env

# Éditer le fichier .env
nano .env  # ou vim .env
```

**Configuration minimale (.env) :**
```bash
# Real-Debrid (OBLIGATOIRE)
RD_TOKEN=votre_token_real_debrid_ici

# Optionnel (valeurs par défaut)
ENVIRONMENT=development
LOG_LEVEL=DEBUG
DB_PATH=./data/redriva.db
REDIS_URL=redis://redis:6379/0
```

### 3. Démarrage Express

```bash
# Méthode recommandée avec scripts
./scripts/dev.sh start

# Vérification du démarrage
./scripts/dev.sh status
```

### 4. Accès à l'Application

- **Interface Web :** http://localhost:5174
- **API Backend :** http://localhost:8080
- **Documentation API :** http://localhost:8080/docs

### 5. Vérification de l'Installation

```bash
# Tests complets
./scripts/dev.sh test

# Vérification des logs
./scripts/dev.sh logs

# Vérification santé des services
curl http://localhost:5174
curl http://localhost:8080/api/ping
```

## Installation Production

### 1. Préparation du Serveur

```bash
# Sur votre serveur de production
git clone https://github.com/kesurof/redriva.git
cd redriva

# Configuration production
cp .env.prod.example .env.prod
```

### 2. Configuration Production

**Éditer .env.prod :**
```bash
# Real-Debrid (OBLIGATOIRE)
RD_TOKEN=votre_token_real_debrid

# Configuration production
ENVIRONMENT=production
LOG_LEVEL=INFO
DB_PATH=/app/data/redriva.db
REDIS_URL=redis://redis:6379/0

# Sécurité (optionnel)
SECRET_KEY=votre_clé_secrète_unique
```

### 3. Déploiement

```bash
# Déploiement automatique
./scripts/deploy.sh deploy

# Vérification
./scripts/deploy.sh status
```

### 4. Accès Production

- **Application :** http://votre-serveur:3000
- **SSL/HTTPS :** Configurez un reverse proxy externe (Nginx/Caddy)

## Installation Avancée

### Configuration Nginx (Optionnel)

Si vous voulez exposer Redriva via un nom de domaine avec SSL :

```nginx
# /etc/nginx/sites-available/redriva
server {
    listen 80;
    server_name votre-domaine.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Configuration Systemd (Optionnel)

Pour un démarrage automatique au boot :

```bash
# Créer le service
sudo cp systemd/redriva.service /etc/systemd/system/
sudo systemctl enable redriva
sudo systemctl start redriva
```

### Sauvegarde et Restauration

```bash
# Sauvegarde des données
./scripts/deploy.sh backup

# Restauration
./scripts/deploy.sh restore backup-YYYYMMDD-HHMMSS.tar.gz
```

## Dépannage Installation

### Erreurs Communes

**Docker non trouvé :**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install docker.io docker-compose-plugin

# CentOS/RHEL
sudo yum install docker docker-compose
```

**Permissions Docker :**
```bash
sudo usermod -aG docker $USER
# Puis redémarrer la session
```

**Port déjà utilisé :**
```bash
# Vérifier les ports occupés
sudo netstat -tlnp | grep :5174
sudo netstat -tlnp | grep :8080

# Arrêter les services conflictuels
sudo systemctl stop apache2 nginx
```

**Token Real-Debrid invalide :**
1. Vérifiez votre token sur https://real-debrid.com/apitoken
2. Assurez-vous qu'il n'y a pas d'espaces dans le .env
3. Redémarrez après modification : `./scripts/dev.sh restart`

### Vérifications Post-Installation

```bash
# Santé des conteneurs
docker compose ps

# Logs détaillés
docker compose logs --tail=50

# Test des endpoints
curl -H "Accept: application/json" http://localhost:8080/api/ping
```

### Mise à Jour

```bash
# Mise à jour du code
git pull origin main

# Reconstruction et redémarrage
./scripts/dev.sh rebuild  # Développement
./scripts/deploy.sh deploy  # Production
```

## Support

Si vous rencontrez des problèmes :

1. **Consultez les logs :** `./scripts/dev.sh logs`
2. **Vérifiez la documentation :** [docs/](./README.md)
3. **Ouvrez une issue :** [GitHub Issues](https://github.com/kesurof/redriva/issues)
4. **Discussions :** [GitHub Discussions](https://github.com/kesurof/redriva/discussions)

---

✅ **Installation réussie !** Vous pouvez maintenant utiliser Redriva pour gérer vos téléchargements Real-Debrid.
