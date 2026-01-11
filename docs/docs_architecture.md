# REDRIVA — Architecture

Ce document décrit l’architecture interne de REDRIVA.

Il s’adresse aux **mainteneurs**, **contributeurs** et aux administrateurs curieux qui veulent comprendre *comment* et *pourquoi* REDRIVA fonctionne ainsi.

Ce n’est **pas** un guide utilisateur.

---

## 🎯 Objectif architectural

REDRIVA est conçu pour :

- durer dans le temps
- être relançable sans risque
- rester compréhensible après plusieurs mois
- éviter toute magie implicite

L’architecture privilégie :

> **Lisibilité > abstraction**  
> **Maintenance > installation**

---

## 🧱 Vue d’ensemble

REDRIVA est structuré autour d’un principe simple :

> **Séparer strictement le code, la logique métier et les effets système**

Structure globale :

```
redriva/
├── redriva          # point d’entrée (dispatcher)
├── core/            # fondations (UI, loader, checks)
├── modules/         # logique métier pure
├── actions/         # scripts effecteurs unitaires
├── menus/           # déclaratif (si présent)
├── apps/            # templates applicatifs
└── docs/            # documentation
```

Chaque dossier a un rôle **non négociable**.

---

## 🚪 Point d’entrée : `redriva`

Le fichier `redriva` est le **seul point d’entrée**.

Responsabilités :
- auto-élévation root
- chargement du core
- dispatch des commandes (`menu`, `action`, `list`)

Il ne contient **aucune logique métier**.

---

## ⚙️ `core/` — Fondations

Le dossier `core/` contient uniquement :

- UI (affichage, messages)
- checks globaux
- loader des composants
- configuration

### Règles strictes

- ❌ aucun effet système au `source`
- ❌ aucune création de fichier implicite
- ❌ aucune dépendance vers `modules/` ou `actions/`

Le core est **passif** : il fournit des outils, jamais des actions.

---

## 🧠 `modules/` — Logique métier

Les modules contiennent **exclusivement des fonctions**.

Caractéristiques :
- pas d’exécution directe
- pas d’interaction utilisateur
- pas de `exit`
- pas de `sudo`

Un module doit être :
- réutilisable
- testable
- prédictible

👉 Un module ne fait **rien** tout seul.

---

## ⚡ `actions/` — Actions effectrices

Une action est un **script court à responsabilité unique**.

Caractéristiques :
- peut modifier le système
- peut afficher des messages
- peut appeler plusieurs modules
- doit être rejouable

### Règles clés

- ❌ aucune logique de menu
- ❌ aucun ordre d’exécution implicite
- ❌ aucune dépendance à une autre action

👉 Chaque action doit pouvoir être lancée **isolément**.

---

## 📦 `apps/` — Applications

Le dossier `apps/` contient :

- des templates versionnés
- des fichiers `.tpl`
- des `app.conf`

Les applications sont :
- préparées par REDRIVA
- déployées dans `/opt/docker/<app>`

REDRIVA **ne vit jamais** dans `/opt/docker`.

---

## 🧭 Menu dynamique

Le menu REDRIVA est **entièrement dynamique**.

Principe :
- scan automatique du dossier `actions/`
- aucune entrée codée en dur
- aucune maintenance manuelle

Ajouter une action = elle apparaît dans le menu.

---

## 🔄 Cycle de vie

### Installation

- clonage Git dans `/opt/redriva`
- installation du lanceur `/usr/local/bin/redriva`

### Mise à jour

- action dédiée `redriva_update`
- `git pull --ff-only`
- aucun impact applicatif

### Exécution

- toujours via le lanceur
- toujours en root

---

## 🔐 Sécurité

Principes appliqués :

- exécution root centralisée
- aucune escalade locale (`sudo` dans les actions)
- confirmations explicites pour actions critiques
- séparation outil / données

Si REDRIVA fait quelque chose, **c’est visible**.

---

## 🧠 Philosophie de contribution

Avant d’ajouter du code, se poser la question :

> « Est-ce que cela rend REDRIVA plus simple à maintenir dans 2 ans ? »

Si la réponse est non, la modification est probablement incorrecte.

---

## 🏁 Conclusion

REDRIVA n’est pas un framework.

C’est un **outil d’administration durable**, volontairement strict, conçu pour :

- réduire la dette mentale
- éviter les scripts oubliés
- rendre l’état du serveur explicite

Ce document constitue la **référence architecturale officielle** de REDRIVA.

