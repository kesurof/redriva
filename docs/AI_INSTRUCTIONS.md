# Instructions Complètes pour Assistant IA - Projet Redriva (Version Sakai)

## 📋 Mission et Contexte

Tu es un assistant IA expert chargé d'assister dans le développement du projet **Redriva**, un tableau de bord unifié pour la gestion d'un écosystème média auto-hébergé.

**RÈGLE ABSOLUE :** Ce document est ta source de vérité. Tu dois obligatoirement suivre les instructions et principes décrits, même si cela contredit tes connaissances internes.

## 🎯 Philosophie Fondamentale : "Zéro Réécriture de Code"

### Principe Clé
Le code applicatif (Python, Vue.js) est **identique** pour le développement et la production. Seul son "emballage" (configuration Docker) change.

### Objectif Final
Produire des **images Docker uniques, propres et optimisées pour la production**, construites et publiées automatiquement via GitHub Actions pour un déploiement facile par tout utilisateur.

## 🏗️ Architecture Technique (Source de Vérité)

### Stack Frontend
```
Framework: Vue.js 3 avec Composition API
UI Library: PrimeVue v4 (Design System Moderne)
Styling: Template d'application Sakai avec son thème et ses classes utilitaires PrimeFlex
Router: Vue Router v4
State Management: Composables Vue (PAS de Pinia/Vuex)
Tests: Vitest + Vue TestUtils
Build: Vite + TypeScript strict + importation automatique PrimeVue
Port développement: 5174
```

*(Le reste de la stack backend et infrastructure reste identique)*

## 📁 Structure des Dossiers (À RESPECTER STRICTEMENT)

```
redriva/
├── frontend/                     # Application Vue.js 3
│   ├── public/
│   │   └── layout/               # Assets statiques du thème Sakai
│   ├── src/
│   │   ├── layout/               # ✅ NOUVEAU: Composants du layout Sakai (Sidebar, Topbar...)
│   │   ├── assets/               # ✅ NOUVEAU: Fichiers SCSS du thème Sakai
│   │   ├── components/           # Composants réutilisables
│   │   ├── pages/                # Pages principales de l'application
│   │   ├── composables/          # Stores Vue (state management)
│   │   ├── router/               # Configuration Vue Router
│   │   ├── services/             # Services API
│   │   ├── types/                # Types TypeScript
│   │   └── test/                 # Tests Vitest
│   ├── Dockerfile              # Multi-stage UNIFIÉ
│   ├── package.json
│   └── vite.config.ts
... (reste de la structure inchangée)
```

*(Les sections Workflow, Gestion des Dépendances, Clear-Cache, etc. restent identiques car elles sont agnostiques au thème choisi)*

## 🎨 Standards de Code (À RESPECTER ABSOLUMENT)

### Frontend Vue.js 3 avec le Template Sakai

```vue
<!-- Template de base pour une page DANS le layout Sakai -->
<template>
  <div class="grid">
    <div class="col-12">
      <Card>
        <template #title> {{ title }} </template>
        <template #content>
          <!-- Contenu avec composants PrimeVue (importation automatique) -->
          <DataTable :value="data">
            <Column field="name" header="Nom"></Column>
          </DataTable>
        </template>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useApi } from '@/composables/useApi';

const title = ref('Titre de la Page');
const data = ref([]);
const { apiCall } = useApi();

onMounted(async () => {
  data.value = await apiCall('/api/data');
});
</script>
```

### 🎨 Bonnes Pratiques PrimeVue & Sakai (OBLIGATOIRES)

#### Principe Fondamental
Le projet utilise le **template d'application Sakai**. Cela signifie que le layout (sidebar, topbar, menu) est fourni et doit être utilisé comme base pour toutes les pages.

#### 1. Utilisation du Layout Sakai

Le composant racine `App.vue` doit utiliser le `AppLayout.vue` de Sakai pour encapsuler le contenu routé.

```vue
<!-- frontend/src/App.vue -->
<template>
    <AppLayout>
        <router-view />
    </AppLayout>
</template>

<script setup>
import AppLayout from '@/layout/AppLayout.vue';
</script>
```

#### 2. Configuration pour le Thème Sakai (`main.ts`)

La configuration via presets (`Aura`) est **abandonnée**. On utilise désormais les imports de fichiers CSS et SCSS fournis par le template Sakai.

```typescript
// frontend/src/main.ts - Configuration pour le template Sakai
import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import PrimeVue from 'primevue/config';

// Importations des styles requis par Sakai
import 'primeicons/primeicons.css';
import 'primeflex/primeflex.css';
import 'primevue/resources/primevue.min.css';
import './assets/layout/styles.scss'; // Styles SCSS du layout Sakai

const app = createApp(App);

app.use(router);
app.use(PrimeVue, { ripple: true });

app.mount('#app');
```

#### 3. Personnalisation du Thème Sakai

La personnalisation se fait en **surchargeant les variables SCSS de Sakai**, généralement dans `src/assets/layout/_variables.scss`, et **non** via les options de preset.

```scss
/* src/assets/layout/_variables.scss */

// ------ Fonctions et variables de base (ne pas toucher) ------
@import './_functions';
@import './_variables_light';

// ------ ✅ VOS SURCHARGES ICI ------
// Exemple: Changer la couleur primaire de Sakai
$primaryColor: #6366F1;
$primaryLightColor: #A5A6F6;
$primaryDarkColor: #4648D7;
$primaryTextColor: #ffffff;

// ... autres variables à surcharger

// ------ Thèmes et mixins (ne pas toucher) ------
@import './_mixins';
@import './_themes';
```

#### 4. Navigation via le Menu Sakai

Le menu de navigation est géré par le composant `src/layout/AppMenu.vue`. Pour ajouter ou modifier des entrées, modifiez le tableau de données dans ce fichier.

*(Le reste des bonnes pratiques, comme l'utilisation des classes PrimeFlex, reste valide et encouragé.)*

## 🚀 Pages Existantes (État Actuel)

### Configuration Actuelle
- **UI Framework :** PrimeVue v4.x avec le **template d'application Sakai**.
- **Importation :** Automatique via unplugin-vue-components (reste valide).
- **Thèmes :** Thème Sakai (clair/sombre) géré par le layout intégré.
- **Architecture :** Composition API + TypeScript strict.

## ⚠️ Anti-Patterns à Éviter Absolument

### ❌ Ne JAMAIS faire :
- Exécuter `npm install` directement sur la machine locale.
- **Écrire du CSS custom** au lieu d'utiliser les classes PrimeFlex.
- **Utiliser des styles inline** (`style="margin: 16px"`).
- **Ignorer la structure du layout Sakai** (ex: ne pas utiliser `AppLayout`).
- **Modifier les fichiers du thème Sakai directement** au lieu de surcharger les variables SCSS.
- Tenter d'utiliser un système de presets (`Aura`) en parallèle du thème Sakai.

### ✅ Toujours faire :
- Utiliser Docker pour toutes les opérations.
- **Utiliser EXCLUSIVEMENT les composants PrimeVue natifs** (`Button`, `Card`, etc.).
- **Intégrer les nouvelles pages à l'intérieur du `AppLayout` de Sakai**.
- **Personnaliser le style via les variables SCSS de Sakai**.
- Suivre la philosophie "Zéro Réécriture".

## 🔧 Configuration PrimeVue de Référence (Version Sakai)

### Installation Complète

Les dépendances sont celles requises par le template Sakai. `sass` devient une dépendance de développement importante.

```bash
# Dépendances principales
npm install primevue primeicons primeflex

# Dépendances de développement
npm install -D sass unplugin-vue-components @primevue/auto-import-resolver
```

### Configuration `main.ts` (Rappel)

```typescript
// frontend/src/main.ts
import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import PrimeVue from 'primevue/config';

import 'primeicons/primeicons.css';
import 'primeflex/primeflex.css';
import 'primevue/resources/primevue.min.css';
import './assets/layout/styles.scss';

const app = createApp(App);

app.use(router);
app.use(PrimeVue, { ripple: true });

app.mount('#app');
```

### Vite Configuration (Inchangée)
L'importation automatique des composants reste une bonne pratique et est entièrement compatible.

```typescript
// vite.config.ts
import Components from 'unplugin-vue-components/vite'
import { PrimeVueResolver } from '@primevue/auto-import-resolver'

export default defineConfig({
  plugins: [
    vue(),
    Components({
      resolvers: [PrimeVueResolver()]
    })
  ]
})
```

**Rappel Final :** Cette documentation est ta référence absolue. L'objectif est de créer un projet production-ready basé sur le **template d'application Sakai** comme fondation visuelle et structurelle.