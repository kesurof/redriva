# REDRIVA

REDRIVA est un **outil d’administration serveur** pensé pour la vraie vie :
serveurs qui durent, configurations qui évoluent, admins fatigués à 23h.

Ce n’est **pas** un script d’installation jetable.
Ce n’est **pas** un framework magique.

REDRIVA est un **orchestrateur d’actions** : clair, relançable, maintenable.

---

## ✨ Pourquoi REDRIVA ?

Avec le temps, les serveurs accumulent :
- des scripts oubliés
- des commandes copiées/collées
- des procédures non documentées

REDRIVA apporte une réponse simple :

> **Tout ce qui est fait sur le serveur doit être rejouable, lisible et explicite.**

Une action = une responsabilité.

---

## 🧱 Philosophie

- 🔁 **Rejouable** — une action peut être relancée sans casser l’existant
- 📖 **Lisible** — pas besoin de connaître le projet pour l’utiliser
- 🧠 **Prévisible** — aucun effet de bord implicite
- 🛠️ **Maintenance > installation**
- ❌ **Zéro magie**

REDRIVA est conçu pour rester utilisable **dans plusieurs années**.

---

## 📂 Architecture

```
/opt/redriva          → outil REDRIVA (code)
/usr/local/bin/redriva → lanceur système
/opt/docker/*         → applications & données hôte
```

Les rôles sont volontairement séparés.

---

## 🚀 Installation (serveur vierge)

```bash
git clone https://github.com/kesurof/redriva.git /opt/redriva
cd /opt/redriva
sudo ./redriva action redriva_install
```

Puis simplement :

```bash
redriva menu
```

---

## 🔄 Mise à jour

REDRIVA se met à jour **depuis lui-même**.

```bash
redriva action redriva_update
```

- pas de `git pull` manuel
- pas de script externe
- aucune application impactée

---

## 🧭 Utilisation quotidienne

### Menu interactif

```bash
redriva menu
```

Le menu est généré automatiquement à partir des actions disponibles.

Ajouter une action = elle apparaît immédiatement.

---

### Exécuter une action

```bash
redriva action <nom_action>
```

Exemples :
- `ssh_check_keys`
- `cloudflare_configure`
- `app_deploy`

Chaque action annonce clairement ce qu’elle va faire.

---

## 📦 Applications

- Les templates vivent dans `apps/`
- Les applications sont déployées dans `/opt/docker/<app>`
- REDRIVA ne mélange **jamais** outil et données

```bash
redriva action app_deploy
```

---

## 🔐 Sécurité & confiance

- REDRIVA s’exécute en root
- le contrôle des privilèges est centralisé
- aucune action cachée
- aucune modification silencieuse

Si REDRIVA fait quelque chose, **tu le vois**.

---

## 🧠 À qui s’adresse REDRIVA ?

- admins système
- auto-hébergeurs sérieux
- environnements cloud long terme
- personnes qui veulent **reprendre la main** sur leurs serveurs

---

## 🏁 En résumé

REDRIVA est :
- un outil d’administration durable
- un socle de confiance
- une alternative saine aux scripts jetables

Si tu gères un serveur **dans la durée**, REDRIVA est fait pour toi.

---

👉 Documentation complète : voir le dossier `docs/` (ou le wiki GitHub)

