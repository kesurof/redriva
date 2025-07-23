# 📖 Guide d'Utilisation Redriva

## Vue d'Ensemble

Redriva est votre tableau de bord centralisé pour gérer efficacement vos téléchargements Real-Debrid. Cette interface moderne et intuitive vous permet de contrôler tous vos téléchargements depuis une seule application.

## 🎯 Premiers Pas

### Connexion Initiale

1. **Accédez à l'interface** : http://localhost:5174 (développement) ou http://localhost:3000 (production)
2. **Authentification automatique** : Votre token Real-Debrid est configuré via les variables d'environnement
3. **Vérification de connexion** : Le statut de connexion s'affiche dans le header

### Interface Principale

L'interface Redriva est organisée en plusieurs sections principales accessibles via la navigation :

## 📊 Dashboard (`/`)

**Votre centre de contrôle principal**

### Informations Affichées
- **Statut des services** : Real-Debrid, Redis, Backend
- **Statistiques globales** : Nombre de torrents actifs, vitesse globale
- **Activité récente** : Derniers téléchargements et actions
- **Métriques système** : Utilisation CPU, RAM, stockage

### Actions Rapides
- Ajouter un nouveau torrent
- Voir les téléchargements en cours
- Accéder aux paramètres
- Monitoring en temps réel

## 🌊 Gestion des Torrents (`/torrents`)

**Centre de gestion de tous vos téléchargements**

### Liste des Torrents
- **Vue en grille** : Aperçu visuel avec miniatures
- **Vue en liste** : Informations détaillées en tableau
- **Filtres** : Par statut, taille, date, type
- **Tri** : Nom, taille, progression, vitesse

### Statuts des Torrents
- 🔄 **En attente** : Torrent ajouté, en attente de traitement
- ⬇️ **Téléchargement** : Téléchargement en cours
- ✅ **Terminé** : Téléchargement réussi
- ❌ **Erreur** : Échec du téléchargement
- ⏸️ **Suspendu** : Téléchargement mis en pause

### Actions sur les Torrents
- **Ajouter** : URL magnet, fichier .torrent, ou lien direct
- **Supprimer** : Retirer de la liste (et optionnellement du stockage)
- **Suspendre/Reprendre** : Contrôle manuel des téléchargements
- **Télécharger** : Récupérer les fichiers terminés

## 📋 Détails d'un Torrent (`/torrents/:id`)

**Informations complètes sur un téléchargement**

### Informations Générales
- **Nom** : Titre du torrent
- **Taille** : Taille totale et téléchargée
- **Progression** : Pourcentage et barre de progression
- **Vitesse** : Vitesse actuelle de téléchargement
- **ETA** : Temps estimé restant

### Informations Techniques
- **Hash** : Identifiant unique du torrent
- **Seeders/Leechers** : Nombre de sources
- **Statut Real-Debrid** : État côté service
- **Fichiers** : Liste des fichiers dans le torrent

### Actions Disponibles
- **Télécharger** : Lancer le téléchargement direct
- **Supprimer** : Retirer de Real-Debrid
- **Partager** : Obtenir des liens de partage
- **Actualiser** : Mettre à jour les informations

## ⚙️ Services (`/services`)

**Monitoring de l'infrastructure**

### Services Surveillés
- **Real-Debrid API** : Statut de connexion, quota, limites
- **Redis Cache** : État du cache, nombre de clés, mémoire
- **Base de données** : Connexion SQLite, taille, intégrité
- **Worker Queue** : Jobs en attente, en cours, terminés

### Métriques en Temps Réel
- **Performance** : Temps de réponse des APIs
- **Utilisation** : CPU, RAM, stockage
- **Réseau** : Bande passante, latence
- **Erreurs** : Logs d'erreurs récentes

## 🔧 Paramètres (`/settings`)

**Configuration de l'application**

### Préférences Générales
- **Thème** : Clair, sombre, automatique
- **Langue** : Interface utilisateur
- **Notifications** : Activer/désactiver les alertes
- **Actualisation** : Fréquence de mise à jour automatique

### Configuration Real-Debrid
- **Token** : Gestion du token d'authentification
- **Limites** : Configuration des quotas
- **Dossiers** : Organisation des téléchargements
- **Qualité** : Préférences de qualité vidéo

### Paramètres Avancés
- **Logs** : Niveau de logging, rétention
- **Cache** : Configuration Redis
- **API** : Endpoints personnalisés
- **Sécurité** : Paramètres d'authentification

## 🎮 Démonstration (`/demo`)

**Environnement de test et découverte**

### Fonctionnalités de Demo
- **Tests d'API** : Vérifier la connectivité Real-Debrid
- **Simulation** : Téléchargements fictifs pour tester l'interface
- **Benchmarks** : Tests de performance
- **Tutoriels** : Guides interactifs

## 🔧 API et Intégrations

### Endpoints Principaux

**Authentification :**
- `GET /api/auth/status` - Statut de connexion
- `POST /api/auth/refresh` - Renouveler le token

**Torrents :**
- `GET /api/torrents` - Liste des torrents
- `POST /api/torrents` - Ajouter un torrent
- `GET /api/torrents/{id}` - Détails d'un torrent
- `DELETE /api/torrents/{id}` - Supprimer un torrent

**Services :**
- `GET /api/services/status` - Statut des services
- `GET /api/services/metrics` - Métriques système

**Monitoring :**
- `GET /api/health` - Santé de l'application
- `GET /api/metrics` - Métriques Prometheus

### Format des Réponses

```json
{
  "status": "success",
  "data": {
    // Données de réponse
  },
  "message": "Description optionnelle"
}
```

### Codes d'Erreur

- `200` - Succès
- `400` - Erreur de requête
- `401` - Non autorisé
- `404` - Ressource non trouvée
- `500` - Erreur serveur

## 🔄 Workflow Typique

### Ajouter un Nouveau Torrent

1. **Accéder** à la page Torrents
2. **Cliquer** sur "Ajouter un torrent"
3. **Coller** l'URL magnet ou télécharger le fichier .torrent
4. **Valider** et attendre l'ajout à Real-Debrid
5. **Suivre** la progression depuis la liste

### Télécharger des Fichiers

1. **Attendre** que le torrent soit terminé (statut ✅)
2. **Cliquer** sur le torrent pour voir les détails
3. **Sélectionner** les fichiers à télécharger
4. **Lancer** le téléchargement direct

### Surveiller les Performances

1. **Accéder** au Dashboard pour une vue d'ensemble
2. **Consulter** la page Services pour les détails techniques
3. **Utiliser** les métriques en temps réel
4. **Ajuster** les paramètres si nécessaire

## 🔧 Dépannage Utilisateur

### Problèmes Courants

**Torrent ne s'ajoute pas :**
- Vérifiez la validité du lien magnet
- Contrôlez votre quota Real-Debrid
- Consultez les logs d'erreur

**Téléchargement lent :**
- Vérifiez votre connexion Internet
- Consultez les limites Real-Debrid
- Surveillez l'usage de bande passante

**Interface ne se charge pas :**
- Vérifiez que les services sont démarrés
- Consultez les logs : `./scripts/dev.sh logs`
- Redémarrez si nécessaire : `./scripts/dev.sh restart`

### Logs et Debugging

```bash
# Voir tous les logs
./scripts/dev.sh logs

# Logs spécifiques
./scripts/dev.sh logs frontend
./scripts/dev.sh logs backend

# Monitoring en temps réel
./scripts/dev.sh monitor
```

## 🔒 Sécurité et Confidentialité

- **Token sécurisé** : Votre token Real-Debrid est stocké localement
- **Communications chiffrées** : HTTPS en production
- **Données privées** : Aucune donnée partagée avec des tiers
- **Logs anonymes** : Pas d'informations personnelles dans les logs

## 📞 Support et Assistance

- **Documentation** : [docs/](./README.md)
- **Issues GitHub** : [Signaler un bug](https://github.com/kesurof/redriva/issues)
- **Discussions** : [Forum communautaire](https://github.com/kesurof/redriva/discussions)
- **Mise à jour** : Suivez les releases GitHub

---

🎉 **Profitez de Redriva !** Cette interface moderne rend la gestion Real-Debrid simple et efficace.
