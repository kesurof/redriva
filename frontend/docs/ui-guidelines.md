# UI Guidelines Redriva

## Principes généraux
- Utiliser TailwindCSS pour toute la mise en page et les couleurs.
- Préférer les composants réutilisables (Table, Modal, Loader, Notification, Toast).
- Toujours prévoir un état de chargement et un état vide.
- Respecter l’accessibilité (focus, aria, contrastes, navigation clavier).
- Internationaliser toutes les chaînes (svelte-i18n).
- Responsive design : mobile, tablette, desktop.
- Dark mode activable (switch dans le header).

## Structure des pages
- Navigation principale dans le header (Torrents, Downloads, Scraper, Settings).
- Layout global dans `+layout.svelte` : header, main, footer.
- Chaque page peut afficher des toasts pour feedback utilisateur.

## Composants UI
- `Table.svelte` : affichage des listes, supporte actions (suppression, clic ligne).
- `Modal.svelte` : modale réutilisable pour formulaires ou détails.
- `Loader.svelte` : indicateur de chargement contextuel.
- `Notification.svelte` : feedback en haut à droite, fermable.
- `Toast.svelte` : feedback contextuel en bas à droite, auto-disparition.

## Bonnes pratiques
- Utiliser des props explicites pour chaque composant.
- Gérer les erreurs et loaders à chaque appel API.
- Utiliser les toasts pour toute action utilisateur (succès, erreur).
- Documenter chaque nouveau composant dans ce fichier.

## Exemples d’intégration

```svelte
<!-- Exemple Table avec suppression -->
<Table {columns} rows={torrents} onDelete={deleteTorrent} on:rowClick={e => openDetail(e.detail)} />

<!-- Exemple Toast -->
<Toast message={toastMsg} type={toastType} onClose={() => showToast = false} duration={2500} />
```

## Convention de nommage
- Composants : PascalCase
- Props : camelCase
- Fichiers : kebab-case ou PascalCase selon usage Svelte

## Accessibilité
- Utiliser les rôles ARIA sur les notifications, modales, boutons.
- Tester la navigation clavier et le contraste des couleurs.

---

Pour toute contribution UI, se référer à ce guide et enrichir la documentation au fil des évolutions.
