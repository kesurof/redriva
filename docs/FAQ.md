# ❓ Foire Aux Questions (FAQ) - Redriva

## 🚀 Installation et Configuration

### Q: Quels sont les prérequis pour installer Redriva ?
**R:** Vous avez besoin de :
- Docker et Docker Compose (versions récentes)
- Un compte Real-Debrid actif
- Un token API Real-Debrid
- 4 GB de RAM minimum (8 GB recommandé)
- 10 GB d'espace disque libre

### Q: Comment obtenir un token Real-Debrid ?
**R:** 
1. Connectez-vous à votre compte Real-Debrid
2. Allez dans [Paramètres > API](https://real-debrid.com/apitoken)
3. Copiez le token généré
4. Ajoutez-le dans votre fichier `.env` : `RD_TOKEN=votre_token_ici`

### Q: L'installation échoue avec une erreur Docker
**R:** Vérifiez que :
- Docker est démarré : `sudo systemctl start docker`
- Vous avez les permissions : `sudo usermod -aG docker $USER`
- Les ports 5174 et 8080 sont libres
- Redémarrez votre session après ajout au groupe docker

### Q: Comment changer les ports par défaut ?
**R:** Modifiez le fichier `docker-compose.yml` :
```yaml
ports:
  - "NOUVEAU_PORT:5174"  # Frontend
  - "NOUVEAU_PORT:8080"  # Backend
```

## 🔧 Utilisation

### Q: Comment ajouter un torrent ?
**R:** 
1. Accédez à la page "Torrents"
2. Cliquez sur "Ajouter un torrent"
3. Collez l'URL magnet ou téléchargez un fichier .torrent
4. Le torrent sera automatiquement ajouté à Real-Debrid

### Q: Pourquoi mon torrent reste en "attente" ?
**R:** Plusieurs causes possibles :
- Token Real-Debrid invalide ou expiré
- Quota Real-Debrid dépassé
- Torrent non supporté par Real-Debrid
- Problème de connectivité réseau

### Q: Comment télécharger les fichiers terminés ?
**R:** 
1. Attendez que le statut passe à "Terminé" ✅
2. Cliquez sur le torrent pour voir les détails
3. Sélectionnez les fichiers désirés
4. Cliquez sur "Télécharger"

### Q: L'interface est lente, que faire ?
**R:** 
- Vérifiez les logs : `./scripts/dev.sh logs`
- Redémarrez les services : `./scripts/dev.sh restart`
- Augmentez la RAM allouée à Docker
- Vérifiez votre connexion Internet

## 🔒 Sécurité et Données

### Q: Mes données sont-elles sécurisées ?
**R:** Oui :
- Token stocké localement uniquement
- Communications HTTPS en production
- Aucune donnée partagée avec des tiers
- Code source ouvert et auditable

### Q: Puis-je utiliser Redriva sans token Real-Debrid ?
**R:** Non, le token Real-Debrid est obligatoire pour toutes les fonctionnalités. Redriva est spécifiquement conçu pour Real-Debrid.

### Q: Comment sauvegarder mes données ?
**R:** 
```bash
# Sauvegarde automatique (production)
./scripts/deploy.sh backup

# Sauvegarde manuelle
docker compose exec backend cp -r /app/data /backup/
```

## 🐳 Docker et Déploiement

### Q: Différence entre mode développement et production ?
**R:** 
- **Développement** : Hot reload, logs détaillés, outils de debug
- **Production** : Optimisé, sécurisé, reverse proxy, logs minimaux

### Q: Comment mettre à jour Redriva ?
**R:** 
```bash
# Récupérer les dernières modifications
git pull origin main

# Reconstruire et redémarrer
./scripts/dev.sh rebuild      # Développement
./scripts/deploy.sh deploy    # Production
```

### Q: Comment déployer en production sur un serveur distant ?
**R:** 
1. Clonez le repository sur le serveur
2. Configurez `.env.prod` avec vos valeurs
3. Lancez `./scripts/deploy.sh deploy`
4. Configurez un reverse proxy (Nginx) pour HTTPS

### Q: Les conteneurs consomment trop de ressources
**R:** Modifiez les limites dans `docker-compose.prod.yml` :
```yaml
deploy:
  resources:
    limits:
      memory: 256M
      cpus: '0.25'
```

## 🔧 Dépannage Technique

### Q: Erreur "Port already in use"
**R:** 
```bash
# Identifier le processus utilisant le port
sudo netstat -tlnp | grep :5174

# Arrêter le processus
sudo kill -9 PID_DU_PROCESSUS

# Ou changer le port dans docker-compose.yml
```

### Q: Erreur de base de données SQLite
**R:** 
```bash
# Réinitialiser la base de données
./scripts/dev.sh db:reset

# Ou supprimer manuellement
rm -rf data/redriva.db
./scripts/dev.sh restart
```

### Q: Redis ne démarre pas
**R:** 
- Vérifiez les logs : `docker compose logs redis`
- Supprimez les données Redis : `docker volume rm redriva_redriva-redis`
- Redémarrez : `./scripts/dev.sh restart`

### Q: Frontend ne se charge pas
**R:** 
1. Vérifiez que le backend répond : `curl http://localhost:8080/api/ping`
2. Consultez les logs frontend : `./scripts/dev.sh logs frontend`
3. Reconstruisez : `./scripts/dev.sh rebuild`

## 🌐 Réseau et Connectivité

### Q: Comment accéder à Redriva depuis un autre appareil ?
**R:** 
1. Remplacez `localhost` par l'IP de votre serveur
2. Assurez-vous que les ports sont ouverts dans le firewall
3. En production, utilisez un reverse proxy avec SSL

### Q: Real-Debrid API retourne des erreurs
**R:** 
- Vérifiez la validité de votre token
- Contrôlez votre quota et limites
- Vérifiez la connectivité : `curl https://api.real-debrid.com/rest/1.0/user`

### Q: Comment configurer HTTPS ?
**R:** Utilisez un reverse proxy externe (non inclus dans Redriva) :
```nginx
server {
    listen 443 ssl;
    server_name votre-domaine.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

## 📊 Monitoring et Performance

### Q: Comment surveiller les performances ?
**R:** 
- Dashboard intégré avec métriques temps réel
- Page Services pour détails techniques
- Logs avec `./scripts/dev.sh monitor`
- Métriques Prometheus sur `/metrics`

### Q: L'application utilise trop de mémoire
**R:** 
- Ajustez les limites Docker
- Videz le cache Redis régulièrement
- Augmentez la RAM de votre système
- Surveillez les fuites mémoire dans les logs

## 🤝 Développement et Contribution

### Q: Comment contribuer au projet ?
**R:** 
1. Forkez le repository GitHub
2. Créez une branche feature
3. Développez avec `./scripts/dev.sh`
4. Testez avec `./scripts/dev.sh test`
5. Soumettez une Pull Request

### Q: Comment ajouter une nouvelle page ?
**R:** 
1. Créez `src/views/MaPage.vue`
2. Ajoutez la route dans `src/router/index.ts`
3. Utilisez Vuetify pour l'interface
4. Testez avec hot reload

### Q: Quelle est la philosophie "Zéro Réécriture" ?
**R:** Le même code source fonctionne en développement ET production. Seules les configurations Docker changent, éliminant la maintenance double.

## 📞 Support

### Q: Où obtenir de l'aide ?
**R:** 
- **Documentation** : Dossier `docs/`
- **Issues** : [GitHub Issues](https://github.com/kesurof/redriva/issues)
- **Discussions** : [GitHub Discussions](https://github.com/kesurof/redriva/discussions)
- **Email** : Voir le profil GitHub du mainteneur

### Q: Comment signaler un bug ?
**R:** 
1. Vérifiez que ce n'est pas déjà signalé
2. Ouvrez une issue GitHub avec :
   - Description du problème
   - Étapes pour reproduire
   - Logs pertinents
   - Configuration système

### Q: Des fonctionnalités sont-elles prévues ?
**R:** Consultez :
- Les issues GitHub labelées "enhancement"
- La roadmap dans les discussions
- Les Pull Requests en cours

---

💡 **Votre question n'est pas listée ?** Ouvrez une [discussion GitHub](https://github.com/kesurof/redriva/discussions) ou une [issue](https://github.com/kesurof/redriva/issues) !
