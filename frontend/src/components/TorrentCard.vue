<template>
  <v-card 
    elevation="2" 
    rounded="lg"
    class="elevation-hover"
    style="transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1)"
    hover
  >
    <!-- En-tête avec nom, statut et priorité -->
    <v-card-title class="pb-2">
      <div class="d-flex align-start justify-space-between w-100">
        <div class="flex-grow-1 text-truncate">
          <h3 
            class="text-h6 text-truncate mb-1" 
            :title="name"
          >
            {{ name }}
          </h3>
          <div class="d-flex align-center" style="gap: 8px;">
            <!-- Statut -->
            <v-chip
              :color="statusConfig.color"
              :prepend-icon="statusConfig.icon"
              size="small"
              variant="flat"
            >
              {{ statusConfig.label }}
            </v-chip>
            
            <!-- Priorité -->
            <v-chip
              v-if="priority && priority !== 'normal'"
              :color="priorityConfig.color"
              size="x-small"
              variant="elevated"
            >
              {{ priority.toUpperCase() }}
            </v-chip>
          </div>
        </div>
        
        <!-- Taille et progression -->
        <div class="text-right">
          <div class="text-body-2 text-medium-emphasis">{{ size }}</div>
          <div 
            v-if="progress < 100"
            class="text-body-2 font-weight-medium"
          >
            {{ progress }}%
          </div>
        </div>
      </div>
    </v-card-title>

    <!-- Corps avec barre de progression et détails -->
    <v-card-text class="pt-0">
      <!-- Barre de progression -->
      <v-progress-linear
        :model-value="progress"
        :color="progressColor"
        height="8"
        rounded
        class="mb-4"
      />

      <!-- Informations détaillées -->
      <v-row v-if="hasDetailedInfo" dense>
        <!-- Vitesse de téléchargement -->
        <v-col v-if="downloadSpeed" cols="6" md="3">
          <div class="text-caption text-medium-emphasis mb-1">
            Téléchargement
          </div>
          <div class="text-body-2 font-weight-medium text-primary">
            <v-icon icon="mdi-download" size="12" class="mr-1" />
            {{ downloadSpeed }}
          </div>
        </v-col>

        <!-- Vitesse d'upload -->
        <v-col v-if="uploadSpeed" cols="6" md="3">
          <div class="text-caption text-medium-emphasis mb-1">
            Upload
          </div>
          <div class="text-body-2 font-weight-medium text-secondary">
            <v-icon icon="mdi-upload" size="12" class="mr-1" />
            {{ uploadSpeed }}
          </div>
        </v-col>

        <!-- Temps restant -->
        <v-col v-if="eta && status === 'downloading'" cols="6" md="3">
          <div class="text-caption text-medium-emphasis mb-1">
            Temps restant
          </div>
          <div class="text-body-2 font-weight-medium">
            <v-icon icon="mdi-clock-outline" size="12" class="mr-1" />
            {{ eta }}
          </div>
        </v-col>

        <!-- Sources (seeders/leechers) -->
        <v-col v-if="hasSeeders || hasLeechers" cols="6" md="3">
          <div class="text-caption text-medium-emphasis mb-1">
            Sources
          </div>
          <div class="text-body-2 font-weight-medium">
            <span v-if="hasSeeders" class="text-success">
              <v-icon icon="mdi-account-group" size="12" class="mr-1" />
              {{ seeders }}
            </span>
            <span v-if="hasLeechers" :class="hasSeeders ? 'ml-2' : ''">
              <v-icon icon="mdi-download-outline" size="12" class="mr-1" />
              {{ leechers }}
            </span>
          </div>
        </v-col>
      </v-row>
    </v-card-text>

    <!-- Actions -->
    <v-card-actions class="justify-end">
      <!-- Bouton pause/reprendre -->
      <v-btn
        v-if="status === 'downloading'"
        size="small"
        variant="outlined"
        color="warning"
        prepend-icon="mdi-pause"
        @click="handlePause"
      >
        Pause
      </v-btn>
      
      <v-btn
        v-else-if="status === 'paused'"
        size="small"
        variant="outlined" 
        color="primary"
        prepend-icon="mdi-play"
        @click="handleResume"
      >
        Reprendre
      </v-btn>

      <!-- Bouton ouvrir (si terminé) -->
      <v-btn
        v-if="status === 'completed'"
        size="small"
        variant="outlined"
        color="success"
        prepend-icon="mdi-folder-open"
        @click="handleOpen"
      >
        Ouvrir
      </v-btn>

      <!-- Bouton supprimer -->
      <v-btn
        size="small"
        variant="outlined"
        color="error"
        prepend-icon="mdi-delete"
        @click="handleDelete"
      >
        Supprimer
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface TorrentCardProps {
  id: string
  name: string
  status: 'downloading' | 'completed' | 'paused' | 'error' | 'waiting'
  progress: number
  size: string
  downloadSpeed?: string
  uploadSpeed?: string
  eta?: string
  seeders?: number
  leechers?: number
  priority?: 'low' | 'normal' | 'high'
}

const props = withDefaults(defineProps<TorrentCardProps>(), {
  downloadSpeed: undefined,
  uploadSpeed: undefined,
  eta: undefined,
  seeders: undefined,
  leechers: undefined,
  priority: 'normal'
})

const emit = defineEmits<{
  pause: [id: string]
  resume: [id: string]
  open: [id: string]
  delete: [id: string]
}>()

// Configuration des statuts
const statusConfigs = {
  downloading: {
    color: 'primary',
    icon: 'mdi-download',
    label: 'Téléchargement'
  },
  completed: {
    color: 'success',
    icon: 'mdi-check-circle',
    label: 'Terminé'
  },
  paused: {
    color: 'warning',
    icon: 'mdi-pause-circle',
    label: 'En pause'
  },
  error: {
    color: 'error',
    icon: 'mdi-alert-circle',
    label: 'Erreur'
  },
  waiting: {
    color: 'info',
    icon: 'mdi-clock-outline',
    label: 'En attente'
  }
}

// Configuration des priorités
const priorityConfigs = {
  high: { color: 'error' },
  normal: { color: 'primary' },
  low: { color: 'info' }
}

const statusConfig = computed(() => statusConfigs[props.status])
const priorityConfig = computed(() => priorityConfigs[props.priority])

// Couleur de la barre de progression
const progressColor = computed(() => {
  switch (props.status) {
    case 'completed': return 'success'
    case 'error': return 'error' 
    case 'paused': return 'warning'
    default: return 'primary'
  }
})

// Helpers pour l'affichage conditionnel
const hasDetailedInfo = computed(() => 
  props.downloadSpeed || props.uploadSpeed || props.eta || 
  props.seeders !== undefined || props.leechers !== undefined
)

const hasSeeders = computed(() => props.seeders !== undefined)
const hasLeechers = computed(() => props.leechers !== undefined)

// Gestionnaires d'événements
const handlePause = () => emit('pause', props.id)
const handleResume = () => emit('resume', props.id)
const handleOpen = () => emit('open', props.id)
const handleDelete = () => emit('delete', props.id)
</script>


