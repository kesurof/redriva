<template>
  <div class="services-list">
    <v-container fluid>
      <!-- En-tête -->
      <v-row>
        <v-col cols="12">
          <div class="d-flex align-center justify-space-between mb-6">
            <div>
              <h1 class="text-h4 font-weight-bold text-primary mb-2">
                <v-icon icon="mdi-cog-outline" class="mr-2"></v-icon>
                Services
              </h1>
              <p class="text-body-1 text-medium-emphasis">
                Monitoring et gestion des services de votre écosystème média
              </p>
            </div>
            <v-btn
              color="primary"
              variant="elevated"
              prepend-icon="mdi-refresh"
              @click="refreshServices"
              :loading="loading"
            >
              Actualiser
            </v-btn>
          </div>
        </v-col>
      </v-row>

      <!-- Statistiques globales -->
      <v-row class="mb-6">
        <v-col cols="12" sm="6" md="3">
          <StatCard
            title="Services Actifs"
            :value="stats.active"
            icon="mdi-check-circle"
            color="success"
            :loading="loading"
          />
        </v-col>
        <v-col cols="12" sm="6" md="3">
          <StatCard
            title="Services Inactifs"
            :value="stats.inactive"
            icon="mdi-alert-circle"
            color="warning"
            :loading="loading"
          />
        </v-col>
        <v-col cols="12" sm="6" md="3">
          <StatCard
            title="En Erreur"
            :value="stats.error"
            icon="mdi-close-circle"
            color="error"
            :loading="loading"
          />
        </v-col>
        <v-col cols="12" sm="6" md="3">
          <StatCard
            title="Total Services"
            :value="stats.total"
            icon="mdi-server"
            color="info"
            :loading="loading"
          />
        </v-col>
      </v-row>

      <!-- Liste des services -->
      <v-row>
        <v-col
          v-for="service in services"
          :key="service.name"
          cols="12"
          md="6"
          lg="4"
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
            @start="handleStart"
            @stop="handleStop"
            @restart="handleRestart"
            @view-logs="handleViewLogs"
            @view-config="handleViewConfig"
          />
        </v-col>
      </v-row>

      <!-- État de chargement -->
      <v-row v-if="loading && services.length === 0">
        <v-col cols="12" class="text-center py-8">
          <v-progress-circular
            indeterminate
            color="primary"
            size="64"
          ></v-progress-circular>
          <p class="text-h6 mt-4">Chargement des services...</p>
        </v-col>
      </v-row>

      <!-- Aucun service -->
      <v-row v-if="!loading && services.length === 0">
        <v-col cols="12" class="text-center py-8">
          <v-icon size="64" color="medium-emphasis" class="mb-4">
            mdi-server-off
          </v-icon>
          <h3 class="text-h6 mb-2">Aucun service configuré</h3>
          <p class="text-body-1 text-medium-emphasis">
            Configurez vos services pour commencer le monitoring
          </p>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAppStore } from '@/composables/useAppStore'
import { useNotificationStore } from '@/composables/useNotificationStore'
import StatCard from '@/components/StatCard.vue'
import ServiceCard from '@/components/ServiceCard.vue'

// Types
interface Service {
  name: string
  status: 'running' | 'stopped' | 'error'
  url?: string
  version?: string
  uptime?: number
  cpu?: number
  memory?: number
  description?: string
}

// Stores
const appStore = useAppStore()
const notificationStore = useNotificationStore()

// State
const loading = ref(true)
const services = ref<Service[]>([])

// Computed
const stats = computed(() => {
  const active = services.value.filter(s => s.status === 'running').length
  const inactive = services.value.filter(s => s.status === 'stopped').length
  const error = services.value.filter(s => s.status === 'error').length
  const total = services.value.length

  return { active, inactive, error, total }
})

// Methods
const loadServices = async () => {
  try {
    loading.value = true
    
    // Simulation de données pour la démonstration
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    services.value = [
      {
        name: 'Plex Media Server',
        status: 'running',
        url: 'http://localhost:32400',
        version: '1.40.1.8227',
        uptime: 345600,
        cpu: 15.2,
        memory: 2048,
        description: 'Serveur multimédia personnel'
      },
      {
        name: 'Radarr',
        status: 'running',
        url: 'http://localhost:7878',
        version: '5.8.3.8933',
        uptime: 258000,
        cpu: 5.1,
        memory: 512,
        description: 'Gestionnaire de films automatique'
      },
      {
        name: 'Sonarr',
        status: 'running',
        url: 'http://localhost:8989',
        version: '4.0.8.1874',
        uptime: 432000,
        cpu: 3.8,
        memory: 380,
        description: 'Gestionnaire de séries TV automatique'
      },
      {
        name: 'Transmission',
        status: 'stopped',
        url: 'http://localhost:9091',
        version: '4.0.5',
        uptime: 0,
        cpu: 0,
        memory: 0,
        description: 'Client BitTorrent'
      },
      {
        name: 'Real-Debrid API',
        status: 'running',
        url: 'https://api.real-debrid.com',
        version: 'v1',
        uptime: 999999,
        cpu: 0,
        memory: 0,
        description: 'Service de téléchargement premium'
      },
      {
        name: 'Jellyfin',
        status: 'error',
        url: 'http://localhost:8096',
        version: '10.9.9',
        uptime: 0,
        cpu: 0,
        memory: 0,
        description: 'Serveur multimédia libre'
      }
    ]
  } catch (error) {
    console.error('Erreur lors du chargement des services:', error)
    notificationStore.add({
      type: 'error',
      title: 'Erreur',
      message: 'Impossible de charger les services'
    })
  } finally {
    loading.value = false
  }
}

const refreshServices = () => {
  loadServices()
  notificationStore.add({
    type: 'info',
    title: 'Actualisation',
    message: 'Services mis à jour'
  })
}

const handleRestart = (serviceName: string) => {
  notificationStore.add({
    type: 'info',
    title: 'Service redémarré',
    message: `${serviceName} a été redémarré`
  })
  // Simuler le redémarrage
  const service = services.value.find(s => s.name === serviceName)
  if (service) {
    service.status = 'running'
  }
}

const handleStop = (serviceName: string) => {
  notificationStore.add({
    type: 'warning',
    title: 'Service arrêté',
    message: `${serviceName} a été arrêté`
  })
  // Simuler l'arrêt
  const service = services.value.find(s => s.name === serviceName)
  if (service) {
    service.status = 'stopped'
  }
}

const handleStart = (serviceName: string) => {
  notificationStore.add({
    type: 'success',
    title: 'Service démarré',
    message: `${serviceName} a été démarré`
  })
  // Simuler le démarrage
  const service = services.value.find(s => s.name === serviceName)
  if (service) {
    service.status = 'running'
  }
}

const handleViewLogs = (serviceName: string) => {
  console.log(`Voir les logs du service ${serviceName}`)
  // TODO: Naviguer vers la page des logs ou ouvrir un modal
  notificationStore.add({
    type: 'info',
    title: 'Logs du service',
    message: `Ouverture des logs pour ${serviceName}`
  })
}

const handleViewConfig = (serviceName: string) => {
  console.log(`Voir la configuration du service ${serviceName}`)
  // TODO: Naviguer vers la page de configuration
  notificationStore.add({
    type: 'info',
    title: 'Configuration',
    message: `Ouverture de la configuration pour ${serviceName}`
  })
}

// Lifecycle
onMounted(() => {
  loadServices()
})
</script>

<style scoped>
.services-list {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
</style>
