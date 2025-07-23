<template>
  <v-snackbar
    v-for="notification in notifications"
    :key="notification.id"
    v-model="snackbarStates[notification.id]"
    :color="getColor(notification.type)"
    :timeout="notification.duration || -1"
    location="top right"
    variant="elevated"
    multi-line
    @update:model-value="handleClose(notification.id, $event)"
  >
    <div class="d-flex align-center">
      <v-icon 
        :icon="getIcon(notification.type)" 
        size="20" 
        class="mr-2" 
      />
      <div class="flex-grow-1">
        <div class="font-weight-bold">{{ notification.title }}</div>
        <div class="text-body-2">{{ notification.message }}</div>
      </div>
      <v-btn
        icon="mdi-close"
        size="small"
        variant="text"
        @click="removeNotification(notification.id)"
      />
    </div>
  </v-snackbar>
</template>

<script setup lang="ts">
import { computed, reactive, watch } from 'vue'
import { useNotificationStore } from '@/composables/useNotificationStore'

const { notifications, remove } = useNotificationStore()

// État local pour gérer les snackbars
const snackbarStates = reactive<Record<string, boolean>>({})

// Synchroniser les états des snackbars avec les notifications
watch(notifications, (newNotifications) => {
  // Ajouter les nouvelles notifications
  newNotifications.forEach(notification => {
    if (!(notification.id in snackbarStates)) {
      snackbarStates[notification.id] = true
    }
  })
  
  // Nettoyer les anciennes
  Object.keys(snackbarStates).forEach(id => {
    if (!newNotifications.find(n => n.id === id)) {
      delete snackbarStates[id]
    }
  })
}, { immediate: true })

const getColor = (type: string) => {
  switch (type) {
    case 'success': return 'success'
    case 'error': return 'error'
    case 'warning': return 'warning'
    case 'info': return 'info'
    default: return 'info'
  }
}

const getIcon = (type: string) => {
  switch (type) {
    case 'success': return 'mdi-check-circle'
    case 'error': return 'mdi-alert-circle'
    case 'warning': return 'mdi-alert'
    case 'info': return 'mdi-information'
    default: return 'mdi-information'
  }
}

const removeNotification = (id: string) => {
  snackbarStates[id] = false
  setTimeout(() => remove(id), 300) // Délai pour l'animation
}

const handleClose = (id: string, isOpen: boolean) => {
  if (!isOpen) {
    removeNotification(id)
  }
}
</script>

<style scoped>
.v-snackbar {
  margin-bottom: 8px;
}
</style>
