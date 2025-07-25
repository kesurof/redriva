import { ref, reactive } from 'vue'
import type { App } from 'vue'

// Types pour les thèmes
export interface ThemeConfig {
  name: string
  preset: any
  isDark?: boolean
}

export interface CustomThemeColors {
  primary: string
  surface: string
  text: string
}

// État global du thème
const currentTheme = ref('aura')
const isDarkMode = ref(false)
const customColors = reactive<CustomThemeColors>({
  primary: '#3B82F6',
  surface: '#FFFFFF',
  text: '#1F2937'
})

// Thèmes disponibles (à importer dynamiquement)
const themePresets = {
  aura: () => import('@primevue/themes/aura'),
  lara: () => import('@primevue/themes/lara'),
  // material: () => import('@primevue/themes/material'),
  // nora: () => import('@primevue/themes/nora')
}

export const useThemeStore = () => {
  
  /**
   * Change le thème principal de l'application
   */
  const setTheme = async (themeName: string, app?: App) => {
    try {
      if (themeName in themePresets) {
        const themeModule = await themePresets[themeName as keyof typeof themePresets]()
        const preset = themeModule.default
        
        // Si l'instance de l'app est fournie, reconfigurer PrimeVue
        if (app && app.config.globalProperties.$primevue) {
          app.config.globalProperties.$primevue.config.theme = {
            preset,
            options: {
              darkModeSelector: '.dark-mode',
              cssLayer: {
                name: 'primevue',
                order: 'tailwind-base, primevue, tailwind-utilities'
              }
            }
          }
        }
        
        currentTheme.value = themeName
        saveThemePreferences()
        
        console.log(`Thème changé vers: ${themeName}`)
        return true
      }
    } catch (error) {
      console.error('Erreur lors du changement de thème:', error)
      return false
    }
    return false
  }

  /**
   * Active/désactive le mode sombre
   */
  const toggleDarkMode = (enabled?: boolean) => {
    const html = document.documentElement
    
    if (enabled !== undefined) {
      isDarkMode.value = enabled
    } else {
      isDarkMode.value = !isDarkMode.value
    }
    
    if (isDarkMode.value) {
      html.classList.add('dark-mode')
    } else {
      html.classList.remove('dark-mode')
    }
    
    saveThemePreferences()
  }

  /**
   * Met à jour les couleurs personnalisées
   */
  const updateCustomColors = (colors: Partial<CustomThemeColors>) => {
    Object.assign(customColors, colors)
    applyCustomColors()
    saveThemePreferences()
  }

  /**
   * Applique les couleurs personnalisées via CSS custom properties
   */
  const applyCustomColors = () => {
    const root = document.documentElement
    root.style.setProperty('--p-primary-color', customColors.primary)
    root.style.setProperty('--p-surface-0', customColors.surface)
    root.style.setProperty('--p-text-color', customColors.text)
  }

  /**
   * Réinitialise le thème aux valeurs par défaut
   */
  const resetTheme = async (app?: App) => {
    currentTheme.value = 'aura'
    isDarkMode.value = false
    Object.assign(customColors, {
      primary: '#3B82F6',
      surface: '#FFFFFF',
      text: '#1F2937'
    })
    
    document.documentElement.classList.remove('dark-mode')
    applyCustomColors()
    await setTheme('aura', app)
    
    localStorage.removeItem('redriva-theme-config')
  }

  /**
   * Charge les préférences sauvegardées
   */
  const loadThemePreferences = async (app?: App) => {
    try {
      const saved = localStorage.getItem('redriva-theme-config')
      if (saved) {
        const config = JSON.parse(saved)
        
        if (config.theme) {
          await setTheme(config.theme, app)
        }
        
        if (config.darkMode !== undefined) {
          toggleDarkMode(config.darkMode)
        }
        
        if (config.customColors) {
          updateCustomColors(config.customColors)
        }
      }
    } catch (error) {
      console.error('Erreur lors du chargement des préférences:', error)
    }
  }

  /**
   * Sauvegarde les préférences
   */
  const saveThemePreferences = () => {
    const config = {
      theme: currentTheme.value,
      darkMode: isDarkMode.value,
      customColors: { ...customColors }
    }
    
    localStorage.setItem('redriva-theme-config', JSON.stringify(config))
  }

  /**
   * Exporte la configuration actuelle
   */
  const exportThemeConfig = () => {
    const config = {
      theme: currentTheme.value,
      darkMode: isDarkMode.value,
      customColors: { ...customColors },
      exportDate: new Date().toISOString()
    }
    
    return config
  }

  /**
   * Importe une configuration
   */
  const importThemeConfig = async (configData: any, app?: App) => {
    try {
      if (configData.theme) {
        await setTheme(configData.theme, app)
      }
      
      if (configData.darkMode !== undefined) {
        toggleDarkMode(configData.darkMode)
      }
      
      if (configData.customColors) {
        updateCustomColors(configData.customColors)
      }
      
      return true
    } catch (error) {
      console.error('Erreur lors de l\'importation:', error)
      return false
    }
  }

  return {
    // État
    currentTheme: readonly(currentTheme),
    isDarkMode: readonly(isDarkMode),
    customColors: readonly(customColors),
    
    // Actions
    setTheme,
    toggleDarkMode,
    updateCustomColors,
    resetTheme,
    loadThemePreferences,
    exportThemeConfig,
    importThemeConfig
  }
}

// Helper pour readonly
function readonly<T>(ref: T): T {
  return ref
}
