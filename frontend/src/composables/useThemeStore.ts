import { ref, computed } from 'vue'
import { useTheme } from 'vuetify'

// Types des thèmes disponibles
export type ThemeName = 'skeletonLight' | 'skeletonDark' | 'wintryLight' | 'wintryDark'

// Store global du thème (équivalent au store Svelte)
const currentTheme = ref<ThemeName>('skeletonLight')
const isDarkMode = ref(false)

export function useThemeStore() {
  const theme = useTheme()

  // Getters (équivalent aux derived stores Svelte)
  const themeName = computed(() => currentTheme.value)
  const isLight = computed(() => !isDarkMode.value)
  const isDark = computed(() => isDarkMode.value)

  // Actions (équivalent aux fonctions des stores Svelte)
  const setTheme = (themeName: ThemeName) => {
    currentTheme.value = themeName
    isDarkMode.value = themeName.includes('Dark')
    theme.global.name.value = themeName
    
    // Sauvegarder dans localStorage (persistance)
    localStorage.setItem('redriva-theme', themeName)
  }

  const toggleDarkMode = () => {
    const baseTheme = currentTheme.value.replace('Light', '').replace('Dark', '') as 'skeleton' | 'wintry'
    const newTheme = isDarkMode.value 
      ? `${baseTheme}Light` as ThemeName
      : `${baseTheme}Dark` as ThemeName
    
    setTheme(newTheme)
  }

  const setLightMode = () => {
    const baseTheme = currentTheme.value.replace('Light', '').replace('Dark', '') as 'skeleton' | 'wintry'
    setTheme(`${baseTheme}Light` as ThemeName)
  }

  const setDarkMode = () => {
    const baseTheme = currentTheme.value.replace('Light', '').replace('Dark', '') as 'skeleton' | 'wintry'
    setTheme(`${baseTheme}Dark` as ThemeName)
  }

  const setSkeleton = () => {
    const mode = isDarkMode.value ? 'Dark' : 'Light'
    setTheme(`skeleton${mode}` as ThemeName)
  }

  const setWintry = () => {
    const mode = isDarkMode.value ? 'Dark' : 'Light'
    setTheme(`wintry${mode}` as ThemeName)
  }

  // Initialisation depuis localStorage
  const initTheme = () => {
    const savedTheme = localStorage.getItem('redriva-theme') as ThemeName | null
    if (savedTheme && ['skeletonLight', 'skeletonDark', 'wintryLight', 'wintryDark'].includes(savedTheme)) {
      setTheme(savedTheme)
    } else {
      // Détecter préférence système
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      setTheme(prefersDark ? 'skeletonDark' : 'skeletonLight')
    }
  }

  // Écouter les changements de préférence système
  const watchSystemTheme = () => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    mediaQuery.addEventListener('change', (e) => {
      // Seulement si pas de thème sauvegardé explicitement
      if (!localStorage.getItem('redriva-theme')) {
        setTheme(e.matches ? 'skeletonDark' : 'skeletonLight')
      }
    })
  }

  return {
    // State
    themeName,
    isDark,
    isLight,
    
    // Actions
    setTheme,
    toggleDarkMode,
    setLightMode,
    setDarkMode,
    setSkeleton,
    setWintry,
    initTheme,
    watchSystemTheme,
  }
}
