# 🎬 Redriva - Gestionnaire Real-Debrid Moderne (SvelteKit)

> **Tableau de bord unifié pour la gestion d'un écosystème média auto-hébergé**

Redriva est une application web moderne qui simplifie la gestion de vos téléchargements Real-Debrid avec une interface élégante et des fonctionnalités avancées de monitoring. **Maintenant avec SvelteKit !**

## ✨ Fonctionnalités

- 🎯 **Interface moderne** - SvelteKit + TailwindCSS + TypeScript
- 🔄 **Gestion des torrents** - Ajout, suivi et téléchargement automatisé
- 📊 **Monitoring en temps réel** - Métriques et statistiques intégrées
- 🔐 **Authentification sécurisée** - Intégration Real-Debrid OAuth
- 🐳 **Déploiement simplifié** - Docker avec scripts ultra-simplifiés
- ⚡ **Performance optimisée** - SvelteKit pour des performances exceptionnelles
- 🎨 **Thèmes personnalisables** - Mode sombre/clair et couleurs personnalisées

## 🚀 Migration vers SvelteKit

### Changements Majeurs
- **Frontend**: Migration complète de Vue.js vers SvelteKit
- **Performance**: Amélioration significative des temps de chargement
- **Bundle Size**: Réduction de ~40% de la taille du bundle
- **Developer Experience**: Hot reload amélioré et TypeScript natif
- **Architecture**: Composants plus simples et maintenables

### Équivalences
| Vue.js | SvelteKit |
|--------|-----------|
| `composables/` | `$lib/stores/` |
| `components/` | `$lib/components/` |
| `router/` | `routes/` (file-based routing) |
| `pinia` | `svelte/store` + `svelte-persisted-store` |
| `vuetify` | `skeleton-ui` + `tailwindcss` |

## 🚀 Démarrage Rapide

### Prérequis
- Docker et Docker Compose
- Node.js 20+ (pour le développement local)
- Token Real-Debrid ([obtenir ici](https://real-debrid.com/apitoken))

### Installation Express (Développement)

```bash
# 1. Cloner le projet
git clone https://github.com/kesurof/redriva.git
cd redriva

# 2. Configuration (optionnelle)
cp .env.example .env
# Éditer .env avec votre token Real-Debrid

# 3. Démarrage en une commande
docker compose up -d

# 4. Accès immédiat
# 🌐 Interface SvelteKit: http://localhost:5174
# 🔧 API Backend: http://localhost:8080/api
```

## 🛠️ Stack Technique

### Frontend (SvelteKit)
```
SvelteKit 2.x    → Framework full-stack moderne
TypeScript       → Typage statique
TailwindCSS 4.x  → Framework CSS utilitaire
Vite            → Build tool ultra-rapide
Vitest          → Framework de tests
```

### Backend (FastAPI)
```
FastAPI         → Framework API Python moderne
SQLite          → Base de données légère
Pydantic        → Validation des données
Uvicorn         → Serveur ASGI
```

### Architecture
```
📁 Structure Modernisée
redriva/
├── frontend/               # Application SvelteKit
│   ├── src/
│   │   ├── lib/
│   │   │   ├── components/ # Composants réutilisables
│   │   │   ├── stores/     # Gestion d'état Svelte
│   │   │   └── api/        # Services API
│   │   └── routes/         # Pages (file-based routing)
│   ├── static/             # Assets statiques
│   └── Dockerfile          # Multi-stage build
├── backend/                # API FastAPI inchangée
└── docker-compose.yml      # Orchestration des services
```

## 📱 Pages Disponibles

| Page | Route | Description |
|------|-------|-------------|
| **Dashboard** | `/` | Tableau de bord principal avec statistiques |
| **Torrents** | `/torrents` | Gestion complète des téléchargements |
| **Services** | `/services` | Monitoring des services connectés |
| **Thèmes** | `/themes` | Personnalisation interface et couleurs |
| **Paramètres** | `/settings` | Configuration et préférences |

## 🎨 Gestion des Thèmes

SvelteKit Redriva inclut un système de thèmes avancé :

- **Mode sombre/clair** - Basculement automatique ou manuel
- **12 couleurs primaires** - Palette complète personnalisable
- **Mode compact** - Interface adaptable selon les préférences
- **Persistance** - Préférences sauvegardées localement
- **CSS Variables** - Thèmes appliqués dynamiquement

## 🔧 Développement

### Commandes Frontend (SvelteKit)
```bash
cd frontend

# Développement avec hot reload
npm run dev

# Build production
npm run build

# Tests
npm run test
npm run test:watch
npm run test:coverage

# Vérification TypeScript
npm run check
npm run check:watch

# Linting et formatage
npm run lint
npm run format
```

### Commandes Docker
```bash
# Démarrage complet
docker compose up -d

# Logs en temps réel
docker compose logs -f

# Reconstruction complète
docker compose up -d --build

# Arrêt des services
docker compose down
```

## 🧪 Tests et Qualité

### Tests Frontend
```bash
# Tests unitaires (Vitest)
npm run test

# Tests de composants
npm run test:watch

# Couverture de code
npm run test:coverage

# Interface graphique des tests
npm run test:ui
```

### Qualité du Code
```bash
# Vérification TypeScript
npm run check

# Linting ESLint
npm run lint

# Formatage Prettier
npm run format
```

## 🚨 Migration depuis Vue.js

### Données Préservées
- ✅ Configuration backend inchangée
- ✅ API endpoints identiques
- ✅ Base de données compatible
- ✅ Variables d'environnement conservées
- ✅ Logique métier préservée

### Avantages SvelteKit
- 🚀 **Performance**: Bundle ~40% plus petit
- ⚡ **Vitesse**: Chargement initial 2x plus rapide
- 🛠️ **DX**: Developer Experience améliorée
- 📦 **Simplicité**: Moins de boilerplate code
- 🎯 **Modern**: Stack 2025 future-proof

## 🔒 Sécurité

- ✅ **Tokens sécurisés** - Variables d'environnement uniquement
- ✅ **Réseau isolé** - Backend inaccessible directement
- ✅ **Validation stricte** - Pydantic + TypeScript
- ✅ **CORS configuré** - Protection contre les attaques XSS
- ✅ **Headers sécurisés** - CSP et autres protections

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[Migration Guide](docs/MIGRATION_SVELTEKIT.md)** | Guide de migration Vue.js → SvelteKit |
| **[SvelteKit Guide](docs/SVELTEKIT.md)** | Guide développement SvelteKit |
| **[API Documentation](docs/API.md)** | Documentation de l'API backend |
| **[Deployment](docs/DEPLOYMENT.md)** | Guide de déploiement production |

## 🤝 Contribution

Les contributions sont bienvenues ! Le passage à SvelteKit offre de nouvelles opportunités d'amélioration.

### Workflow de Contribution
1. Fork du projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Développer avec `docker compose up -d`
4. Tester avec `npm run test`
5. Commit (`git commit -m 'Add AmazingFeature'`)
6. Push (`git push origin feature/AmazingFeature`)
7. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🌟 Remerciements

- **[SvelteKit](https://kit.svelte.dev/)** - Framework full-stack moderne
- **[TailwindCSS](https://tailwindcss.com/)** - Framework CSS utilitaire
- **[TypeScript](https://www.typescriptlang.org/)** - JavaScript avec types
- **[Vite](https://vitejs.dev/)** - Build tool ultra-rapide
- **[Real-Debrid](https://real-debrid.com/)** - Service de téléchargement premium
- **[FastAPI](https://fastapi.tiangolo.com/)** - Framework API moderne

---

<div align="center">

**Redriva 2.0** - *Maintenant avec SvelteKit pour des performances exceptionnelles*

[🌐 Site Web](https://github.com/kesurof/redriva) • [📖 Documentation](docs/) • [🐛 Issues](https://github.com/kesurof/redriva/issues) • [💬 Discussions](https://github.com/kesurof/redriva/discussions)

</div>
