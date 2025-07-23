<template>
  <div class="bg-surface min-vh-100">
    <v-container fluid>
      <!-- En-tête -->
      <v-row>
        <v-col cols="12">
          <div class="d-flex align-center justify-space-between mb-6">
            <div>
              <h1 class="text-h4 font-weight-bold text-primary mb-2">
                <v-icon icon="mdi-download" class="mr-2"></v-icon>
                Torrents
              </h1>
              <p class="text-body-1 text-medium-emphasis">
                Gestion de vos téléchargements et de la file d'attente
              </p>
            </div>
            <v-btn
              color="primary"
              variant="elevated"
              prepend-icon="mdi-plus"
              @click="showAddDialog = true"
            >
              Ajouter
            </v-btn>
          </div>
        </v-col>
      </v-row>

      <!-- Filtres et recherche -->
      <v-row class="mb-4">
        <v-col cols="12" md="6">
          <v-text-field
            v-model="searchQuery"
            prepend-inner-icon="mdi-magnify"
            label="Rechercher un torrent..."
            variant="outlined"
            clearable
            hide-details
          ></v-text-field>
        </v-col>
        <v-col cols="12" md="3">
          <v-select
            v-model="statusFilter"
            :items="statusOptions"
            label="Statut"
            variant="outlined"
            hide-details
          ></v-select>
        </v-col>
        <v-col cols="12" md="3">
          <v-select
            v-model="sortBy"
            :items="sortOptions"
            label="Trier par"
            variant="outlined"
            hide-details
          ></v-select>
        </v-col>
      </v-row>

      <!-- Liste des torrents -->
      <v-row>
        <v-col
          v-for="torrent in filteredTorrents"
          :key="torrent.id"
          cols="12"
        >
          <TorrentCard
            :torrent="torrent"
            @view-details="viewDetails"
            @pause="pauseTorrent"
            @resume="resumeTorrent"
            @remove="removeTorrent"
          />
        </v-col>
      </v-row>

      <!-- État de chargement -->
      <v-row v-if="loading">
        <v-col cols="12" class="text-center py-8">
          <v-progress-circular
            indeterminate
            color="primary"
            size="64"
          ></v-progress-circular>
          <p class="text-h6 mt-4">Chargement des torrents...</p>
        </v-col>
      </v-row>

      <!-- Aucun torrent -->
      <v-row v-if="!loading && filteredTorrents.length === 0">
        <v-col cols="12" class="text-center py-8">
          <v-icon size="64" color="medium-emphasis" class="mb-4">
            mdi-download-off
          </v-icon>
          <h3 class="text-h6 mb-2">Aucun torrent trouvé</h3>
          <p class="text-body-1 text-medium-emphasis">
            Ajoutez des torrents pour commencer vos téléchargements
          </p>
        </v-col>
      </v-row>
    </v-container>

    <!-- Dialog d'ajout de torrent -->
    <v-dialog v-model="showAddDialog" max-width="600">
      <v-card>
        <v-card-title>
          <span class="text-h5">Ajouter un torrent</span>
        </v-card-title>
        <v-card-text>
          <v-form ref="form" v-model="formValid">
            <v-textarea
              v-model="newTorrentUrl"
              label="URL du torrent ou magnet link"
              placeholder="magnet:?xt=urn:btih:... ou http://..."
              variant="outlined"
              rows="3"
              :rules="[rules.required, rules.validUrl]"
            ></v-textarea>
          </v-form>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="grey"
            variant="text"
            @click="showAddDialog = false"
          >
            Annuler
          </v-btn>
          <v-btn
            color="primary"
            variant="elevated"
            :disabled="!formValid"
            @click="addTorrent"
          >
            Ajouter
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDataStore } from '@/composables/useDataStore'
import { useNotificationStore } from '@/composables/useNotificationStore'
import TorrentCard from '@/components/TorrentCard.vue'

// Types
interface Torrent {
  id: string
  name: string
  status: 'downloading' | 'completed' | 'paused' | 'error'
  progress: number
  size: number
  downloaded: number
  uploadSpeed: number
  downloadSpeed: number
  eta: number
  peers: number
  seeds: number
  addedDate: Date
}

// Router et stores
const router = useRouter()
const dataStore = useDataStore()
const notificationStore = useNotificationStore()

// State
const loading = ref(true)
const torrents = ref<Torrent[]>([])
const searchQuery = ref('')
const statusFilter = ref('all')
const sortBy = ref('addedDate')
const showAddDialog = ref(false)
const newTorrentUrl = ref('')
const formValid = ref(false)

// Options
const statusOptions = [
  { title: 'Tous', value: 'all' },
  { title: 'En cours', value: 'downloading' },
  { title: 'Terminés', value: 'completed' },
  { title: 'En pause', value: 'paused' },
  { title: 'Erreur', value: 'error' }
]

const sortOptions = [
  { title: 'Date d\'ajout', value: 'addedDate' },
  { title: 'Nom', value: 'name' },
  { title: 'Progression', value: 'progress' },
  { title: 'Taille', value: 'size' }
]

// Validation rules
const rules = {
  required: (value: string) => !!value || 'Ce champ est requis',
  validUrl: (value: string) => {
    const magnetRegex = /^magnet:\?xt=urn:btih:/
    const httpRegex = /^https?:\/\/.+\.torrent$/
    return magnetRegex.test(value) || httpRegex.test(value) || 'URL ou magnet link invalide'
  }
}

// Computed
const filteredTorrents = computed(() => {
  let filtered = torrents.value

  // Filtrer par statut
  if (statusFilter.value !== 'all') {
    filtered = filtered.filter(t => t.status === statusFilter.value)
  }

  // Filtrer par recherche
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(t => 
      t.name.toLowerCase().includes(query)
    )
  }

  // Trier
  filtered.sort((a, b) => {
    switch (sortBy.value) {
      case 'name':
        return a.name.localeCompare(b.name)
      case 'progress':
        return b.progress - a.progress
      case 'size':
        return b.size - a.size
      case 'addedDate':
      default:
        return b.addedDate.getTime() - a.addedDate.getTime()
    }
  })

  return filtered
})

// Methods
const loadTorrents = async () => {
  try {
    loading.value = true
    
    // Simulation de données pour la démonstration
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    torrents.value = [
      {
        id: '1',
        name: 'Big Movie 2024 1080p BluRay x264-GROUP',
        status: 'downloading',
        progress: 65,
        size: 2147483648, // 2GB
        downloaded: 1395864371, // 1.3GB
        uploadSpeed: 0,
        downloadSpeed: 5242880, // 5MB/s
        eta: 3600, // 1h
        peers: 15,
        seeds: 8,
        addedDate: new Date(Date.now() - 3600000) // 1h ago
      },
      {
        id: '2',
        name: 'TV Show S05E10 HDTV x264-LOL',
        status: 'completed',
        progress: 100,
        size: 367001600, // 350MB
        downloaded: 367001600,
        uploadSpeed: 1048576, // 1MB/s
        downloadSpeed: 0,
        eta: 0,
        peers: 5,
        seeds: 12,
        addedDate: new Date(Date.now() - 7200000) // 2h ago
      },
      {
        id: '3',
        name: 'Album Artist - Greatest Hits (2024) [FLAC]',
        status: 'paused',
        progress: 25,
        size: 524288000, // 500MB
        downloaded: 131072000, // 125MB
        uploadSpeed: 0,
        downloadSpeed: 0,
        eta: 0,
        peers: 0,
        seeds: 3,
        addedDate: new Date(Date.now() - 10800000) // 3h ago
      }
    ]
  } catch (error) {
    console.error('Erreur lors du chargement des torrents:', error)
    notificationStore.add({
      type: 'error',
      title: 'Erreur',
      message: 'Impossible de charger les torrents'
    })
  } finally {
    loading.value = false
  }
}

const viewDetails = (torrentId: string) => {
  router.push(`/torrents/${torrentId}`)
}

const pauseTorrent = (torrentId: string) => {
  const torrent = torrents.value.find(t => t.id === torrentId)
  if (torrent) {
    torrent.status = 'paused'
    notificationStore.add({
      type: 'info',
      title: 'Torrent mis en pause',
      message: torrent.name
    })
  }
}

const resumeTorrent = (torrentId: string) => {
  const torrent = torrents.value.find(t => t.id === torrentId)
  if (torrent) {
    torrent.status = 'downloading'
    notificationStore.add({
      type: 'success',
      title: 'Torrent repris',
      message: torrent.name
    })
  }
}

const removeTorrent = (torrentId: string) => {
  const index = torrents.value.findIndex(t => t.id === torrentId)
  if (index !== -1) {
    const torrent = torrents.value[index]
    torrents.value.splice(index, 1)
    notificationStore.add({
      type: 'warning',
      title: 'Torrent supprimé',
      message: torrent.name
    })
  }
}

const addTorrent = () => {
  if (formValid.value && newTorrentUrl.value) {
    // Simuler l'ajout d'un nouveau torrent
    const newTorrent: Torrent = {
      id: Date.now().toString(),
      name: 'Nouveau Torrent',
      status: 'downloading',
      progress: 0,
      size: 1073741824, // 1GB
      downloaded: 0,
      uploadSpeed: 0,
      downloadSpeed: 0,
      eta: 0,
      peers: 0,
      seeds: 0,
      addedDate: new Date()
    }
    
    torrents.value.unshift(newTorrent)
    
    notificationStore.add({
      type: 'success',
      title: 'Torrent ajouté',
      message: 'Le téléchargement va commencer'
    })
    
    showAddDialog.value = false
    newTorrentUrl.value = ''
  }
}

// Lifecycle
onMounted(() => {
  loadTorrents()
})
</script>


