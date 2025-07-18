# Procédure de déploiement Redriva (Docker & systemd)

## Déploiement avec Docker


1. Construire l’image Docker :
   ```sh
   docker build -t redriva-autonome .
   ```

2. Lancer le conteneur (mode détaché, dossiers montés pour la persistance) :
   ```sh
   docker run -d --name redriva-autonome \
     -v "$PWD/config":/app/config \
     -v "$PWD/logs":/app/logs \
     -v "$PWD/data":/app/data \
     -e RD_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
     -p 8000:8000 \
     redriva-autonome
   ```
   > **Important** : le token Real-Debrid (`RD_TOKEN`) doit être passé en variable d’environnement ou via un fichier monté, JAMAIS inclus dans l’image.

3. Arrêter et supprimer le conteneur :
   ```sh
   docker stop redriva-autonome && docker rm redriva-autonome
   ```

4. Accéder à l’API backend :
   http://localhost:8000/api/ping

5. (Optionnel) Servir le frontend buildé avec un serveur statique (nginx, serve) si besoin.

6. Conseils sécurité & bonnes pratiques :
   - Ne jamais exposer le token RD dans l’image Docker.
   - Toujours monter les dossiers `logs`, `data`, `config` en volume pour la persistance.
   - Adapter la configuration selon l’environnement cible (dev/prod).

## Déploiement avec systemd (mode utilisateur)

1. Copier le fichier d’unité systemd fourni dans `systemd/redriva.service` dans `~/.config/systemd/user/`.
2. Activer et démarrer le service :
   ```sh
   systemctl --user enable redriva.service
   systemctl --user start redriva.service
   ```
3. Vérifier le statut :
   ```sh
   systemctl --user status redriva.service
   ```
4. Arrêter proprement :
   ```sh
   systemctl --user stop redriva.service
   ```

## Conseils
- Ne jamais exposer le token Real-Debrid dans l’image, toujours le passer via un volume ou variable d’environnement.
- Adapter les chemins de montage selon la structure réelle du projet.
- Pour logs persistants, toujours monter le dossier logs en volume.
- Pour le frontend, adapter le reverse proxy (nginx, caddy) si besoin.

---

Pour plus de détails, consulter le README et la documentation du projet.
