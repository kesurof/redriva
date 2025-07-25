import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

import PrimeVue from 'primevue/config'

// Styles Sakai - Import direct des CSS comme prévu par le template
import 'primeicons/primeicons.css'
import 'primeflex/primeflex.css'
import '@/assets/layout/layout.scss'

const app = createApp(App)

app.use(router)
app.use(PrimeVue, { ripple: true })

app.mount('#app')
