/**
 * Composable pour la gestion de l'état global de l'application
 * Équivalent du store app.ts de Svelte
 */
import { ref, computed, reactive } from 'vue'

export interface SystemStatus {
  cpu_percent: number
  memory: {
    used: number
    total: number
    available: number
  }
  disk: {
    used: number
    total: number
    free: number
  }
  uptime: string
  load_average?: number[]
  boot_time?: string
  network?: {
    bytes_sent: number
    bytes_recv: number
  }
}

export interface AppState {
  isLoading: boolean
  systemStatus: SystemStatus | null
  lastUpdated: Date | null
  error: string | null
}

// État réactif global
const appState = reactive<AppState>({
  isLoading: false,
  systemStatus: null,
  lastUpdated: null,
  error: null
})

export function useAppStore() {
  // Computed properties (équivalent aux derived stores)
  const isLoading = computed(() => appState.isLoading)
  const systemStatus = computed(() => appState.systemStatus)
  const lastUpdated = computed(() => appState.lastUpdated)
  const error = computed(() => appState.error)

  // Actions
  const setLoading = (loading: boolean) => {
    appState.isLoading = loading
  }

  const updateSystemStatus = (status: SystemStatus) => {
    appState.systemStatus = status
    appState.lastUpdated = new Date()
    appState.error = null
  }

  const setError = (errorMessage: string) => {
    appState.error = errorMessage
    appState.isLoading = false
  }

  const clearError = () => {
    appState.error = null
  }

  const refreshSystemStatus = async () => {
    setLoading(true)
    
    try {
      const response = await fetch('/api/system')
      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`)
      }
      
      const status = await response.json()
      updateSystemStatus(status)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue')
    } finally {
      setLoading(false)
    }
  }

  // Getters pour l'état
  const getState = () => ({ ...appState })

  return {
    // State
    isLoading,
    systemStatus,
    lastUpdated,
    error,
    
    // Actions
    setLoading,
    updateSystemStatus,
    setError,
    clearError,
    refreshSystemStatus,
    getState
  }
}
