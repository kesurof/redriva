# File d’attente et gestion des priorités Redriva

## Principe
Gérez l’ordre de traitement des torrents (priorité, statut), limitez le nombre de téléchargements simultanés et suivez l’avancement de chaque job via une file d’attente centralisée.

## Backend
- Table SQLite `queue` : id, torrent_id, priority, status, added_at, updated_at
- Endpoints REST :
  - `GET /api/queue` : liste la file d’attente
  - `POST /api/queue` : ajoute un torrent à la file
  - `PATCH /api/queue/{id}` : modifie la priorité ou le statut
  - `DELETE /api/queue/{id}` : supprime un job de la file
- Script `backend/queue_worker.py` : lance les jobs selon la priorité, limite à N actifs, met à jour le statut

## Frontend
- Page `/queue` :
  - Affiche la file d’attente (table interactive)
  - Ajout d’un torrent par ID
  - Modification de la priorité (▲/▼)
  - Suppression d’un job
  - Rafraîchissement automatique toutes les 5 s (polling)
- Feedbacks visuels (chargement, erreurs, notifications)

## Déploiement & maintenance
- Fonctionne en local, Docker Compose ou cloud (voir `docs/DEPLOIEMENT.md`)
- Les logs et l’état de la file sont persistés (`logs/`, `data/`)
- Pour debug : consultez les logs, vérifiez la connectivité API RD, utilisez les endpoints REST

## Cas d’usage
- Prioriser un téléchargement urgent
- Mettre en pause ou relancer un job
- Suivre l’avancement de la file
- Nettoyer les jobs terminés ou en erreur

## Limites & évolutions
- Pour la démo, le worker simule un téléchargement (remplacer par appel réel à l’API RD)
- Ajouter la gestion du statut « pause », la relance, le bulk delete
- Améliorer la synchronisation (websocket, notifications temps réel)

## Exemples d’appels API

```bash
# Ajouter un torrent à la file
curl -X POST -H "Content-Type: application/json" -d '{"torrent_id": "abc123"}' http://localhost:8000/api/queue

# Modifier la priorité
curl -X PATCH -H "Content-Type: application/json" -d '{"priority": 1}' http://localhost:8000/api/queue/1

# Supprimer un job
curl -X DELETE http://localhost:8000/api/queue/1
```

## Sécurité
- Le token Real-Debrid n’est jamais exposé côté client
- Les accès API sont protégés côté backend (rate limiting, logs)

## FAQ
- **Comment voir la file ?**
  - Aller sur la page « File d’attente » du frontend
- **Comment changer la priorité ?**
  - Utiliser les boutons ▲/▼ sur la ligne du job
- **Combien de jobs actifs ?**
  - Limite fixée dans `queue_worker.py` (MAX_ACTIVE)

---

Pour toute question, voir la documentation principale (`docs/`), la FAQ ou ouvrir une issue sur GitHub.
