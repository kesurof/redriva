Parfait.
Voici un **README fondateur**, volontairement **clair, sobre et structurant**, qui pose l’identité de **REDRIVA** pour les années à venir.
Tu peux le poser tel quel comme `README.md` à la racine du repo.

---

# REDRIVA

**REDRIVA** est un **orchestrateur d’actions d’administration serveur**, modulaire, relançable et maintenable dans le temps.

Il permet de **configurer, maintenir et faire évoluer un serveur Linux** à travers des **actions unitaires**, exécutables à la demande, sans dépendre d’un parcours figé ou d’un script monolithique.

---

## 🎯 Objectifs du projet

REDRIVA vise à :

* Administrer un serveur **dans la durée**, pas uniquement à l’installation
* Remplacer les scripts “one-shot” par des **actions rejouables**
* Centraliser la configuration système, réseau et applicative
* Réduire la dette technique et l’effet “script oublié”
* Offrir une **interface simple** (menu) pour l’exploitation quotidienne

---

## 🧠 Philosophie

### REDRIVA n’est PAS

* Un script d’installation jetable
* Un bootstrap linéaire
* Un framework opaque ou magique
* Un outil figé dans un état initial

### REDRIVA EST

* Un **socle d’actions unitaires**
* Un outil **toujours relançable**
* Une base **lisible, explicite et auditable**
* Un projet orienté **maintenance long terme**
* Un **orchestrateur**, pas un remplaçant à Docker, systemd ou Ansible

---

## 🧩 Concept clé : l’action

Dans REDRIVA, **tout est une action**.

Une action :

* Fait **une seule chose**
* Peut être exécutée indépendamment
* Peut être rejouée sans effet de bord
* Ne dépend pas d’un “ordre global”

Exemples :

* Configurer un DNS Cloudflare
* Sécuriser SSH
* Déployer Traefik
* Mettre à jour un outil interne
* Recharger une configuration

---

## 🗂️ Architecture du projet

```text
redriva/
├── redriva               # CLI principal
├── README.md
│
├── core/                 # Fondations (UI, config, checks)
│
├── modules/              # Logique métier par domaine
│   ├── cloudflare/
│   ├── ssh/
│   ├── users/
│   ├── docker/
│   ├── traefik/
│   └── redriva/
│
├── actions/              # Actions unitaires exécutables
│
├── menus/                # Menus déclaratifs
│
└── profiles/             # (optionnel) presets de serveur
```

### Séparation stricte des responsabilités

* **core/**
  Fonctions fondamentales partagées (UI, config, validations)
  - loader
    👉 Charge le core
    👉 Gère menus & actions
    👉 Aucune logique métier

* **modules/**
  Logique métier pure, sans orchestration globale

* **actions/**
  Scripts courts, explicites, rejouables

* **menus/**
  Interface utilisateur déclarative (aucune logique)

---

## 🧭 Interface utilisateur

REDRIVA propose une interface simple :

```bash
redriva menu
```

Le menu :

* Liste les actions disponibles
* Les classe par domaine
* Permet d’exécuter une action sans connaître sa structure interne

Aucune modification de code n’est nécessaire pour maintenir le menu.

---

## 🔐 Configuration persistante

REDRIVA utilise une configuration persistante locale :

* Centralisée
* Hors dépôt Git
* Réutilisée automatiquement
* Modifiable uniquement avec confirmation

Les secrets ne sont jamais affichés en clair.

---

## 🔁 Rejouabilité et sécurité

* Les actions sont conçues pour être **idempotentes**
* Aucune destruction sans confirmation explicite
* Aucune dépendance implicite à un “ordre d’exécution”
* Chaque action peut être relancée après une mise à jour, un incident ou un redémarrage serveur

---

## 🛠️ Cas d’usage typiques

* Installation initiale d’un serveur
* Reconfiguration partielle (DNS, SSH, proxy)
* Maintenance récurrente
* Ajout progressif de services
* Réparation après incident
* Reprise sur serveur existant

---

## 📌 Principes directeurs

* Simplicité > sophistication
* Lisibilité > abstraction
* Actions unitaires > scripts globaux
* Maintenance > installation
* Transparence totale

---

## 🛣️ Évolutions prévues

* Enrichissement progressif des modules
* Menus contextuels
* Profils de serveur optionnels
* Outils de diagnostic
* Vérifications de conformité

---

## ⚠️ Note importante

REDRIVA n’impose **aucune architecture applicative**.
Il ne remplace ni Docker Compose, ni systemd, ni les outils standards du système.

Il **orchestré ce qui existe**, sans le masquer.

---

## ✨ En résumé

REDRIVA est un outil pour les admins qui veulent :

> **reprendre le contrôle de leur serveur, aujourd’hui comme demain.**

---
