<template>
  <div class="torrent-detail">
    <v-container fluid>
      <!-- Navigation -->
      <v-row>
        <v-col cols="12">
          <v-btn
            variant="text"
            prepend-icon="mdi-arrow-left"
            @click="goBack"
            class="mb-4"
          >
            Retour aux torrents
          </v-btn>
        </v-col>
      </v-row>

      <!-- En-tête du torrent -->
      <v-row v-if="torrent">
        <v-col cols="12">
          <v-card class="mb-6">
            <v-card-title>
              <div class="d-flex align-center">
                <v-icon
                  :icon="getStatusIcon(torrent.status)"
                  :color="getStatusColor(torrent.status)"
                  class="mr-2"
                  size="32"
                ></v-icon>
                <div>
                  <h1 class="text-h5">{{ torrent.name }}</h1>
                  <v-chip
                    :color="getStatusColor(torrent.status)"
                    variant="tonal"
                    size="small"
                    class="mt-1"
                  >
                    {{ getStatusText(torrent.status) }}
                  </v-chip>
                </div>
                <v-spacer></v-spacer>
                <div class="d-flex gap-2">
                  <v-btn
                    v-if="torrent.status === 'paused'"
                    color="success"
                    variant="elevated"
                    prepend-icon="mdi-play"
                    @click="resumeTorrent"
                  >
                    Reprendre
                  </v-btn>
                  <v-btn
                    v-else-if="torrent.status === 'downloading'"
                    color="warning"
                    variant="elevated"
                    prepend-icon="mdi-pause"
                    @click="pauseTorrent"
                  >
                    Pause
                  </v-btn>
                  <v-btn
                    color="error"
                    variant="outlined"
                    prepend-icon="mdi-delete"
                    @click="removeTorrent"
                  >
                    Supprimer
                  </v-btn>
                </div>
              </div>
            </v-card-title>
          </v-card>
        </v-col>
      </v-row>

      <!-- Statistiques détaillées -->
      <v-row v-if="torrent">
        <v-col cols="12" md="6">
          <v-card>
            <v-card-title>
              <v-icon icon="mdi-chart-line" class="mr-2"></v-icon>
              Progression
            </v-card-title>
            <v-card-text>
              <div class="mb-4">
                <div class="d-flex justify-space-between mb-2">
                  <span>{{ torrent.progress }}%</span>
                  <span>{{ formatBytes(torrent.downloaded) }} / {{ formatBytes(torrent.size) }}</span>
                </div>
                <v-progress-linear
                  :model-value="torrent.progress"
                  height="12"
                  :color="getProgressColor(torrent.progress)"
                  rounded
                ></v-progress-linear>
              </div>
              
              <v-row>
                <v-col cols="6">
                  <div class="text-caption text-medium-emphasis">Vitesse de téléchargement</div>
                  <div class="text-h6">{{ formatSpeed(torrent.downloadSpeed) }}</div>
                </v-col>
                <v-col cols="6">
                  <div class="text-caption text-medium-emphasis">Vitesse d'envoi</div>
                  <div class="text-h6">{{ formatSpeed(torrent.uploadSpeed) }}</div>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col cols="12" md="6">
          <v-card>
            <v-card-title>
              <v-icon icon="mdi-information" class="mr-2"></v-icon>
              Informations
            </v-card-title>
            <v-card-text>
              <v-list density="compact">
                <v-list-item>
                  <v-list-item-title>Taille totale</v-list-item-title>
                  <v-list-item-subtitle>{{ formatBytes(torrent.size) }}</v-list-item-subtitle>
                </v-list-item>
                <v-list-item>
                  <v-list-item-title>Sources</v-list-item-title>
                  <v-list-item-subtitle>{{ torrent.seeds }} sources, {{ torrent.peers }} pairs</v-list-item-subtitle>
                </v-list-item>
                <v-list-item>
                  <v-list-item-title>Temps restant</v-list-item-title>
                  <v-list-item-subtitle>{{ formatETA(torrent.eta) }}</v-list-item-subtitle>
                </v-list-item>
                <v-list-item>
                  <v-list-item-title>Ajouté le</v-list-item-title>
                  <v-list-item-subtitle>{{ formatDate(torrent.addedDate) }}</v-list-item-subtitle>
                </v-list-item>
              </v-list>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Fichiers du torrent -->
      <v-row v-if="torrent && files.length > 0">
        <v-col cols="12">
          <v-card>
            <v-card-title>
              <v-icon icon="mdi-file-multiple" class="mr-2"></v-icon>
              Fichiers ({{ files.length }})
            </v-card-title>
            <v-card-text>
              <v-data-table
                :headers="fileHeaders"
                :items="files"
                :items-per-page="10"
                class="elevation-0"
              >
                <template v-slot:item.name="{ item }">
                  <div class="d-flex align-center">
                    <v-icon :icon="getFileIcon(item.name)" class="mr-2"></v-icon>
                    {{ item.name }}
                  </div>
                </template>
                <template v-slot:item.size="{ item }">
                  {{ formatBytes(item.size) }}
                </template>
                <template v-slot:item.progress="{ item }">
                  <v-progress-linear
                    :model-value="item.progress"
                    height="6"
                    color="primary"
                    rounded
                  ></v-progress-linear>
                </template>
                <template v-slot:item.priority="{ item }">
                  <v-select
                    :model-value="item.priority"
                    :items="priorityOptions"
                    variant="outlined"
                    density="compact"
                    hide-details
                    @update:model-value="updateFilePriority(item.id, $event)"
                  ></v-select>
                </template>
              </v-data-table>
            </v-card-text>
          </v-card>
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
          <p class="text-h6 mt-4">Chargement du torrent...</p>
        </v-col>
      </v-row>

      <!-- Torrent non trouvé -->
      <v-row v-if="!loading && !torrent">
        <v-col cols="12" class="text-center py-8">
          <v-icon size="64" color="error" class="mb-4">
            mdi-alert-circle
          </v-icon>
          <h3 class="text-h6 mb-2">Torrent non trouvé</h3>
          <p class="text-body-1 text-medium-emphasis">
            Le torrent demandé n'existe pas ou a été supprimé
          </p>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useNotificationStore } from '@/composables/useNotificationStore'

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

interface TorrentFile {
  id: string
  name: string
  size: number
  progress: number
  priority: 'low' | 'normal' | 'high' | 'skip'
}

// Router et stores
const route = useRoute()
const router = useRouter()
const notificationStore = useNotificationStore()

// State
const loading = ref(true)
const torrent = ref<Torrent | null>(null)
const files = ref<TorrentFile[]>([])

// Table headers
const fileHeaders = [
  { title: 'Nom', key: 'name', sortable: true },
  { title: 'Taille', key: 'size', sortable: true },
  { title: 'Progression', key: 'progress', sortable: true },
  { title: 'Priorité', key: 'priority', sortable: false }
]

// Priority options
const priorityOptions = [
  { title: 'Ignorer', value: 'skip' },
  { title: 'Faible', value: 'low' },
  { title: 'Normale', value: 'normal' },
  { title: 'Élevée', value: 'high' }
]

// Methods
const loadTorrentDetails = async () => {
  try {
    loading.value = true
    const torrentId = route.params.id as string
    
    // Simulation de données pour la démonstration
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // Données simulées du torrent
    torrent.value = {
      id: torrentId,
      name: 'Big Movie 2024 1080p BluRay x264-GROUP',
      status: 'downloading',
      progress: 65,
      size: 2147483648, // 2GB
      downloaded: 1395864371, // 1.3GB
      uploadSpeed: 1048576, // 1MB/s
      downloadSpeed: 5242880, // 5MB/s
      eta: 3600, // 1h
      peers: 15,
      seeds: 8,
      addedDate: new Date(Date.now() - 3600000) // 1h ago
    }
    
    // Fichiers simulés
    files.value = [
      {
        id: '1',
        name: 'Big.Movie.2024.1080p.BluRay.x264-GROUP.mkv',
        size: 2000000000,
        progress: 65,
        priority: 'high'
      },
      {
        id: '2',
        name: 'Sample/sample.mkv',
        size: 50000000,
        progress: 100,
        priority: 'normal'
      },
      {
        id: '3',
        name: 'Subs/French.srt',
        size: 100000,
        progress: 100,
        priority: 'normal'
      },
      {
        id: '4',
        name: 'NFO.txt',
        size: 5000,
        progress: 100,
        priority: 'low'
      }
    ]
  } catch (error) {
    console.error('Erreur lors du chargement du torrent:', error)
    notificationStore.add({
      type: 'error',
      title: 'Erreur',
      message: 'Impossible de charger les détails du torrent'
    })
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.back()
}

const pauseTorrent = () => {
  if (torrent.value) {
    torrent.value.status = 'paused'
    notificationStore.add({
      type: 'info',
      title: 'Torrent mis en pause',
      message: torrent.value.name
    })
  }
}

const resumeTorrent = () => {
  if (torrent.value) {
    torrent.value.status = 'downloading'
    notificationStore.add({
      type: 'success',
      title: 'Torrent repris',
      message: torrent.value.name
    })
  }
}

const removeTorrent = () => {
  if (torrent.value) {
    notificationStore.add({
      type: 'warning',
      title: 'Torrent supprimé',
      message: torrent.value.name
    })
    router.push('/torrents')
  }
}

const updateFilePriority = (fileId: string, priority: string) => {
  const file = files.value.find(f => f.id === fileId)
  if (file) {
    file.priority = priority as any
    notificationStore.add({
      type: 'info',
      title: 'Priorité mise à jour',
      message: file.name
    })
  }
}

// Utility functions
const getStatusIcon = (status: string) => {
  switch (status) {
    case 'downloading': return 'mdi-download'
    case 'completed': return 'mdi-check-circle'
    case 'paused': return 'mdi-pause-circle'
    case 'error': return 'mdi-alert-circle'
    default: return 'mdi-help-circle'
  }
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'downloading': return 'primary'
    case 'completed': return 'success'
    case 'paused': return 'warning'
    case 'error': return 'error'
    default: return 'grey'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'downloading': return 'En cours'
    case 'completed': return 'Terminé'
    case 'paused': return 'En pause'
    case 'error': return 'Erreur'
    default: return 'Inconnu'
  }
}

const getProgressColor = (progress: number) => {
  if (progress >= 100) return 'success'
  if (progress >= 75) return 'primary'
  if (progress >= 50) return 'info'
  if (progress >= 25) return 'warning'
  return 'error'
}

const getFileIcon = (filename: string) => {
  const ext = filename.split('.').pop()?.toLowerCase()
  switch (ext) {
    case 'mkv':
    case 'mp4':
    case 'avi':
      return 'mdi-video'
    case 'srt':
    case 'sub':
      return 'mdi-subtitles'
    case 'txt':
    case 'nfo':
      return 'mdi-text'
    default:
      return 'mdi-file'
  }
}

const formatBytes = (bytes: number) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const formatSpeed = (bytesPerSecond: number) => {
  return formatBytes(bytesPerSecond) + '/s'
}

const formatETA = (seconds: number) => {
  if (seconds === 0) return 'Terminé'
  if (seconds < 0) return 'Inconnu'
  
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  
  if (hours > 0) {
    return `${hours}h ${minutes}m`
  }
  return `${minutes}m`
}

const formatDate = (date: Date) => {
  return date.toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Lifecycle
onMounted(() => {
  loadTorrentDetails()
})
</script>

<style scoped>
.torrent-detail {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
</style>
