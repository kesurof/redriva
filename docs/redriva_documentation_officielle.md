# REDRIVA — Documentation Officielle

Cette documentation décrit **l’installation**, la **mise à jour** et le **workflow d’administration quotidien** de REDRIVA.

REDRIVA est un **outil d’administration serveur** conçu pour la maintenance long terme, la rejouabilité et la lisibilité. Il n’est **pas** un script d’installation jetable.

---

## 1. Installation

### 1.1 Pré-requis

- Système Linux (Debian/Ubuntu recommandés)
- Accès réseau sortant (GitHub)
- Un utilisateur avec accès `sudo`
- Aucun prérequis logiciel spécifique (Docker, SSH, etc. seront gérés par REDRIVA)

---

### 1.2 Installation initiale (serveur vierge)

L’installation officielle se fait **directement dans `/opt/redriva`**.

```bash
git clone https://github.com/kesurof/redriva.git /opt/redriva
cd /opt/redriva
sudo ./redriva action redriva_install
```

Cette action :
- installe REDRIVA comme **outil système**
- installe le lanceur global `/usr/local/bin/redriva`
- ne modifie **aucune donnée applicative**

Une fois terminée :

```bash
redriva menu
```

---

### 1.3 Réinstallation / migration

Si `/opt/redriva` existe déjà mais n’est pas un dépôt Git valide, REDRIVA :
- détecte la situation
- demande confirmation explicite
- propose une réinstallation propre

Aucune suppression n’est faite sans validation utilisateur.

---

## 2. Mise à jour

### 2.1 Principe

REDRIVA se met à jour **exclusivement via une action dédiée**.

❌ Pas de `git pull` manuel
❌ Pas de script externe
❌ Pas de mise à jour silencieuse

✅ Une seule commande officielle

---

### 2.2 Mise à jour standard

```bash
redriva action redriva_update
```

Cette action :
- travaille uniquement dans `/opt/redriva`
- vérifie la branche `main`
- compare la version locale et distante
- applique un `git pull --ff-only` si nécessaire
- ne touche **ni aux applications**, **ni aux données hôte**

---

### 2.3 Sécurité Git (ownership)

Le dépôt `/opt/redriva` appartient à `root`. Git peut afficher un avertissement si un utilisateur non-root tente une commande Git manuelle.

C’est un comportement normal et souhaité.

👉 Toute opération Git doit passer par :

```bash
redriva action redriva_update
```

---

## 3. Workflow administrateur

### 3.1 Philosophie

REDRIVA est conçu pour :
- un administrateur fatigué
- une utilisation occasionnelle
- une maintenance sur plusieurs années

Tout passe par le menu ou des actions explicites.

---

### 3.2 Menu principal

```bash
redriva menu
```

Le menu :
- est généré automatiquement
- scanne le dossier `actions/`
- ne nécessite aucune maintenance manuelle

Ajouter une action = elle apparaît automatiquement.

---

### 3.3 Exécuter une action

```bash
redriva action <nom_action>
```

Exemples :
- `redriva action cloudflare_configure`
- `redriva action ssh_check_keys`
- `redriva action app_deploy`

Toutes les actions :
- sont rejouables
- affichent clairement leurs effets
- demandent confirmation si nécessaire

---

### 3.4 Déploiement applicatif

- Les templates applicatifs sont stockés dans `apps/`
- Les applications sont déployées dans `/opt/docker/<app>`
- REDRIVA ne vit **jamais** dans `/opt/docker`

Flux standard :

```bash
redriva action app_deploy
```

---

### 3.5 Séparation des responsabilités

| Élément | Emplacement |
|------|------|
| REDRIVA (outil) | `/opt/redriva` |
| Lanceur | `/usr/local/bin/redriva` |
| Applications | `/opt/docker/<app>` |
| Données hôte | `/opt/docker` |

---

## 4. Bonnes pratiques

- Toujours utiliser `redriva action ...`
- Ne jamais modifier `/opt/redriva` manuellement
- Ne jamais lancer Git directement dans `/opt/redriva`
- Versionner uniquement depuis l’environnement de développement

---

## 5. Conclusion

REDRIVA est maintenant :
- installable proprement
- maintenable dans le temps
- extensible sans dette technique
- sûr pour un serveur réel

Ce document constitue la **référence officielle** d’utilisation.

