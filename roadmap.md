Voici une checklist détaillée pour la mise à jour et la conformité de l’ensemble du projet Redriva avec la stack :

Svelte 5.34.0
SvelteKit ^2.22.2
Vite ^7.0.0
@sveltejs/adapter-auto ^3.2.0
@sveltejs/vite-plugin-svelte ^3.0.0
1. Frontend SvelteKit
<input disabled="" type="checkbox"> package.json
<input checked="" disabled="" type="checkbox"> Dépendances à jour (voir extrait ci-dessus)
<input disabled="" type="checkbox"> Pas de commentaires ou de syntaxe non-JSON
<input disabled="" type="checkbox"> Un seul adaptateur dans devDependencies (adapter-auto ou adapter-static, pas les deux)
<input disabled="" type="checkbox"> svelte.config.js
<input checked="" disabled="" type="checkbox"> Utilise bien @sveltejs/adapter-auto (ou adapter-static si besoin)
<input disabled="" type="checkbox"> Pas d’utilisation de require, uniquement import
<input disabled="" type="checkbox"> Alias corrects pour $lib, $components, etc.
<input disabled="" type="checkbox"> vite.config.js
<input disabled="" type="checkbox"> Utilise sveltekit() comme plugin principal
<input disabled="" type="checkbox"> Compatible Vite 7 (aucun plugin obsolète)
<input disabled="" type="checkbox"> Compatibilité Svelte 5
<input disabled="" type="checkbox"> Pas d’utilisation de runes non supportées ou de syntaxe Svelte 3/4 obsolète
<input disabled="" type="checkbox"> Stores ($t, $locale, etc.) utilisés uniquement au top-level ou via variables réactives
<input disabled="" type="checkbox"> Tous les imports sont en ES modules
<input disabled="" type="checkbox"> i18n
<input disabled="" type="checkbox"> Toutes les chaînes UI sont internationalisées
<input disabled="" type="checkbox"> Les usages de $t dans les templates sont extraits dans des variables réactives si utilisés dans des boucles ou props
<input disabled="" type="checkbox"> Accessibilité
<input disabled="" type="checkbox"> Tous les <label> sont associés à un <input> via for/id
<input disabled="" type="checkbox"> Navigation clavier et contrastes vérifiés
<input disabled="" type="checkbox"> UI/UX
<input disabled="" type="checkbox"> Feedback utilisateur systématique (toasts, loaders, erreurs)
<input disabled="" type="checkbox"> Responsive design (mobile/tablette/desktop)
<input disabled="" type="checkbox"> Mode sombre/clair fonctionnel
<input disabled="" type="checkbox"> Tests
<input disabled="" type="checkbox"> Outils de test compatibles Svelte 5/Vite 7 (Playwright, Vitest, etc.)
<input disabled="" type="checkbox"> Snapshots mis à jour si besoin
<input disabled="" type="checkbox"> Scripts NPM
<input checked="" disabled="" type="checkbox"> "dev": "vite dev", "build": "vite build", "preview": "vite preview"
2. Backend (FastAPI/Python)
<input disabled="" type="checkbox"> API
<input disabled="" type="checkbox"> Endpoints /api/* compatibles avec le frontend (format de réponse, CORS)
<input disabled="" type="checkbox"> Token Real-Debrid stocké côté serveur uniquement
<input disabled="" type="checkbox"> Rate limiting et logs d’accès en place
<input disabled="" type="checkbox"> Base de données
<input disabled="" type="checkbox"> Schéma SQLite à jour (torrents, détails, logs…)
<input disabled="" type="checkbox"> Scripts d’initialisation et de migration présents
<input disabled="" type="checkbox"> Sécurité
<input disabled="" type="checkbox"> Pas d’exposition du token RD côté client
<input disabled="" type="checkbox"> Validation des entrées sur tous les endpoints
<input disabled="" type="checkbox"> Tests backend
<input disabled="" type="checkbox"> Tests unitaires et d’intégration présents et à jour
3. Docker / CI/CD
<input disabled="" type="checkbox"> Dockerfile frontend
<input checked="" disabled="" type="checkbox"> Build et preview natif SvelteKit/Vite 7
<input disabled="" type="checkbox"> Pas de dépendance à un dossier /build statique (sauf si adapter-static)
<input disabled="" type="checkbox"> Port exposé : 4173
<input disabled="" type="checkbox"> Dockerfile backend
<input disabled="" type="checkbox"> Utilise Python 3.10+, requirements.txt à jour
<input disabled="" type="checkbox"> Volumes pour data et logs
<input disabled="" type="checkbox"> docker-compose.yml
<input disabled="" type="checkbox"> Services frontend et backend bien définis, ports exposés
<input disabled="" type="checkbox"> Variables d’environnement sécurisées (token RD, etc.)
<input disabled="" type="checkbox"> CI/CD
<input disabled="" type="checkbox"> Jobs qui buildent et testent le frontend et le backend
<input disabled="" type="checkbox"> Badge de build et de couverture dans le README
4. Documentation
<input disabled="" type="checkbox"> README.md
<input disabled="" type="checkbox"> Instructions à jour (install, build, usage, contribution)
<input disabled="" type="checkbox"> Prérequis (Node 18+, Python 3.10+, Docker)
<input disabled="" type="checkbox"> Exemples d’appels API, captures d’écran
<input disabled="" type="checkbox"> INSTALL.md / USAGE.md
<input disabled="" type="checkbox"> Guides d’installation et d’utilisation à jour
<input disabled="" type="checkbox"> CONTRIBUTING.md
<input disabled="" type="checkbox"> Bonnes pratiques, conventions, stratégie de tests
<input disabled="" type="checkbox"> Troubleshooting/FAQ
<input disabled="" type="checkbox"> Section dédiée dans la doc
5. Qualité, sécurité, maintenance
<input disabled="" type="checkbox"> Audit de dépendances
<input disabled="" type="checkbox"> Utilisation de npm audit, pip-audit ou équivalent
<input disabled="" type="checkbox"> Scripts de maintenance
<input disabled="" type="checkbox"> Backup, purge, migration présents dans scripts
<input disabled="" type="checkbox"> Logs
<input disabled="" type="checkbox"> Logs structurés, rotation, monitoring (Sentry ou équivalent)
<input disabled="" type="checkbox"> Accessibilité
<input disabled="" type="checkbox"> Respect des standards WCAG, navigation clavier testée
6. Internationalisation et évolutivité
<input disabled="" type="checkbox"> i18n
<input disabled="" type="checkbox"> Architecture prête pour plusieurs langues
<input disabled="" type="checkbox"> Fichiers de traduction complets
<input disabled="" type="checkbox"> Modularité
<input disabled="" type="checkbox"> Possibilité d’ajouter d’autres services (débrideurs, stockage cloud)
<input disabled="" type="checkbox"> Plugins/modules pour scrapers, parsers, etc.
7. Scripts et automatisation
<input disabled="" type="checkbox"> Scripts d’inventaire et de sync
<input disabled="" type="checkbox"> Scripts Python pour synchroniser les torrents RD → SQLite
<input disabled="" type="checkbox"> Activation automatique du venv, logs, gestion des interruptions
<input disabled="" type="checkbox"> Unités systemd
<input disabled="" type="checkbox"> Fichiers .service pour exécution utilisateur, arrêt propre
Remarque :
Chaque point de cette checklist est issu des instructions projet, des contraintes techniques et des bonnes pratiques modernes (voir vos fichiers d’instructions).
Pour chaque case non cochée, je peux générer le code, la doc ou le script correspondant sur demande.