<template>
  <v-app>
    <v-navigation-drawer
      v-model="drawer"
      app
      temporary
    >
      <v-list nav>
        <v-list-item
          v-for="item in navigationItems"
          :key="item.path"
          :to="item.path"
          :prepend-icon="item.icon"
          :title="item.label"
          @click="drawer = false"
        />
      </v-list>
    </v-navigation-drawer>

    <v-app-bar app color="surface" class="border-b">
      <v-app-bar-nav-icon @click="drawer = !drawer" />
      <v-toolbar-title class="font-weight-bold">Redriva Dashboard</v-toolbar-title>
      <v-spacer />
      
      <!-- Indicateur de statut -->
      <v-chip color="success" size="small" class="mr-2">
        <v-icon icon="mdi-circle" size="12" class="mr-1" />
        Connecté
      </v-chip>
      
      <!-- Theme Switcher -->
      <ThemeSwitcher />
    </v-app-bar>

    <v-main class="bg-background">
      <router-view />
    </v-main>

    <!-- Conteneur de notifications -->
    <NotificationContainer />
  </v-app>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import ThemeSwitcher from '@/components/ThemeSwitcher.vue'
import NotificationContainer from '@/components/NotificationContainer.vue'
import { useThemeStore } from '@/composables/useThemeStore'

const drawer = ref(false)
const { initTheme, watchSystemTheme } = useThemeStore()

const navigationItems = [
  { path: '/', label: 'Dashboard', icon: 'mdi-view-dashboard' },
  { path: '/torrents', label: 'Torrents', icon: 'mdi-download' },
  { path: '/services', label: 'Services', icon: 'mdi-monitor-dashboard' },
  { path: '/settings', label: 'Paramètres', icon: 'mdi-cog' },
  { path: '/demo', label: 'Démonstration', icon: 'mdi-palette' },
  { path: '/composables', label: 'Composables Vue', icon: 'mdi-code-braces' },
  { path: '/components', label: 'Composants Vue', icon: 'mdi-view-grid' }
]

onMounted(() => {
  // Initialiser le système de thèmes
  initTheme()
  watchSystemTheme()
})
</script>

<style scoped>
.border-b {
  border-bottom: 1px solid rgb(var(--v-border-color));
}
</style>
