<template>
  <v-card
    class="service-card"
    :ripple="false"
    hover
  >
    <v-card-text class="pa-6">
      <div class="d-flex align-start justify-space-between">
        <div class="flex-grow-1">
          <!-- Header avec nom et statut -->
          <div class="d-flex align-center mb-3" style="gap: 12px;">
            <h3 class="text-h6 font-weight-medium">{{ name }}</h3>
            <v-chip
              :color="statusConfig.color"
              :prepend-icon="statusConfig.icon"
              :variant="statusConfig.variant"
              size="small"
            >
              {{ statusConfig.label }}
            </v-chip>
          </div>
          
          <!-- Description -->
          <p 
            v-if="description"
            class="text-body-2 text-medium-emphasis mb-3"
          >
            {{ description }}
          </p>
          
          <!-- Métadonnées -->
          <div class="d-flex flex-column" style="gap: 8px;">
            <!-- Version -->
            <div 
              v-if="version"
              class="d-flex align-center text-caption text-medium-emphasis"
              style="gap: 8px;"
            >
              <v-icon icon="mdi-information" size="12" />
              <span>Version: {{ version }}</span>
            </div>
            
            <!-- Temps de réponse -->
            <div 
              v-if="responseTime !== undefined"
              class="d-flex align-center text-caption"
              :class="responseTimeClass"
              style="gap: 8px;"
            >
              <v-icon icon="mdi-clock-outline" size="12" />
              <span>Temps de réponse: {{ responseTime }}ms</span>
            </div>
            
            <!-- Dernière vérification -->
            <div 
              v-if="lastCheck"
              class="d-flex align-center text-caption text-medium-emphasis"
              style="gap: 8px;"
            >
              <v-icon icon="mdi-clock-check-outline" size="12" />
              <span>Dernière vérification: {{ formattedLastCheck }}</span>
            </div>
          </div>
        </div>
        
        <!-- Actions -->
        <div class="d-flex flex-column ml-4" style="gap: 8px;">
          <!-- Bouton ouvrir -->
          <v-btn
            v-if="url"
            :href="url"
            target="_blank"
            size="small"
            variant="outlined"
            prepend-icon="mdi-open-in-new"
          >
            Ouvrir
          </v-btn>
          
          <!-- Bouton tester -->
          <v-btn
            size="small"
            variant="outlined"
            prepend-icon="mdi-refresh"
            @click="handleTest"
          >
            Tester
          </v-btn>
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface ServiceCardProps {
  name: string
  description?: string
  status?: 'online' | 'offline' | 'warning' | 'maintenance'
  url?: string
  version?: string
  lastCheck?: string
  responseTime?: number
}

const props = withDefaults(defineProps<ServiceCardProps>(), {
  description: '',
  status: 'offline',
  url: '',
  version: '',
  lastCheck: '',
  responseTime: undefined
})

const emit = defineEmits<{
  test: [serviceName: string]
}>()

// Configuration des statuts
const statusConfigs = {
  online: {
    color: 'success',
    variant: 'elevated' as const,
    icon: 'mdi-check-circle',
    label: 'En ligne'
  },
  offline: {
    color: 'error',
    variant: 'elevated' as const,
    icon: 'mdi-close-circle',
    label: 'Hors ligne'
  },
  warning: {
    color: 'warning',
    variant: 'elevated' as const,
    icon: 'mdi-alert',
    label: 'Avertissement'
  },
  maintenance: {
    color: 'info',
    variant: 'elevated' as const,
    icon: 'mdi-cog',
    label: 'Maintenance'
  }
}

const statusConfig = computed(() => statusConfigs[props.status])

// Couleur du temps de réponse basée sur la performance
const responseTimeClass = computed(() => {
  if (props.responseTime === undefined) return 'text-medium-emphasis'
  
  if (props.responseTime < 100) return 'text-success'
  if (props.responseTime < 500) return 'text-warning'
  return 'text-error'
})

// Formatage de la dernière vérification
const formattedLastCheck = computed(() => {
  if (!props.lastCheck) return 'Jamais'
  
  try {
    const date = new Date(props.lastCheck)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffMins = Math.floor(diffMs / 60000)
    
    if (diffMins < 1) return 'À l\'instant'
    if (diffMins < 60) return `Il y a ${diffMins} min`
    
    const diffHours = Math.floor(diffMins / 60)
    if (diffHours < 24) return `Il y a ${diffHours}h`
    
    return date.toLocaleDateString('fr-FR')
  } catch {
    return props.lastCheck
  }
})

// Gestionnaire de test
const handleTest = () => {
  emit('test', props.name)
}
</script>

<style scoped>
.service-card {
  transition: all 0.2s ease-in-out;
}

.service-card:hover {
  transform: translateY(-2px);
}
</style>
