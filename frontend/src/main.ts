import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

import PrimeVue from 'primevue/config'
// @ts-ignore
import Aura from '@primevue/themes/aura'
import { useThemeStore } from '@/composables/useThemeStore'

// Styles de base
import 'primeicons/primeicons.css'
import 'primeflex/primeflex.css'

const app = createApp(App)

app.use(router)
app.use(PrimeVue, { 
    theme: {
        preset: Aura,
        options: {
            darkModeSelector: '.dark-mode',
            cssLayer: {
                name: 'primevue',
                order: 'tailwind-base, primevue, tailwind-utilities'
            }
        }
    },
    ripple: true 
})

// Initialiser le système de thème après le montage
app.mount('#app')

// Charger les préférences de thème sauvegardées
const { loadThemePreferences } = useThemeStore()
loadThemePreferences(app)
