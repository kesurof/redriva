<template>
  <v-container fluid class="pa-4">
    <!-- En-tête -->
    <div class="d-flex justify-space-between align-center mb-6">
      <h1 class="text-h4 font-weight-medium">Dashboard</h1>
      <v-chip color="success" variant="elevated" class="text-caption">
        <v-icon start icon="mdi-circle" size="x-small"></v-icon>
        Système en ligne
      </v-chip>
    </div>

    <!-- Informations du serveur -->
    <v-card class="mb-6" elevation="1">
      <v-card-title class="d-flex align-center">
        <v-icon icon="mdi-server" class="mr-2" color="primary"></v-icon>
        Informations du serveur
      </v-card-title>
      <v-card-text>
        <v-row v-if="systemInfo">
          <v-col cols="12" sm="6" md="3">
            <StatCard
              title="CPU"
              :value="`${Math.round(systemInfo.cpu_percent || 0)}%`"
              icon="cpu"
              variant="primary"
              :progress="systemInfo.cpu_percent || 0"
            />
          </v-col>
          <v-col cols="12" sm="6" md="3">
            <StatCard
              title="Mémoire"
              :value="`${Math.round(memoryPercent)}%`"
              :subtitle="formatMemory(systemInfo.memory.used)"
              icon="memory"
              variant="warning"
              :progress="memoryPercent"
            />
          </v-col>
          <v-col cols="12" sm="6" md="3">
            <StatCard
              title="Disque"
              :value="`${Math.round(diskPercent)}%`"
              :subtitle="formatSize(systemInfo.disk.used)"
              icon="storage"
              variant="info"
              :progress="diskPercent"
            />
          </v-col>
          <v-col cols="12" sm="6" md="3">
            <StatCard
              title="Uptime"
              :value="systemInfo.uptime"
              :subtitle="systemInfo.boot_time"
              icon="system"
              variant="success"
            />
          </v-col>
        </v-row>
        <v-skeleton-loader v-else type="article" class="mx-auto"></v-skeleton-loader>
      </v-card-text>
    </v-card>

    <!-- Services -->
    <v-card class="mb-6" elevation="1">
      <v-card-title class="d-flex align-center">
        <v-icon icon="mdi-cog-outline" class="mr-2" color="primary"></v-icon>
        Services ({{ onlineServices }}/{{ totalServices }})
      </v-card-title>
      <v-card-text>
        <v-row v-if="services.length > 0">
          <v-col 
            v-for="service in services" 
            :key="service.name"
            cols="12" 
            sm="6" 
            md="4" 
            lg="3"
          >
            <ServiceCard
              :name="service.name"
              :description="service.description"
              :status="service.status"
              :url="service.url"
              :version="service.version"
              :port="service.port"
              :category="service.category || 'system'"
              :display-name="service.displayName"
              :metrics="{
                uptime: service.lastCheck ? formatUptime(service.lastCheck) : undefined,
                memory: service.memory,
                cpu: service.cpu
              }"
              @start="handleStartService"
              @stop="handleStopService"
              @restart="handleRestartService"
              @view-logs="handleViewLogs"
              @view-config="handleViewConfig"
            />
          </v-col>
        </v-row>
        <v-skeleton-loader v-else type="card" class="mx-auto"></v-skeleton-loader>
      </v-card-text>
    </v-card>

    <!-- Torrents récents -->
    <v-card elevation="1">
      <v-card-title class="d-flex align-center justify-space-between">
        <div class="d-flex align-center">
          <v-icon icon="mdi-download" class="mr-2" color="primary"></v-icon>
          Torrents récents ({{ torrents.length }})
        </div>
        <v-btn 
          variant="text" 
          color="primary" 
          size="small"
          @click="$router.push('/torrents')"
        >
          Voir tout
          <v-icon end icon="mdi-arrow-right"></v-icon>
        </v-btn>
      </v-card-title>
      <v-card-text class="pa-0">
        <v-row v-if="torrents.length > 0" class="ma-0">
          <v-col 
            v-for="torrent in torrents.slice(0, 25)" 
            :key="torrent.id"
            cols="12"
            sm="6"
            md="4"
            lg="3"
            class="pa-2"
          >
            <TorrentCard
              :id="torrent.id"
              :name="torrent.name"
              :status="mapTorrentStatus(torrent.status)"
              :progress="torrent.progress"
              :size="formatSize(torrent.size)"
              :download-speed="torrent.downloadSpeed"
              :upload-speed="torrent.uploadSpeed"
              :eta="torrent.eta"
              :seeders="torrent.seeders"
              :leechers="torrent.leechers"
              :priority="torrent.priority"
            />
          </v-col>
        </v-row>
        
        <div v-else-if="loading" class="pa-4">
          <v-skeleton-loader type="card" v-for="i in 8" :key="i" class="ma-2"></v-skeleton-loader>
        </div>
        
        <div v-else class="text-center pa-6">
          <v-icon icon="mdi-download-off" size="48" color="grey-lighten-1" class="mb-2"></v-icon>
          <div class="text-body-2 text-medium-emphasis">Aucun torrent trouvé</div>
        </div>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { StatCard } from '@/components'
import { ServiceCard } from '@/components'
import { TorrentCard } from '@/components'
import type { SystemInfo, Service, Torrent } from '@/services/api'

const { apiClient } = useApi()

// État réactif
const loading = ref(true)
const systemInfo = ref<SystemInfo | null>(null)
const services = ref<Service[]>([])
const torrents = ref<Torrent[]>([])

// Données calculées pour les métriques système
const memoryPercent = computed(() => {
  if (!systemInfo.value?.memory) return 0
  return (systemInfo.value.memory.used / systemInfo.value.memory.total) * 100
})

const diskPercent = computed(() => {
  if (!systemInfo.value?.disk) return 0
  return (systemInfo.value.disk.used / systemInfo.value.disk.total) * 100
})

// Statistiques des services
const onlineServices = computed(() => 
  services.value.filter((s: Service) => s.status === 'online').length
)

const totalServices = computed(() => services.value.length)

// Fonctions utilitaires
const formatMemory = (bytes: number) => {
  return formatSize(bytes)
}

const mapTorrentStatus = (status: string): 'downloading' | 'completed' | 'paused' | 'error' | 'waiting' => {
  switch (status.toLowerCase()) {
    case 'terminé':
    case 'completed':
      return 'completed'
    case 'downloading':
    case 'téléchargement':
      return 'downloading'
    case 'error':
    case 'erreur':
      return 'error'
    case 'paused':
    case 'pausé':
      return 'paused'
    case 'queued':
    case 'en attente':
    case 'waiting':
      return 'waiting'
    default:
      return 'waiting'
  }
}

const formatSize = (size: number | string) => {
  const bytes = typeof size === 'string' ? parseInt(size) : size
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

// Gestionnaires d'événements pour les services
const handleStartService = async (serviceName: string) => {
  try {
    console.log(`Démarrer le service ${serviceName}`)
    // TODO: Implémenter l'appel API pour démarrer le service
    // await apiClient.startService(serviceName)
    
    // Actualiser les données après l'action
    await loadData()
  } catch (error) {
    console.error('Erreur lors du démarrage du service:', error)
  }
}

const handleStopService = async (serviceName: string) => {
  try {
    console.log(`Arrêter le service ${serviceName}`)
    // TODO: Implémenter l'appel API pour arrêter le service
    // await apiClient.stopService(serviceName)
    
    // Actualiser les données après l'action
    await loadData()
  } catch (error) {
    console.error('Erreur lors de l\'arrêt du service:', error)
  }
}

const handleRestartService = async (serviceName: string) => {
  try {
    console.log(`Redémarrer le service ${serviceName}`)
    // TODO: Implémenter l'appel API pour redémarrer le service
    // await apiClient.restartService(serviceName)
    
    // Actualiser les données après l'action
    await loadData()
  } catch (error) {
    console.error('Erreur lors du redémarrage du service:', error)
  }
}

const handleViewLogs = (serviceName: string) => {
  console.log(`Voir les logs du service ${serviceName}`)
  // TODO: Naviguer vers la page des logs ou ouvrir un modal
}

const handleViewConfig = (serviceName: string) => {
  console.log(`Voir la configuration du service ${serviceName}`)
  // TODO: Naviguer vers la page de configuration
}

const formatUptime = (lastCheck: string) => {
  const now = new Date()
  const last = new Date(lastCheck)
  const diff = now.getTime() - last.getTime()
  const hours = Math.floor(diff / (1000 * 60 * 60))
  return `${hours}h`
}

// Chargement des données
const loadData = async () => {
  loading.value = true
  
  try {
    // Charger les données en parallèle
    const [systemResponse, servicesResponse, torrentsResponse] = await Promise.all([
      apiClient.getSystemInfo(),
      apiClient.getServices(),
      apiClient.getTorrents()
    ])

    if (systemResponse.success && systemResponse.data) {
      systemInfo.value = systemResponse.data
    }

    if (servicesResponse.success && servicesResponse.data) {
      services.value = servicesResponse.data
    }

    if (torrentsResponse.success && torrentsResponse.data) {
      torrents.value = torrentsResponse.data
    }
  } catch (error) {
    console.error('Erreur lors du chargement des données:', error)
  } finally {
    loading.value = false
  }
}

// Actualisation automatique toutes les 30 secondes
const startAutoRefresh = () => {
  setInterval(loadData, 30000)
}

onMounted(() => {
  loadData()
  startAutoRefresh()
})
</script>

<!-- Plus besoin de CSS custom - utilisé les classes Vuetify natives -->
