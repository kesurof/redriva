<template>
  <v-card 
    class="elevation-hover"
    style="transition: all 0.2s cubic-bezier(0.25, 0.8, 0.25, 1)"
  >
    <v-card-text class="pa-6">
      <div class="d-flex align-start" style="gap: 16px;">
        <!-- Icône -->
        <div v-if="showIcon" class="flex-shrink-0 mt-1">
          <v-avatar
            size="40"
            color="primary"
            variant="tonal"
          >
            <v-icon :icon="resolvedIcon" size="20" />
          </v-avatar>
        </div>
        
        <!-- Contenu principal -->
        <div class="flex-grow-1">
          <!-- En-tête -->
          <div class="mb-3">
            <div class="d-flex align-center mb-1" style="gap: 8px;">
              <h3 class="text-h6 font-weight-medium">{{ title }}</h3>
              
              <!-- Catégorie -->
              <v-chip
                v-if="category"
                size="x-small"
                variant="outlined"
                color="secondary"
              >
                {{ category }}
              </v-chip>
              
              <!-- Indicateur requis -->
              <span v-if="required" class="text-error">*</span>
            </div>
            
            <!-- Description -->
            <p 
              v-if="description"
              class="text-body-2 text-medium-emphasis mb-0"
            >
              {{ description }}
            </p>
          </div>
          
          <!-- Champ de saisie -->
          <div class="mt-2">
            <!-- Toggle/Switch -->
            <v-switch
              v-if="type === 'toggle'"
              v-model="internalValue"
              :disabled="disabled"
              :label="switchLabel"
              color="primary"
              hide-details
              @update:model-value="handleChange"
            />
            
            <!-- Select -->
            <v-select
              v-else-if="type === 'select'"
              v-model="internalValue"
              :items="options"
              :disabled="disabled"
              :required="required"
              :placeholder="placeholder || 'Sélectionner une option...'"
              item-title="label"
              item-value="value"
              variant="outlined"
              density="compact"
              hide-details
              @update:model-value="handleChange"
            />
            
            <!-- Textarea -->
            <v-textarea
              v-else-if="type === 'textarea'"
              v-model="internalValue"
              :disabled="disabled"
              :required="required"
              :placeholder="placeholder"
              variant="outlined"
              density="compact"
              rows="3"
              hide-details
              @update:model-value="handleChange"
            />
            
            <!-- Number -->
            <v-text-field
              v-else-if="type === 'number'"
              v-model.number="internalValue"
              type="number"
              :disabled="disabled"
              :required="required"
              :placeholder="placeholder"
              :min="min"
              :max="max"
              variant="outlined"
              density="compact"
              hide-details
              @update:model-value="handleChange"
            />
            
            <!-- Password -->
            <v-text-field
              v-else-if="type === 'password'"
              v-model="internalValue"
              :type="showPassword ? 'text' : 'password'"
              :disabled="disabled"
              :required="required"
              :placeholder="placeholder"
              :append-inner-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
              variant="outlined"
              density="compact"
              hide-details
              @click:append-inner="showPassword = !showPassword"
              @update:model-value="handleChange"
            />
            
            <!-- Text (par défaut) -->
            <v-text-field
              v-else
              v-model="internalValue"
              :disabled="disabled"
              :required="required"
              :placeholder="placeholder"
              variant="outlined"
              density="compact"
              hide-details
              @update:model-value="handleChange"
            />
          </div>
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'

export interface SettingCardOption {
  label: string
  value: any
}

export interface SettingCardProps {
  title: string
  description?: string
  category?: string
  type?: 'toggle' | 'input' | 'select' | 'number' | 'password' | 'textarea'
  value?: any
  options?: SettingCardOption[]
  placeholder?: string
  disabled?: boolean
  required?: boolean
  min?: number
  max?: number
  icon?: string
}

const props = withDefaults(defineProps<SettingCardProps>(), {
  description: '',
  category: '',
  type: 'input',
  value: '',
  options: () => [],
  placeholder: '',
  disabled: false,
  required: false,
  min: undefined,
  max: undefined,
  icon: ''
})

const emit = defineEmits<{
  'update:value': [value: any]
  change: [{ value: any }]
}>()

// État interne pour la visibilité du mot de passe
const showPassword = ref(false)

// Valeur interne réactive
const internalValue = ref(props.value)

// Synchroniser avec la prop value
watch(() => props.value, (newValue) => {
  internalValue.value = newValue
}, { immediate: true })

// Mapping des icônes
const iconMappings: Record<string, string> = {
  api: 'mdi-api',
  download: 'mdi-download',
  folder: 'mdi-folder',
  security: 'mdi-shield-check',
  notification: 'mdi-bell',
  theme: 'mdi-theme-light-dark',
  storage: 'mdi-harddisk',
  network: 'mdi-network',
  settings: 'mdi-cog',
  user: 'mdi-account',
  database: 'mdi-database'
}

// Propriétés calculées
const resolvedIcon = computed(() => {
  return iconMappings[props.icon] || props.icon || 'mdi-cog'
})

const showIcon = computed(() => Boolean(props.icon))

const switchLabel = computed(() => {
  return internalValue.value ? 'Activé' : 'Désactivé'
})

// Gestionnaire de changement
const handleChange = (newValue: any) => {
  let processedValue = newValue
  
  // Traitement spécial pour les nombres
  if (props.type === 'number') {
    processedValue = parseFloat(newValue) || 0
  }
  
  internalValue.value = processedValue
  emit('update:value', processedValue)
  emit('change', { value: processedValue })
}
</script>


