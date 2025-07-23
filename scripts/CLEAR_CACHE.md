# 🧹 Fonction Clear-Cache - Script de Développement Redriva

## Vue d'ensemble

La fonction `clear-cache` du script `dev.sh` permet d'effacer le cache Docker et de reconstruire les services sans utiliser les couches mises en cache. Cette fonction est particulièrement utile lorsque :

- Les variables d'environnement ont changé (comme les tokens d'API)
- Des problèmes de cache empêchent le bon fonctionnement
- Après modification de fichiers de configuration Docker
- Pour obtenir une version "propre" d'un service

## Syntaxe

```bash
./scripts/dev.sh clear-cache [service]
```

## Options

| Commande | Description | Équivalent Docker |
|----------|-------------|-------------------|
| `./scripts/dev.sh clear-cache` | Efface le cache du **backend** (par défaut) | `docker compose down && docker compose build --no-cache backend && docker compose up -d` |
| `./scripts/dev.sh clear-cache frontend` | Efface le cache du **frontend** | `docker compose down && docker compose build --no-cache frontend && docker compose up -d` |
| `./scripts/dev.sh clear-cache all` | Efface le cache de **tous les services** | `docker compose down && docker compose build --no-cache && docker compose up -d` |

## Exemples d'utilisation

### 1. Problème d'authentification Real-Debrid
```bash
# Après avoir modifié le token dans .env
./scripts/dev.sh clear-cache backend
```

### 2. Problème de dépendances Node.js
```bash
# Après modification du package.json
./scripts/dev.sh clear-cache frontend
```

### 3. Reset complet des caches
```bash
# Pour un environnement complètement propre
./scripts/dev.sh clear-cache all
```

## Processus détaillé

1. **Arrêt** : Tous les conteneurs sont arrêtés
2. **Reconstruction** : Le(s) service(s) spécifié(s) sont reconstruits sans cache
3. **Redémarrage** : Tous les services sont redémarrés
4. **Feedback** : Affichage des instructions d'utilisation

## Avertissements

⚠️ **Temps de construction** : La reconstruction sans cache prend plus de temps :
- Backend : ~20-30 secondes (installation des packages Python)
- Frontend : ~25-30 secondes (installation des packages npm)
- All : ~45-60 secondes (reconstruction complète)

⚠️ **Connexion réseau** : Nécessite une connexion internet pour télécharger les dépendances

## Cas d'usage courants

### Modification des variables d'environnement
```bash
# 1. Modifier le fichier .env
nano .env

# 2. Reconstruire le backend pour prendre en compte les changements
./scripts/dev.sh clear-cache backend
```

### Problème de packages npm
```bash
# Après ajout/suppression de dépendances frontend
./scripts/dev.sh clear-cache frontend
```

### Dépannage général
```bash
# Si des problèmes étranges apparaissent
./scripts/dev.sh clear-cache all
```

## Intégration dans le workflow

Cette fonction s'intègre parfaitement dans le workflow de développement Redriva :

```bash
# Développement normal
./scripts/dev.sh start

# En cas de problème : diagnostic
./scripts/dev.sh logs backend

# Solution : effacement du cache
./scripts/dev.sh clear-cache backend

# Vérification
./scripts/dev.sh status
```

## Comparaison avec les autres commandes

| Commande | Cache utilisé | Rapidité | Cas d'usage |
|----------|---------------|----------|-------------|
| `rebuild` | ✅ Oui | 🟢 Rapide | Changements de code simple |
| `clear-cache` | ❌ Non | 🟡 Moyen | Problèmes de cache, variables d'env |
| `reset` | ❌ Non | 🔴 Lent | Reset complet (dangereux) |

---

*Cette fonction respecte la philosophie "Zéro Réécriture" de Redriva en automatisant une tâche Docker courante dans le workflow de développement.*
