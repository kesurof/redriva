<template>
  <div class="demo-page">
    <v-container fluid>
      <!-- En-tête -->
      <v-row>
        <v-col cols="12">
          <div class="text-center mb-8">
            <h1 class="text-h3 font-weight-bold text-primary mb-4">
              <v-icon icon="mdi-test-tube" class="mr-2" size="48"></v-icon>
              Démonstration Redriva
            </h1>
            <p class="text-h6 text-medium-emphasis">
              Découvrez les fonctionnalités de votre dashboard média
            </p>
          </div>
        </v-col>
      </v-row>

      <!-- Démo Composables -->
      <v-row class="mb-8">
        <v-col cols="12">
          <v-card>
            <v-card-title>
              <v-icon icon="mdi-function-variant" class="mr-2"></v-icon>
              Composables Vue
            </v-card-title>
            <v-card-text>
              <p class="mb-4">
                Les composables permettent de partager la logique réactive entre les composants.
              </p>
              <v-btn
                color="primary"
                variant="elevated"
                to="/composables"
                prepend-icon="mdi-play"
              >
                Voir la démo des composables
              </v-btn>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Démo Composants -->
      <v-row class="mb-8">
        <v-col cols="12">
          <v-card>
            <v-card-title>
              <v-icon icon="mdi-view-comfy" class="mr-2"></v-icon>
              Composants UI
            </v-card-title>
            <v-card-text>
              <p class="mb-4">
                Bibliothèque de composants réutilisables basés sur Vuetify.
              </p>
              <v-btn
                color="secondary"
                variant="elevated"
                to="/components"
                prepend-icon="mdi-play"
              >
                Voir la démo des composants
              </v-btn>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Démo API -->
      <v-row class="mb-8">
        <v-col cols="12">
          <v-card>
            <v-card-title>
              <v-icon icon="mdi-api" class="mr-2"></v-icon>
              API Backend
            </v-card-title>
            <v-card-text>
              <p class="mb-4">
                Test de connectivité avec l'API FastAPI.
              </p>
              <div class="d-flex gap-2 align-center">
                <v-btn
                  color="success"
                  variant="elevated"
                  @click="testAPI"
                  :loading="apiLoading"
                  prepend-icon="mdi-play"
                >
                  Tester l'API
                </v-btn>
                <v-chip
                  v-if="apiStatus"
                  :color="apiStatus === 'ok' ? 'success' : 'error'"
                  variant="tonal"
                >
                  {{ apiStatus === 'ok' ? 'API Connectée' : 'Erreur API' }}
                </v-chip>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Fonctionnalités -->
      <v-row>
        <v-col cols="12" md="4">
          <v-card class="feature-card">
            <v-card-title>
              <v-icon icon="mdi-download" color="primary" class="mr-2"></v-icon>
              Gestion Torrents
            </v-card-title>
            <v-card-text>
              <p>Interface complète pour gérer vos téléchargements torrents avec Real-Debrid.</p>
              <v-btn
                color="primary"
                variant="outlined"
                to="/torrents"
                block
                class="mt-3"
              >
                Voir les torrents
              </v-btn>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col cols="12" md="4">
          <v-card class="feature-card">
            <v-card-title>
              <v-icon icon="mdi-cog" color="secondary" class="mr-2"></v-icon>
              Monitoring Services
            </v-card-title>
            <v-card-text>
              <p>Surveillez l'état de vos services Plex, Radarr, Sonarr et autres.</p>
              <v-btn
                color="secondary"
                variant="outlined"
                to="/services"
                block
                class="mt-3"
              >
                Voir les services
              </v-btn>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col cols="12" md="4">
          <v-card class="feature-card">
            <v-card-title>
              <v-icon icon="mdi-settings" color="info" class="mr-2"></v-icon>
              Configuration
            </v-card-title>
            <v-card-text>
              <p>Configurez vos clés API, préférences et paramètres système.</p>
              <v-btn
                color="info"
                variant="outlined"
                to="/settings"
                block
                class="mt-3"
              >
                Paramètres
              </v-btn>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Informations système -->
      <v-row class="mt-8">
        <v-col cols="12">
          <v-card>
            <v-card-title>
              <v-icon icon="mdi-information" class="mr-2"></v-icon>
              Informations Système
            </v-card-title>
            <v-card-text>
              <v-row>
                <v-col cols="12" md="6">
                  <v-list density="compact">
                    <v-list-item>
                      <v-list-item-title>Version Redriva</v-list-item-title>
                      <v-list-item-subtitle>v2.0.0 (Vue.js 3)</v-list-item-subtitle>
                    </v-list-item>
                    <v-list-item>
                      <v-list-item-title>Framework Frontend</v-list-item-title>
                      <v-list-item-subtitle>Vue.js 3 + Vuetify</v-list-item-subtitle>
                    </v-list-item>
                    <v-list-item>
                      <v-list-item-title>Framework Backend</v-list-item-title>
                      <v-list-item-subtitle>FastAPI + Python 3.10</v-list-item-subtitle>
                    </v-list-item>
                  </v-list>
                </v-col>
                <v-col cols="12" md="6">
                  <v-list density="compact">
                    <v-list-item>
                      <v-list-item-title>État Frontend</v-list-item-title>
                      <v-list-item-subtitle>
                        <v-chip color="success" size="small">Opérationnel</v-chip>
                      </v-list-item-subtitle>
                    </v-list-item>
                    <v-list-item>
                      <v-list-item-title>État Backend</v-list-item-title>
                      <v-list-item-subtitle>
                        <v-chip :color="apiStatus === 'ok' ? 'success' : 'error'" size="small">
                          {{ apiStatus === 'ok' ? 'Opérationnel' : 'Déconnecté' }}
                        </v-chip>
                      </v-list-item-subtitle>
                    </v-list-item>
                    <v-list-item>
                      <v-list-item-title>Tests</v-list-item-title>
                      <v-list-item-subtitle>
                        <v-chip color="success" size="small">74 tests passants</v-chip>
                      </v-list-item-subtitle>
                    </v-list-item>
                  </v-list>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useNotificationStore } from '@/stores/notifications'

// Stores
const notificationStore = useNotificationStore()

// State
const apiLoading = ref(false)
const apiStatus = ref<string | null>(null)

// Methods
const testAPI = async () => {
  try {
    apiLoading.value = true
    
    const response = await fetch('/api/ping')
    if (response.ok) {
      const data = await response.json()
      apiStatus.value = data.status
      
      notificationStore.add({
        type: 'success',
        title: 'API Connectée',
        message: 'La communication avec le backend fonctionne'
      })
    } else {
      throw new Error('Erreur de réponse API')
    }
  } catch (error) {
    console.error('Erreur API:', error)
    apiStatus.value = 'error'
    
    notificationStore.add({
      type: 'error',
      title: 'Erreur API',
      message: 'Impossible de communiquer avec le backend'
    })
  } finally {
    apiLoading.value = false
  }
}
</script>

<style scoped>
.demo-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem 0;
}

.feature-card {
  height: 100%;
  transition: transform 0.2s ease-in-out;
}

.feature-card:hover {
  transform: translateY(-4px);
}
</style>
