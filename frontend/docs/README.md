# Documentation Redriva Frontend

## Structure de la documentation

- `ui-guidelines.md` : Bonnes pratiques UI, accessibilité, intégration Tailwind, conventions de nommage, exemples de composants.
- `i18n.md` : Internationalisation, gestion des fichiers de langue, bonnes pratiques svelte-i18n.
- `README.md` (ce fichier) : Vue d’ensemble, installation, scripts, architecture, liens utiles.

## Installation

```bash
cd frontend
npm install
npm run dev
```

## Scripts principaux
- `npm run dev` : Démarrage en mode développement (localhost:5173)
- `npm run build` : Build de production
- `npm run preview` : Preview du build (localhost:4173)

## Architecture
- `src/` : Code source SvelteKit
- `src/lib/components/ui/` : Composants UI réutilisables
- `src/locales/` : Fichiers de traduction i18n
- `docs/` : Documentation interne

## Liens utiles
- [UI Guidelines](./ui-guidelines.md)
- [Guide i18n](./i18n.md)

---
Pour toute contribution, merci de documenter les nouveaux composants, pages ou patterns dans ce dossier.
