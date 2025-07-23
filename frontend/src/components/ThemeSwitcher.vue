<template>
  <div class="theme-switcher">
    <!-- Toggle Dark/Light -->
    <v-btn
      :icon="isDark ? 'mdi-weather-sunny' : 'mdi-weather-night'"
      :color="isDark ? 'warning' : 'primary'"
      variant="text"
      size="large"
      @click="toggleDarkMode"
      :title="isDark ? 'Mode clair' : 'Mode sombre'"
    />
    
    <!-- Sélecteur de thème -->
    <v-menu>
      <template v-slot:activator="{ props }">
        <v-btn
          icon="mdi-palette"
          variant="text"
          size="large"
          v-bind="props"
          title="Changer de thème"
        />
      </template>
      
      <v-list>
        <v-list-item
          v-for="theme in themes"
          :key="theme.name"
          :active="themeName === theme.name"
          @click="setTheme(theme.name)"
        >
          <template v-slot:prepend>
            <v-icon :icon="theme.icon" :color="theme.color" />
          </template>
          <v-list-item-title>{{ theme.label }}</v-list-item-title>
          <template v-slot:append v-if="themeName === theme.name">
            <v-icon icon="mdi-check" color="primary" />
          </template>
        </v-list-item>
      </v-list>
    </v-menu>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useThemeStore, type ThemeName } from '@/composables/useThemeStore'

const { themeName, isDark, setTheme, toggleDarkMode } = useThemeStore()

const themes = computed(() => [
  {
    name: 'skeletonLight' as ThemeName,
    label: 'Skeleton Clair',
    icon: 'mdi-weather-sunny',
    color: 'primary'
  },
  {
    name: 'skeletonDark' as ThemeName,
    label: 'Skeleton Sombre',
    icon: 'mdi-weather-night',
    color: 'primary'
  },
  {
    name: 'wintryLight' as ThemeName,
    label: 'Wintry Clair',
    icon: 'mdi-snowflake',
    color: 'info'
  },
  {
    name: 'wintryDark' as ThemeName,
    label: 'Wintry Sombre',
    icon: 'mdi-snowflake-variant',
    color: 'info'
  }
])
</script>

<style scoped>
.theme-switcher {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
</style>
