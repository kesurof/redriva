# Guide de contribution Redriva

## Principes
- Forkez le dépôt, créez une branche dédiée à votre évolution ou correctif
- Respectez la structure des dossiers et la convention de nommage
- Documentez vos changements (README, changelog, commentaires)
- Ajoutez des tests pour toute nouvelle fonctionnalité ou correction
- Vérifiez le lint et la couverture de tests avant toute PR

## Processus
1. Fork & clone
2. Créez une branche (`feature/xxx` ou `fix/xxx`)
3. Développez, testez, documentez
4. Poussez votre branche et ouvrez une Pull Request
5. Décrivez clairement votre contribution et le besoin associé

## Bonnes pratiques
- Préférez des commits atomiques et explicites
- Utilisez des issues pour discuter des évolutions majeures
- Respectez le Code of Conduct


## Déploiement et automatisation

- Privilégiez Docker et Docker Compose pour tout déploiement local ou cloud.
- Toute évolution touchant au déploiement (Dockerfile, docker-compose.yml, scripts Ansible, CI/CD) doit être testée et documentée.
- Pour le cloud, ajoutez un reverse proxy (nginx/caddy) et automatisez via Ansible ou pipeline CI/CD (GitHub Actions, etc.).
- Ne commitez jamais de secrets ou de tokens sensibles (ex : RD_TOKEN) dans le dépôt.
- Documentez toute procédure de déploiement ou d’automatisation dans `docs/DEPLOIEMENT.md`.
- Vérifiez la compatibilité multi-environnements (local, Docker, cloud) avant toute PR majeure.
