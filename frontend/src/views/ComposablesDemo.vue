<template>
  <v-container fluid class="pa-6">
    <div class="d-flex flex-column gap-6">
      <!-- En-tête -->
      <div class="text-center">
        <h1 class="text-h3 font-weight-bold mb-2">Démonstration des Composables Vue</h1>
        <p class="text-body-1 text-medium-emphasis">
          Test des stores Vue équivalents aux stores Svelte
        </p>
      </div>

      <!-- Section Notifications -->
      <v-card>
        <v-card-title class="d-flex align-center">
          <v-icon icon="mdi-bell" class="mr-2" />
          Système de Notifications
        </v-card-title>
        <v-card-text>
          <div class="d-flex flex-wrap gap-2">
            <v-btn color="success" @click="showSuccessNotification">
              <v-icon icon="mdi-check" class="mr-2" />
              Succès
            </v-btn>
            <v-btn color="error" @click="showErrorNotification">
              <v-icon icon="mdi-alert-circle" class="mr-2" />
              Erreur
            </v-btn>
            <v-btn color="warning" @click="showWarningNotification">
              <v-icon icon="mdi-alert" class="mr-2" />
              Avertissement
            </v-btn>
            <v-btn color="info" @click="showInfoNotification">
              <v-icon icon="mdi-information" class="mr-2" />
              Information
            </v-btn>
            <v-btn color="grey" @click="clearAllNotifications">
              <v-icon icon="mdi-delete-sweep" class="mr-2" />
              Tout effacer
            </v-btn>
          </div>
          <div class="mt-4">
            <p class="text-body-2">Notifications actives: {{ notifications.length }}</p>
          </div>
        </v-card-text>
      </v-card>

      <!-- Section État de l'application -->
      <v-card>
        <v-card-title class="d-flex align-center">
          <v-icon icon="mdi-cog" class="mr-2" />
          État de l'Application
        </v-card-title>
        <v-card-text>
          <div class="d-flex flex-wrap gap-2 mb-4">
            <v-btn 
              :color="isLoading ? 'warning' : 'primary'"
              @click="toggleLoading"
            >
              <v-icon :icon="isLoading ? 'mdi-loading' : 'mdi-play'" class="mr-2" />
              {{ isLoading ? 'Arrêter le chargement' : 'Démarrer le chargement' }}
            </v-btn>
            <v-btn color="error" @click="simulateError">
              <v-icon icon="mdi-bug" class="mr-2" />
              Simuler une erreur
            </v-btn>
            <v-btn color="success" @click="refreshSystemStatus">
              <v-icon icon="mdi-refresh" class="mr-2" />
              Actualiser le système
            </v-btn>
          </div>
          
          <v-row>
            <v-col cols="12" md="6">
              <v-card variant="outlined">
                <v-card-text>
                  <h4>État du chargement</h4>
                  <v-chip 
                    :color="isLoading ? 'warning' : 'success'"
                    :prepend-icon="isLoading ? 'mdi-loading mdi-spin' : 'mdi-check'"
                  >
                    {{ isLoading ? 'En cours...' : 'Prêt' }}
                  </v-chip>
                </v-card-text>
              </v-card>
            </v-col>
            <v-col cols="12" md="6">
              <v-card variant="outlined">
                <v-card-text>
                  <h4>Dernière erreur</h4>
                  <p v-if="appError" class="text-error">{{ appError }}</p>
                  <v-chip v-else color="success" prepend-icon="mdi-check">Aucune erreur</v-chip>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>

      <!-- Section Authentification -->
      <v-card>
        <v-card-title class="d-flex align-center">
          <v-icon icon="mdi-account" class="mr-2" />
          Authentification (Démo)
        </v-card-title>
        <v-card-text>
          <div class="d-flex flex-wrap gap-2 mb-4">
            <v-btn 
              v-if="!isAuthenticated"
              color="primary" 
              @click="simulateLogin"
            >
              <v-icon icon="mdi-login" class="mr-2" />
              Se connecter (demo)
            </v-btn>
            <v-btn 
              v-else
              color="error" 
              @click="logout"
            >
              <v-icon icon="mdi-logout" class="mr-2" />
              Se déconnecter
            </v-btn>
          </div>
          
          <v-card variant="outlined">
            <v-card-text>
              <h4>État de l'authentification</h4>
              <v-chip 
                :color="isAuthenticated ? 'success' : 'error'"
                :prepend-icon="isAuthenticated ? 'mdi-check' : 'mdi-close'"
              >
                {{ isAuthenticated ? 'Connecté' : 'Non connecté' }}
              </v-chip>
              <div v-if="currentUser" class="mt-2">
                <p><strong>Utilisateur:</strong> {{ currentUser.username }}</p>
                <p><strong>Email:</strong> {{ currentUser.email }}</p>
              </div>
            </v-card-text>
          </v-card>
        </v-card-text>
      </v-card>

      <!-- Section Données -->
      <v-card>
        <v-card-title class="d-flex align-center">
          <v-icon icon="mdi-database" class="mr-2" />
          Gestion des Données
        </v-card-title>
        <v-card-text>
          <div class="d-flex flex-wrap gap-2 mb-4">
            <v-btn color="primary" @click="addSampleTorrent">
              <v-icon icon="mdi-plus" class="mr-2" />
              Ajouter un torrent
            </v-btn>
            <v-btn color="warning" @click="clearTorrents">
              <v-icon icon="mdi-delete" class="mr-2" />
              Vider les torrents
            </v-btn>
            <v-btn color="info" @click="addSampleQueueItem">
              <v-icon icon="mdi-playlist-plus" class="mr-2" />
              Ajouter à la queue
            </v-btn>
          </div>
          
          <v-row>
            <v-col cols="12" md="6">
              <v-card variant="outlined">
                <v-card-text>
                  <h4>Torrents</h4>
                  <p>Total: {{ torrents.length }}</p>
                  <p>Actifs: {{ activeDownloads.length }}</p>
                  <p>Terminés: {{ completedTorrents.length }}</p>
                  <p>Taille totale: {{ totalSize }}</p>
                </v-card-text>
              </v-card>
            </v-col>
            <v-col cols="12" md="6">
              <v-card variant="outlined">
                <v-card-text>
                  <h4>File d'attente</h4>
                  <p>Éléments: {{ queue.length }}</p>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </div>
  </v-container>
</template>

<script setup lang="ts">

import { 
  useNotificationStore, 
  useAppStore, 
  useAuthStore, 
  useDataStore 
} from '@/composables'

// Stores
const notificationStore = useNotificationStore()
const appStore = useAppStore()
const authStore = useAuthStore()
const dataStore = useDataStore()

// État des notifications
const { notifications, success, error: notifyError, warning, info, clear } = notificationStore

// État de l'application
const { isLoading, error: appError, setLoading, setError, clearError, refreshSystemStatus } = appStore

// État de l'authentification
const { isAuthenticated, currentUser, login, logout } = authStore

// État des données
const { 
  torrents, 
  queue, 
  activeDownloads, 
  completedTorrents, 
  totalSize,
  addTorrent,
  setTorrents,
  addToQueue
} = dataStore

// Méthodes pour les notifications
const showSuccessNotification = () => {
  success('Succès !', 'Opération réalisée avec succès')
}

const showErrorNotification = () => {
  notifyError('Erreur !', 'Une erreur est survenue lors de l\'opération')
}

const showWarningNotification = () => {
  warning('Attention !', 'Cette action nécessite votre attention')
}

const showInfoNotification = () => {
  info('Information', 'Voici une information importante')
}

const clearAllNotifications = () => {
  clear()
}

// Méthodes pour l'état de l'application
const toggleLoading = () => {
  setLoading(!isLoading.value)
}

const simulateError = () => {
  setError('Une erreur de test a été simulée')
  notifyError('Erreur simulée', 'Ceci est une erreur de test')
}

// Méthodes pour l'authentification
const simulateLogin = () => {
  const user = {
    id: '1',
    username: 'demo_user',
    email: 'demo@redriva.app'
  }
  const tokens = {
    access_token: 'demo_access_token',
    refresh_token: 'demo_refresh_token'
  }
  login(user, tokens)
  success('Connexion réussie', 'Vous êtes maintenant connecté')
}

// Méthodes pour les données
const addSampleTorrent = () => {
  const torrent = {
    id: `torrent_${Date.now()}`,
    name: `Film Demo ${Date.now()}`,
    title: `Film Demo ${Date.now()}`,
    status: Math.random() > 0.5 ? 'downloading' : 'completed' as any,
    size: `${(Math.random() * 50 + 1).toFixed(1)} GB`,
    progress: Math.floor(Math.random() * 100),
    category: 'Movies',
    downloadSpeed: `${(Math.random() * 100).toFixed(1)} MB/s`,
    seeders: Math.floor(Math.random() * 100),
    leechers: Math.floor(Math.random() * 50)
  }
  addTorrent(torrent)
  success('Torrent ajouté', `${torrent.name} a été ajouté`)
}

const clearTorrents = () => {
  setTorrents([])
  info('Torrents effacés', 'Tous les torrents ont été supprimés')
}

const addSampleQueueItem = () => {
  const queueItem = {
    id: Date.now(),
    torrent_id: `torrent_${Date.now()}`,
    priority: ['low', 'normal', 'high'][Math.floor(Math.random() * 3)] as any,
    status: ['pending', 'running'][Math.floor(Math.random() * 2)] as any,
    added_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }
  addToQueue(queueItem)
  info('Élément ajouté', 'Nouvel élément ajouté à la file d\'attente')
}
</script>
