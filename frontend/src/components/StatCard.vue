<template>
  <v-card
    :class="cardClasses"
    :variant="cardVariant"
    :color="cardColor"
  >
    <v-card-text :class="paddingClass">
      <div class="d-flex align-center justify-space-between">
        <div class="flex-grow-1">
          <!-- Titre -->
          <h3 
            :class="titleClasses"
            class="text-uppercase tracking-wide text-medium-emphasis"
          >
            {{ title }}
          </h3>
          
          <!-- Valeur principale et métadonnées -->
          <div class="d-flex align-baseline mt-1" style="gap: 8px;">
            <span 
              :class="valueClasses"
              class="font-weight-bold text-high-emphasis"
            >
              {{ formattedValue }}
            </span>
            
            <!-- Sous-titre -->
            <span 
              v-if="subtitle"
              class="text-caption text-medium-emphasis"
            >
              {{ subtitle }}
            </span>
            
            <!-- Indicateur de tendance -->
            <div 
              v-if="trend && trendValue"
              class="d-flex align-center text-caption"
              :class="trendColorClass"
              style="gap: 4px;"
            >
              <v-icon 
                :icon="trendIcon" 
                size="12"
              />
              {{ trendValue }}
            </div>
          </div>
          
          <!-- Barre de progression -->
          <div v-if="progress !== undefined" class="mt-3">
            <v-progress-linear
              :model-value="clampedProgress"
              :color="progressColor"
              height="6"
              rounded
              class="mb-1"
            />
            <span class="text-caption text-medium-emphasis">
              {{ clampedProgress }}%
            </span>
          </div>
        </div>
        
        <!-- Icône -->
        <div 
          v-if="showIcon"
          class="flex-shrink-0 ml-4"
        >
          <v-avatar
            :size="iconSize"
            :color="iconBackgroundColor"
            variant="tonal"
          >
            <v-icon 
              :icon="resolvedIcon"
              :size="iconInnerSize"
              :color="iconColor"
            />
          </v-avatar>
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface StatCardProps {
  title: string
  value: string | number
  subtitle?: string
  icon?: string
  variant?: 'primary' | 'secondary' | 'success' | 'warning' | 'error' | 'info'
  trend?: 'up' | 'down' | 'stable' | 'neutral'
  trendValue?: string
  progress?: number
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<StatCardProps>(), {
  subtitle: '',
  icon: '',
  variant: 'primary',
  trend: undefined,
  trendValue: '',
  progress: undefined,
  size: 'md'
})

// Mapping des icônes prédéfinies
const iconMappings: Record<string, string> = {
  cpu: 'mdi-cpu-64-bit',
  memory: 'mdi-memory',
  storage: 'mdi-harddisk',
  system: 'mdi-cog',
  download: 'mdi-download',
  queue: 'mdi-playlist-check',
  data: 'mdi-database',
  network: 'mdi-network',
  upload: 'mdi-upload',
  users: 'mdi-account-group',
  files: 'mdi-file-multiple',
  speed: 'mdi-speedometer'
}

// Classes et styles calculés
const sizeConfig = computed(() => {
  switch (props.size) {
    case 'sm':
      return {
        padding: 'pa-3',
        titleClass: 'text-caption',
        valueClass: 'text-h6',
        iconSize: 32,
        iconInnerSize: 16
      }
    case 'lg':
      return {
        padding: 'pa-6',
        titleClass: 'text-body-1',
        valueClass: 'text-h3',
        iconSize: 56,
        iconInnerSize: 28
      }
    default:
      return {
        padding: 'pa-4',
        titleClass: 'text-body-2',
        valueClass: 'text-h4',
        iconSize: 40,
        iconInnerSize: 20
      }
  }
})

const paddingClass = computed(() => sizeConfig.value.padding)
const titleClasses = computed(() => sizeConfig.value.titleClass)
const valueClasses = computed(() => sizeConfig.value.valueClass)
const iconSize = computed(() => sizeConfig.value.iconSize)
const iconInnerSize = computed(() => sizeConfig.value.iconInnerSize)

// Couleurs basées sur la variante
const variantConfig = computed(() => {
  switch (props.variant) {
    case 'success':
      return {
        cardColor: 'success',
        iconColor: 'success',
        progressColor: 'success'
      }
    case 'warning':
      return {
        cardColor: 'warning',
        iconColor: 'warning',
        progressColor: 'warning'
      }
    case 'error':
      return {
        cardColor: 'error',
        iconColor: 'error',
        progressColor: 'error'
      }
    case 'info':
      return {
        cardColor: 'info',
        iconColor: 'info',
        progressColor: 'info'
      }
    case 'secondary':
      return {
        cardColor: 'secondary',
        iconColor: 'secondary',
        progressColor: 'secondary'
      }
    default:
      return {
        cardColor: 'primary',
        iconColor: 'primary',
        progressColor: 'primary'
      }
  }
})

const cardClasses = computed(() => 'stat-card')
const cardVariant = computed(() => 'tonal')
const cardColor = computed(() => variantConfig.value.cardColor)
const iconColor = computed(() => variantConfig.value.iconColor)
const iconBackgroundColor = computed(() => variantConfig.value.cardColor)
const progressColor = computed(() => variantConfig.value.progressColor)

// Gestion des tendances
const trendIcon = computed(() => {
  switch (props.trend) {
    case 'up':
      return 'mdi-trending-up'
    case 'down':
      return 'mdi-trending-down'
    case 'stable':
    case 'neutral':
      return 'mdi-trending-neutral'
    default:
      return ''
  }
})

const trendColorClass = computed(() => {
  switch (props.trend) {
    case 'up':
      return 'text-success'
    case 'down':
      return 'text-error'
    case 'stable':
    case 'neutral':
      return 'text-medium-emphasis'
    default:
      return ''
  }
})

// Icône résolue
const resolvedIcon = computed(() => {
  return iconMappings[props.icon] || props.icon || 'mdi-information'
})

const showIcon = computed(() => Boolean(props.icon))

// Valeur formatée
const formattedValue = computed(() => {
  if (typeof props.value === 'number') {
    // Formatage des nombres avec séparateurs de milliers
    return new Intl.NumberFormat('fr-FR').format(props.value)
  }
  return props.value
})

// Progression contrainte
const clampedProgress = computed(() => {
  if (props.progress === undefined) return 0
  return Math.min(Math.max(props.progress, 0), 100)
})
</script>

<style scoped>
.stat-card {
  transition: all 0.2s ease-in-out;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.tracking-wide {
  letter-spacing: 0.025em;
}
</style>
