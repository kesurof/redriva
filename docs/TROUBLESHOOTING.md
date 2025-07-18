# Dépannage Redriva

## Problèmes fréquents

### Backend
- **Le backend ne démarre pas**
  - Vérifiez la version de Python (3.10+)
  - Vérifiez que les dépendances sont installées (`pip install -r requirements.txt`)
  - Vérifiez la configuration (`config/environment.conf` ou `.env`)
  - Consultez les logs dans `logs/`

### Frontend
- **Le frontend ne démarre pas**
  - Vérifiez Node.js (18+) et npm
  - Vérifiez que les dépendances sont installées (`npm install` dans `frontend/`)
  - Vérifiez la variable `VITE_API_URL` et la connexion à l’API backend

### Docker / Docker Compose
- **Un service ne démarre pas**
  - Vérifiez la syntaxe du `docker-compose.yml`
  - Vérifiez que le fichier `config/.env` est présent et correct
  - Consultez les logs avec `docker compose logs`

### Cloud / Reverse proxy
- **L’interface web n’est pas accessible**
  - Vérifiez la configuration du reverse proxy (nginx/caddy)
  - Vérifiez les ports exposés (80/443 pour le frontend, 8000 pour l’API)
  - Vérifiez les règles de firewall/cloud

### API Real-Debrid
- **API Real-Debrid inaccessible**
  - Vérifiez la validité du token RD
  - Vérifiez la connectivité réseau
  - Consultez les logs dans `logs/`

### Tests
- **Tests qui échouent**
  - Vérifiez la configuration de test
  - Lancez les tests en mode verbeux pour plus de détails
  - Vérifiez les versions de Python, Node, dépendances

### Sécurité
- **Token ou secrets exposés**
  - Ne jamais committer de secrets dans le dépôt
  - Utilisez des variables d’environnement et `.env` non versionnés

## Logs, support & documentation
- Consultez les fichiers dans `logs/` pour diagnostiquer les erreurs
- Utilisez `docker compose logs` pour les services Docker
- Consultez la FAQ, la documentation technique (`docs/`), le README
- Ouvrez une issue sur le dépôt en cas de bug bloquant ou de question
