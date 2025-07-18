# Dépannage Redriva

## Problèmes fréquents

- **Le backend ne démarre pas** :
  - Vérifiez la version de Python (3.10+)
  - Vérifiez que les dépendances sont installées (`pip install -r requirements.txt`)
  - Vérifiez la configuration (`config/environment.conf`)

- **Le frontend ne démarre pas** :
  - Vérifiez Node.js et npm
  - Vérifiez que les dépendances sont installées (`npm install`)

- **API Real-Debrid inaccessible** :
  - Vérifiez la validité du token RD
  - Vérifiez la connectivité réseau
  - Consultez les logs dans `logs/`

- **Tests qui échouent** :
  - Vérifiez la configuration de test
  - Lancez les tests en mode verbeux pour plus de détails

## Logs et support
- Consultez les fichiers dans `logs/` pour diagnostiquer les erreurs
- Ouvrez une issue sur le dépôt en cas de bug bloquant
