# Configuration Real-Debrid

## Configuration de l'API Token

1. **Obtenir votre token Real-Debrid :**
   - Connectez-vous à votre compte Real-Debrid
   - Allez dans "Mon Compte" > "API"
   - Générez un nouveau token API

2. **Configurer le token :**
   - Ouvrez le fichier `.env` à la racine du projet
   - Remplacez `VOTRE_VRAIE_CLE_API_ICI` par votre vrai token
   ```
   REALDEBRID_API_TOKEN="votre_token_reel_ici"
   ```

3. **Redémarrer l'application :**
   ```bash
   docker compose down
   docker compose up --build -d
   ```

## Vérification

Une fois configuré, l'application devrait afficher vos vrais torrents Real-Debrid sur la page `/torrents`.

## Sécurité

- Ne jamais commiter le fichier `.env` avec votre vrai token
- Le fichier `.env` est déjà dans `.gitignore`
- En production, utilisez des variables d'environnement sécurisées
