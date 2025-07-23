<template>
  <div class="settings-page">
    <v-container fluid>
      <!-- En-tête -->
      <v-row>
        <v-col cols="12">
          <div class="d-flex align-center justify-space-between mb-6">
            <div>
              <h1 class="text-h4 font-weight-bold text-primary mb-2">
                <v-icon icon="mdi-settings" class="mr-2"></v-icon>
                Paramètres
              </h1>
              <p class="text-body-1 text-medium-emphasis">
                Configuration de votre écosystème média
              </p>
            </div>
            <v-btn
              color="success"
              variant="elevated"
              prepend-icon="mdi-content-save"
              @click="saveSettings"
              :loading="saving"
            >
              Sauvegarder
            </v-btn>
          </div>
        </v-col>
      </v-row>

      <v-row>
        <!-- Navigation des paramètres -->
        <v-col cols="12" md="3">
          <v-card>
            <v-list>
              <v-list-item
                v-for="section in settingSections"
                :key="section.id"
                :active="activeSection === section.id"
                @click="activeSection = section.id"
                :prepend-icon="section.icon"
              >
                <v-list-item-title>{{ section.title }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-card>
        </v-col>

        <!-- Contenu des paramètres -->
        <v-col cols="12" md="9">
          <!-- Real-Debrid -->
          <v-card v-if="activeSection === 'real-debrid'" class="mb-6">
            <v-card-title>
              <v-icon icon="mdi-cloud-download" class="mr-2"></v-icon>
              Real-Debrid
            </v-card-title>
            <v-card-text>
              <v-form ref="rdForm">
                <v-text-field
                  v-model="settings.realDebrid.apiKey"
                  label="Clé API Real-Debrid"
                  :type="showApiKey ? 'text' : 'password'"
                  :append-inner-icon="showApiKey ? 'mdi-eye' : 'mdi-eye-off'"
                  @click:append-inner="showApiKey = !showApiKey"
                  hint="Obtenez votre clé API sur https://real-debrid.com/apitoken"
                  persistent-hint
                  variant="outlined"
                ></v-text-field>
                
                <v-switch
                  v-model="settings.realDebrid.enabled"
                  label="Activer Real-Debrid"
                  color="primary"
                  class="mt-4"
                ></v-switch>
                
                <v-btn
                  color="primary"
                  variant="outlined"
                  prepend-icon="mdi-test-tube"
                  @click="testRealDebrid"
                  :loading="testing.realDebrid"
                  class="mt-4"
                >
                  Tester la connexion
                </v-btn>
              </v-form>
            </v-card-text>
          </v-card>

          <!-- Services -->
          <v-card v-if="activeSection === 'services'" class="mb-6">
            <v-card-title>
              <v-icon icon="mdi-cog-outline" class="mr-2"></v-icon>
              Services
            </v-card-title>
            <v-card-text>
              <v-expansion-panels variant="accordion">
                <v-expansion-panel
                  v-for="service in serviceSettings"
                  :key="service.name"
                  :title="service.displayName"
                >
                  <v-expansion-panel-text>
                    <v-form>
                      <v-text-field
                        v-model="service.url"
                        :label="`URL ${service.displayName}`"
                        placeholder="http://localhost:7878"
                        variant="outlined"
                        class="mb-3"
                      ></v-text-field>
                      
                      <v-text-field
                        v-model="service.apiKey"
                        :label="`Clé API ${service.displayName}`"
                        type="password"
                        variant="outlined"
                        class="mb-3"
                      ></v-text-field>
                      
                      <v-switch
                        v-model="service.enabled"
                        :label="`Activer ${service.displayName}`"
                        color="primary"
                      ></v-switch>
                    </v-form>
                  </v-expansion-panel-text>
                </v-expansion-panel>
              </v-expansion-panels>
            </v-card-text>
          </v-card>

          <!-- Interface -->
          <v-card v-if="activeSection === 'interface'" class="mb-6">
            <v-card-title>
              <v-icon icon="mdi-palette" class="mr-2"></v-icon>
              Interface
            </v-card-title>
            <v-card-text>
              <v-form>
                <v-select
                  v-model="settings.interface.theme"
                  :items="themeOptions"
                  label="Thème"
                  variant="outlined"
                  class="mb-3"
                ></v-select>
                
                <v-select
                  v-model="settings.interface.language"
                  :items="languageOptions"
                  label="Langue"
                  variant="outlined"
                  class="mb-3"
                ></v-select>
                
                <v-switch
                  v-model="settings.interface.animations"
                  label="Animations"
                  color="primary"
                  class="mb-3"
                ></v-switch>
                
                <v-switch
                  v-model="settings.interface.notifications"
                  label="Notifications"
                  color="primary"
                ></v-switch>
              </v-form>
            </v-card-text>
          </v-card>

          <!-- Sécurité -->
          <v-card v-if="activeSection === 'security'" class="mb-6">
            <v-card-title>
              <v-icon icon="mdi-shield-check" class="mr-2"></v-icon>
              Sécurité
            </v-card-title>
            <v-card-text>
              <v-form>
                <v-switch
                  v-model="settings.security.authRequired"
                  label="Authentification requise"
                  color="primary"
                  class="mb-3"
                ></v-switch>
                
                <v-text-field
                  v-model="settings.security.username"
                  label="Nom d'utilisateur"
                  variant="outlined"
                  :disabled="!settings.security.authRequired"
                  class="mb-3"
                ></v-text-field>
                
                <v-text-field
                  v-model="settings.security.password"
                  label="Mot de passe"
                  type="password"
                  variant="outlined"
                  :disabled="!settings.security.authRequired"
                  class="mb-3"
                ></v-text-field>
                
                <v-switch
                  v-model="settings.security.httpsOnly"
                  label="HTTPS uniquement"
                  color="primary"
                  :disabled="!settings.security.authRequired"
                ></v-switch>
              </v-form>
            </v-card-text>
          </v-card>

          <!-- Système -->
          <v-card v-if="activeSection === 'system'" class="mb-6">
            <v-card-title>
              <v-icon icon="mdi-cog" class="mr-2"></v-icon>
              Système
            </v-card-title>
            <v-card-text>
              <v-form>
                <v-slider
                  v-model="settings.system.refreshInterval"
                  label="Intervalle de rafraîchissement (secondes)"
                  min="10"
                  max="300"
                  step="10"
                  thumb-label
                  class="mb-3"
                ></v-slider>
                
                <v-select
                  v-model="settings.system.logLevel"
                  :items="logLevelOptions"
                  label="Niveau de log"
                  variant="outlined"
                  class="mb-3"
                ></v-select>
                
                <v-switch
                  v-model="settings.system.autoStart"
                  label="Démarrage automatique"
                  color="primary"
                  class="mb-3"
                ></v-switch>
                
                <v-switch
                  v-model="settings.system.metrics"
                  label="Collecter les métriques"
                  color="primary"
                ></v-switch>
              </v-form>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useNotificationStore } from '@/composables/useNotificationStore'

// Stores
const notificationStore = useNotificationStore()

// State
const activeSection = ref('real-debrid')
const saving = ref(false)
const showApiKey = ref(false)
const testing = reactive({
  realDebrid: false
})

// Settings data
const settings = reactive({
  realDebrid: {
    apiKey: '',
    enabled: false
  },
  interface: {
    theme: 'auto',
    language: 'fr',
    animations: true,
    notifications: true
  },
  security: {
    authRequired: false,
    username: '',
    password: '',
    httpsOnly: false
  },
  system: {
    refreshInterval: 30,
    logLevel: 'info',
    autoStart: true,
    metrics: true
  }
})

const serviceSettings = reactive([
  {
    name: 'radarr',
    displayName: 'Radarr',
    url: 'http://localhost:7878',
    apiKey: '',
    enabled: false
  },
  {
    name: 'sonarr',
    displayName: 'Sonarr',
    url: 'http://localhost:8989',
    apiKey: '',
    enabled: false
  },
  {
    name: 'plex',
    displayName: 'Plex',
    url: 'http://localhost:32400',
    apiKey: '',
    enabled: false
  },
  {
    name: 'transmission',
    displayName: 'Transmission',
    url: 'http://localhost:9091',
    apiKey: '',
    enabled: false
  }
])

// Navigation sections
const settingSections = [
  { id: 'real-debrid', title: 'Real-Debrid', icon: 'mdi-cloud-download' },
  { id: 'services', title: 'Services', icon: 'mdi-cog-outline' },
  { id: 'interface', title: 'Interface', icon: 'mdi-palette' },
  { id: 'security', title: 'Sécurité', icon: 'mdi-shield-check' },
  { id: 'system', title: 'Système', icon: 'mdi-cog' }
]

// Options
const themeOptions = [
  { title: 'Automatique', value: 'auto' },
  { title: 'Clair', value: 'light' },
  { title: 'Sombre', value: 'dark' }
]

const languageOptions = [
  { title: 'Français', value: 'fr' },
  { title: 'English', value: 'en' },
  { title: 'Español', value: 'es' }
]

const logLevelOptions = [
  { title: 'Debug', value: 'debug' },
  { title: 'Info', value: 'info' },
  { title: 'Warning', value: 'warning' },
  { title: 'Error', value: 'error' }
]

// Methods
const saveSettings = async () => {
  try {
    saving.value = true
    
    // Simulation de sauvegarde
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    notificationStore.add({
      type: 'success',
      title: 'Paramètres sauvegardés',
      message: 'Vos paramètres ont été enregistrés avec succès'
    })
  } catch (error) {
    console.error('Erreur lors de la sauvegarde:', error)
    notificationStore.add({
      type: 'error',
      title: 'Erreur de sauvegarde',
      message: 'Impossible de sauvegarder les paramètres'
    })
  } finally {
    saving.value = false
  }
}

const testRealDebrid = async () => {
  try {
    testing.realDebrid = true
    
    if (!settings.realDebrid.apiKey) {
      throw new Error('Clé API manquante')
    }
    
    // Simulation de test API
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    notificationStore.add({
      type: 'success',
      title: 'Real-Debrid connecté',
      message: 'La connexion à Real-Debrid fonctionne correctement'
    })
  } catch (error) {
    console.error('Erreur test Real-Debrid:', error)
    notificationStore.add({
      type: 'error',
      title: 'Erreur Real-Debrid',
      message: 'Impossible de se connecter à Real-Debrid'
    })
  } finally {
    testing.realDebrid = false
  }
}
</script>

<style scoped>
.settings-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
</style>
