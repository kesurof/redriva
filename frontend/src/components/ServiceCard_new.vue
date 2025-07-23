<template>
  <v-card
    class="mx-auto"
    color="surface-variant"
    max-width="600"
    min-height="320"
    variant="flat"
    elevation="3"
    rounded="xl"
  >
    <!-- En-tête de la carte -->
    <v-sheet :color="headerColor" class="rounded-t-xl">
      <v-card-item class="pa-4">
        <template v-slot:prepend>
          <v-card-title class="d-flex align-center">
            <v-icon
              :icon="icon || 'mdi-server'"
              :color="statusConfig.color"
              size="20"
              class="mr-2"
            />
            <span class="text-h6 font-weight-bold">{{ name }}</span>
          </v-card-title>
        </template>

        <v-divider class="mx-3" vertical />

        <!-- Indicateur de statut moderne -->
        <v-chip
          :color="statusConfig.color"
          :prepend-icon="statusConfig.icon"
          variant="tonal"
          size="small"
          class="text-caption font-weight-medium"
        >
          {{ statusConfig.label }}
        </v-chip>

        <template v-slot:append>
          <v-btn
            v-if="url"
            :href="url"
            target="_blank"
            icon="mdi-open-in-new"
            size="large"
            variant="text"
            :color="statusConfig.color"
          />
        </template>
      </v-card-item>
    </v-sheet>

    <!-- Contenu principal -->
    <v-card
      class="ma-4"
      color="surface"
      rounded="lg"
      variant="flat"
      elevation="1"
    >
      <v-card-item class="pa-4">
        <!-- Informations du service -->
        <v-card-title class="text-body-2 d-flex align-center pa-0">
          <v-icon
            :color="categoryColor"
            :icon="categoryIcon"
            size="16"
            class="mr-2"
          />
          
          <span class="text-medium-emphasis font-weight-bold text-caption text-uppercase">
            {{ category || 'Service' }}
          </span>

          <v-spacer />

          <!-- Version/Port si disponible -->
          <v-chip
            v-if="version || port"
            class="text-caption"
            color="surface-variant"
            size="x-small"
            variant="flat"
          >
            {{ version || `Port ${port}` }}
          </v-chip>
        </v-card-title>

        <!-- Description -->
        <div class="py-3">
          <div class="text-subtitle-1 font-weight-medium mb-1">
            {{ displayName || name }}
          </div>
          
          <div class="font-weight-light text-medium-emphasis text-body-2">
            {{ description || 'Service de l\'écosystème Redriva' }}
          </div>
        </div>

        <!-- Métriques si disponibles -->
        <div v-if="metrics" class="d-flex align-center gap-3 mt-2">
          <div v-if="metrics.cpu" class="d-flex align-center">
            <v-icon icon="mdi-cpu-64-bit" size="14" class="mr-1 text-medium-emphasis" />
            <span class="text-caption text-medium-emphasis">{{ metrics.cpu }}%</span>
          </div>
          <div v-if="metrics.memory" class="d-flex align-center">
            <v-icon icon="mdi-memory" size="14" class="mr-1 text-medium-emphasis" />
            <span class="text-caption text-medium-emphasis">{{ metrics.memory }}</span>
          </div>
          <div v-if="metrics.uptime" class="d-flex align-center">
            <v-icon icon="mdi-clock-outline" size="14" class="mr-1 text-medium-emphasis" />
            <span class="text-caption text-medium-emphasis">{{ metrics.uptime }}</span>
          </div>
        </div>
      </v-card-item>

      <v-divider />

      <!-- Actions -->
      <div class="pa-4 d-flex align-center">
        <v-icon
          color="disabled"
          icon="mdi-cog"
          size="20"
          class="mr-2"
        />

        <v-icon
          :color="statusConfig.color"
          :icon="status === 'online' ? 'mdi-play-circle' : 'mdi-pause-circle'"
          size="16"
        />

        <span class="text-caption text-medium-emphasis ms-1 font-weight-light">
          {{ status === 'online' ? 'En fonctionnement' : 'Arrêté' }}
        </span>

        <v-spacer />

        <!-- Bouton menu options -->
        <v-menu>
          <template v-slot:activator="{ props }">
            <v-btn
              v-bind="props"
              icon="mdi-dots-horizontal"
              variant="text"
              size="small"
            />
          </template>
          <v-list density="compact">
            <v-list-item @click="handleViewLogs" prepend-icon="mdi-text-box-outline">
              <v-list-item-title>Voir les logs</v-list-item-title>
            </v-list-item>
            <v-list-item @click="handleViewConfig" prepend-icon="mdi-cog-outline">
              <v-list-item-title>Configuration</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>

        <!-- Bouton Reset (si en ligne) -->
        <v-btn
          v-if="status === 'online'"
          class="me-2 text-none"
          color="warning"
          prepend-icon="mdi-restart"
          variant="tonal"
          size="small"
          @click="handleRestart"
        >
          Reset
        </v-btn>

        <!-- Bouton principal Start/Stop -->
        <v-btn
          class="text-none"
          :prepend-icon="status === 'online' ? 'mdi-stop' : 'mdi-play'"
          :color="status === 'online' ? 'error' : 'success'"
          variant="flat"
          size="small"
          @click="handleToggleService"
        >
          {{ status === 'online' ? 'Stop' : 'Start' }}
        </v-btn>
      </div>
    </v-card>
  </v-card>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface ServiceCardProps {
  name: string
  description?: string
  status: 'online' | 'offline' | 'warning' | 'maintenance'
  url?: string
  port?: number
  version?: string
  icon?: string
  category?: string
  displayName?: string
  responseTime?: number
  metrics?: {
    cpu?: number
    memory?: string
    uptime?: string
  }
}

const props = withDefaults(defineProps<ServiceCardProps>(), {
  status: 'offline'
})

const emit = defineEmits<{
  start: [serviceName: string]
  stop: [serviceName: string]
  restart: [serviceName: string]
  viewLogs: [serviceName: string]
  viewConfig: [serviceName: string]
}>()

// Configuration des statuts avec style Discord
const statusConfigs = {
  online: {
    color: 'success',
    variant: 'elevated',
    icon: 'mdi-check-circle',
    label: 'En ligne'
  },
  offline: {
    color: 'error', 
    variant: 'elevated',
    icon: 'mdi-close-circle',
    label: 'Hors ligne'
  },
  warning: {
    color: 'warning',
    variant: 'elevated', 
    icon: 'mdi-alert-circle',
    label: 'Attention'
  },
  maintenance: {
    color: 'info',
    variant: 'elevated',
    icon: 'mdi-wrench',
    label: 'Maintenance'
  }
}

const statusConfig = computed(() => statusConfigs[props.status])

// Couleur de l'en-tête basée sur le statut
const headerColor = computed(() => {
  switch (props.status) {
    case 'online': return 'surface-bright'
    case 'warning': return 'warning-lighten-4'
    case 'offline': return 'error-lighten-4'
    case 'maintenance': return 'info-lighten-4'
    default: return 'surface-variant'
  }
})

// Couleur et icône de catégorie
const categoryColor = computed(() => {
  const categoryColors: Record<string, string> = {
    'download': 'blue',
    'media': 'purple',
    'system': 'orange',
    'security': 'red',
    'monitoring': 'green'
  }
  return categoryColors[props.category || 'system'] || 'primary'
})

const categoryIcon = computed(() => {
  const categoryIcons: Record<string, string> = {
    'download': 'mdi-download',
    'media': 'mdi-play-circle',
    'system': 'mdi-server',
    'security': 'mdi-shield',
    'monitoring': 'mdi-chart-line'
  }
  return categoryIcons[props.category || 'system'] || 'mdi-server'
})

// Gestionnaires d'événements
const handleToggleService = () => {
  if (props.status === 'online') {
    emit('stop', props.name)
  } else {
    emit('start', props.name)
  }
}

const handleRestart = () => emit('restart', props.name)
const handleViewLogs = () => emit('viewLogs', props.name)
const handleViewConfig = () => emit('viewConfig', props.name)
</script>
