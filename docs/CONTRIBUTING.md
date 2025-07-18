# Guide de contribution Redriva

## Principes généraux
- Travaillez sur une branche dédiée (`feature/xxx` ou `fix/xxx`)
- Respectez la structure des dossiers et la convention de nommage
- Documentez vos changements (README, changelog, commentaires)
- Ajoutez des tests pour toute nouvelle fonctionnalité ou correction
- Vérifiez le lint et la couverture de tests avant toute PR

## Processus de contribution
1. Forkez le dépôt et clonez-le localement
2. Créez une branche dédiée (`feature/xxx` ou `fix/xxx`)
3. Développez, testez, documentez vos modifications
4. Poussez votre branche et ouvrez une Pull Request (PR)
5. Décrivez clairement votre contribution, le besoin associé et les impacts éventuels

## Bonnes pratiques
- Commits atomiques et messages explicites
- Utilisez des issues pour discuter des évolutions majeures ou des bugs
- Respectez le Code of Conduct du projet
- Ajoutez des tests unitaires et E2E pour toute nouvelle fonctionnalité
- Vérifiez la compatibilité multi-environnements (local, Docker, cloud)

## Déploiement, maintenance et debug
- Privilégiez Docker et Docker Compose pour tout déploiement local ou cloud
- Toute évolution touchant au déploiement (Dockerfile, docker-compose.yml, scripts Ansible, CI/CD) doit être testée et documentée dans `docs/DEPLOIEMENT.md`
- Pour le cloud, ajoutez un reverse proxy (nginx/caddy) et automatisez via Ansible ou pipeline CI/CD (GitHub Actions, etc.)
- Pour la maintenance, vérifiez les logs (`logs/` ou `docker compose logs`), la persistance des données (`data/`), et la sécurité des accès
- Pour le debug, consultez la FAQ, les logs, et ouvrez une issue si besoin

## Ajout de fonctionnalités
- Proposez d’abord une issue pour discuter des évolutions majeures
- Respectez la structure du code et la logique existante
- Ajoutez systématiquement des tests et de la documentation
- Décrivez l’impact de la fonctionnalité sur le déploiement, la sécurité et la maintenance

## Sécurité
- Ne commitez jamais de secrets ou de tokens sensibles (ex : RD_TOKEN) dans le dépôt
- Utilisez des variables d’environnement et des fichiers `.env` non versionnés
- Documentez toute procédure de déploiement ou d’automatisation

## Support
- Consultez la documentation technique et la FAQ dans `docs/`
- Ouvrez une issue pour toute question, bug ou suggestion
