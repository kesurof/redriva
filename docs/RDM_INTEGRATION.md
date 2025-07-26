# Intégration RDM dans Redriva

## 🎯 **Résumé de l'Intégration**

Cette intégration s'inspire de l'architecture **Real-Debrid Manager (RDM)** pour optimiser les performances et la compatibilité avec l'API Real-Debrid, **en utilisant uniquement votre token personnel**.

## 🚀 **Améliorations Appliquées**

### **1. Client API Simplifié (Backend)**
- **Session persistante** avec User-Agent personnalisé `Redriva/1.0`
- **Pagination intelligente** : jusqu'à 1000 éléments par requête, 2500 au total
- **Gestion d'erreurs robuste** avec timeouts de 30 secondes
- **Mapping complet** des champs Real-Debrid
- **Token personnel uniquement** - pas de Client ID externe

```python
# Configuration Redriva avec token personnel
self.static_token = token  # Votre token personnel uniquement
self.max_limit_per_request = 1000
self.max_total_limit = 2500
```

### **2. Endpoints API Étendus**
- `GET /api/torrents/recent?limit=25&page=1` - Compatible existant
- `GET /api/torrents?limit=1000&page=1` - Nouveau endpoint RDM-style
- Support de **pagination multi-requêtes** automatique

### **3. Types TypeScript (Frontend)**
- **Types RDM complets** : `TorrentsResponse`, `TorrentInfoResponse`, etc.
- **Configuration centralisée** : limites API, constantes
- **Support metadata** pour extensions futures

### **4. Interface Utilisateur**
- **Sélecteur pagination** : 25, 50, 100, 250, 500, 1000 éléments
- **Rechargement intelligent** des données selon la limite
- **Tri et recherche** maintenus sur toutes les pages

## 📊 **Limites API Respectées**

| Paramètre | Limite | Source |
|-----------|--------|--------|
| **Par requête** | 1000 torrents | API Real-Debrid |
| **Total pagination** | 2500 torrents | Architecture RDM |
| **Timeout** | 30 secondes | Best practice RDM |
| **User-Agent** | `Redriva/1.0` | Style RDM |

## 🔧 **Configuration**

### **Variables d'Environnement**
```bash
# URLs de base (identiques RDM)
PUBLIC_BASE_URI="https://api.real-debrid.com/rest/1.0"
PUBLIC_BASE_AUTH_URI="https://api.real-debrid.com"
PUBLIC_CLIENT_ID="X245A4XAIBGVM"

# Limites
MAX_LIMIT_PER_REQUEST=1000
MAX_TOTAL_LIMIT=2500
```

### **Headers HTTP**
```http
Authorization: Bearer {token}
Content-Type: application/json
User-Agent: Redriva/1.0
```

## 🎪 **Exemples d'Usage**

### **Backend - Pagination Avancée**
```python
# Récupérer 1500 torrents (2 requêtes automatiques)
torrents = await rd_client.get_torrents_paginated(limit=1500, page=1)

# Validation automatique des limites
if limit > 2500:
    raise ValueError("Limit must be between 1 and 2500")
```

### **Frontend - Interface Flexible**
```typescript
// Sélecteur de pagination avec toutes les options RDM
const paginationOptions = [25, 50, 100, 250, 500, 1000];

// Rechargement intelligent selon la limite
if (newLimit > currentData.length && hasMoreData) {
    await loadTorrents(); // Recharge depuis l'API
}
```

## 📈 **Performances**

### **Avant (Simple)**
- 1 requête = max 25-100 torrents
- Pas de pagination native
- Timeout par défaut (5s)

### **Après (RDM-Style)**
- 1 requête = max 1000 torrents
- Pagination multi-requêtes automatique
- Timeout optimisé (30s)
- **10x plus de données** par chargement

## 🔄 **Compatibilité**

### **Rétrocompatible**
- ✅ Ancien endpoint `/api/torrents/recent` maintenu
- ✅ Même format de réponse JSON
- ✅ Paramètres existants préservés

### **Extensions RDM**
- ✅ Nouveau endpoint `/api/torrents` avec pagination
- ✅ Types TypeScript complets
- ✅ Configuration centralisée
- ✅ Métadonnées extensibles

## 🎯 **Prochaines Étapes**

1. **Intégration Torrentio** (déjà configuré dans `.env`)
2. **Métadonnées media** (films/séries comme RDM)
3. **Filtres avancés** par status, host, taille
4. **Cache Redis** pour optimiser les requêtes
5. **WebSocket** pour updates temps réel

L'architecture est maintenant **prête pour une montée en charge** et compatible avec l'écosystème RDM ! 🚀
