
# Pr1. Clonez le dépôt et placez-vous à la racine.
2. Copiez le fichier `.env` d'exemple dans `config/` et renseignez votre token Real-Debrid.
3. Lancez :
   ```sh
   docker compose up -d
   ```
4. Accédez à l'interface web sur [http://localhost:5174](http://localhost:5174)
5. L'API backend est disponible sur [http://localhost:8000](http://localhost:8000)de déploiement Redriva

## 1. Déploiement recommandé : Docker Compose

1. Clonez le dépôt et placez-vous à la racine.
2. Copiez le fichier `.env` d’exemple dans `config/` et renseignez votre token Real-Debrid.
3. Lancez :
   ```sh
   docker compose up -d
   ```
4. Accédez à l’interface web sur [http://localhost:5173](http://localhost:5173)
5. L’API backend est disponible sur [http://localhost:8000](http://localhost:8000)

> Les données et logs sont persistés dans les dossiers `data/` et `logs/`.

## 2. Déploiement cloud & production

- Ajoutez un reverse proxy (nginx/caddy) dans `docker-compose.yml` pour HTTPS et le routage `/api`.
- Utilisez le playbook Ansible (`ansible/`) pour automatiser l’installation, la configuration et le déploiement.
- Mettez en place un pipeline CI/CD (ex : `.github/workflows/deploy.yml`) pour build, test et déploiement auto.
- Voir le README et le plan pour tous les scénarios (local, systemd, cloud).

## 3. Déploiement avec systemd (mode utilisateur, optionnel)

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

## 4. Maintenance, debug et sécurité

- Les logs applicatifs sont dans `logs/` (backend, worker, erreurs)
- Les données sont dans `data/` (SQLite, fichiers)
- Pour voir les logs Docker :
  ```sh
  docker compose logs
  ```
- Pour mettre à jour :
  ```sh
  git pull && docker compose build && docker compose up -d
  ```
- Ne jamais exposer le token Real-Debrid dans l’image, toujours le passer via un volume ou variable d’environnement.
- Adapter les chemins de montage selon la structure réelle du projet.
- Pour logs persistants, toujours monter le dossier logs en volume.
- Pour le frontend, adapter le reverse proxy (nginx, caddy) si besoin.

---

Pour plus de détails, consulter le README, la documentation technique (`docs/`), la FAQ et le plan de développement.
