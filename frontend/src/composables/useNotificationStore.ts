/**
 * Composable pour la gestion des notifications
 * Équivalent du store notifications.ts de Svelte
 */
import { ref, computed, reactive } from 'vue'

export interface Notification {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message: string
  duration?: number // en millisecondes, undefined = permanente
  timestamp: Date
}

// État réactif global
const notifications = ref<Notification[]>([])

export function useNotificationStore() {
  // Computed properties
  const allNotifications = computed(() => notifications.value)
  const hasNotifications = computed(() => notifications.value.length > 0)
  const errorNotifications = computed(() => 
    notifications.value.filter(n => n.type === 'error')
  )
  const successNotifications = computed(() => 
    notifications.value.filter(n => n.type === 'success')
  )

  // Actions
  const add = (notification: Omit<Notification, 'id' | 'timestamp'>) => {
    const newNotification: Notification = {
      ...notification,
      id: crypto.randomUUID(),
      timestamp: new Date()
    }

    notifications.value.push(newNotification)

    // Auto-suppression si durée spécifiée
    if (newNotification.duration) {
      setTimeout(() => {
        remove(newNotification.id)
      }, newNotification.duration)
    }

    return newNotification.id
  }

  const remove = (id: string) => {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index > -1) {
      notifications.value.splice(index, 1)
    }
  }

  const clear = () => {
    notifications.value = []
  }

  // Méthodes de raccourci
  const success = (title: string, message: string, duration: number = 5000) => {
    return add({ type: 'success', title, message, duration })
  }

  const error = (title: string, message: string, duration?: number) => {
    return add({ type: 'error', title, message, duration })
  }

  const warning = (title: string, message: string, duration: number = 7000) => {
    return add({ type: 'warning', title, message, duration })
  }

  const info = (title: string, message: string, duration: number = 5000) => {
    return add({ type: 'info', title, message, duration })
  }

  return {
    // State
    notifications: allNotifications,
    hasNotifications,
    errorNotifications,
    successNotifications,
    
    // Actions
    add,
    remove,
    clear,
    success,
    error,
    warning,
    info
  }
}
