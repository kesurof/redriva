/**
 * Composable pour la gestion des torrents, queue et données principales
 * Équivalent du store stores.ts de Svelte
 */
import { ref, computed, reactive } from 'vue'

export interface Torrent {
  id: string
  name: string
  title: string
  status: 'downloading' | 'completed' | 'paused' | 'error'
  size: string
  progress: number
  category?: string
  downloadSpeed?: string
  uploadSpeed?: string
  eta?: string
  seeders?: number
  leechers?: number
}

export interface QueueItem {
  id: number
  torrent_id: string
  priority: 'low' | 'normal' | 'high'
  status: 'pending' | 'running' | 'completed' | 'failed'
  added_at: string
  updated_at: string
}

export interface SystemInfo {
  cpu_usage: number
  memory_usage: number
  disk_usage: number
  network_in: number
  network_out: number
  uptime: string
}

// État réactif global
const torrents = ref<Torrent[]>([])
const queue = ref<QueueItem[]>([])
const systemInfo = ref<SystemInfo | null>(null)
const isLoading = ref<boolean>(false)
const error = ref<string | null>(null)

// Filtres et UI
const searchQuery = ref<string>('')
const statusFilter = ref<string>('all')
const categoryFilter = ref<string>('all')
const sidebarOpen = ref<boolean>(false)

export function useDataStore() {
  // Computed properties (équivalent aux derived stores)
  const filteredTorrents = computed(() => {
    let filtered = torrents.value

    // Filtrage par recherche
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      filtered = filtered.filter(torrent =>
        torrent.name.toLowerCase().includes(query) ||
        torrent.title.toLowerCase().includes(query)
      )
    }

    // Filtrage par statut
    if (statusFilter.value !== 'all') {
      filtered = filtered.filter(torrent => torrent.status === statusFilter.value)
    }

    // Filtrage par catégorie
    if (categoryFilter.value !== 'all') {
      filtered = filtered.filter(torrent => torrent.category === categoryFilter.value)
    }

    return filtered
  })

  const activeDownloads = computed(() => 
    torrents.value.filter(t => t.status === 'downloading')
  )

  const completedTorrents = computed(() => 
    torrents.value.filter(t => t.status === 'completed')
  )

  const totalSize = computed(() => {
    const totalSizeInGB = torrents.value.reduce((total, torrent) => {
      const sizeMatch = torrent.size.match(/([\d.]+)\s*(GB|MB|TB)/)
      if (sizeMatch) {
        const value = parseFloat(sizeMatch[1])
        const unit = sizeMatch[2]
        switch (unit) {
          case 'TB': return total + (value * 1024)
          case 'GB': return total + value
          case 'MB': return total + (value / 1024)
          default: return total
        }
      }
      return total
    }, 0)
    
    return `${totalSizeInGB.toFixed(1)} GB`
  })

  // Actions pour les torrents
  const setTorrents = (newTorrents: Torrent[]) => {
    torrents.value = newTorrents
  }

  const addTorrent = (torrent: Torrent) => {
    torrents.value.push(torrent)
  }

  const updateTorrent = (id: string, updates: Partial<Torrent>) => {
    const index = torrents.value.findIndex(t => t.id === id)
    if (index > -1) {
      torrents.value[index] = { ...torrents.value[index], ...updates }
    }
  }

  const removeTorrent = (id: string) => {
    const index = torrents.value.findIndex(t => t.id === id)
    if (index > -1) {
      torrents.value.splice(index, 1)
    }
  }

  // Actions pour la queue
  const setQueue = (newQueue: QueueItem[]) => {
    queue.value = newQueue
  }

  const addToQueue = (item: QueueItem) => {
    queue.value.push(item)
  }

  const updateQueueItem = (id: number, updates: Partial<QueueItem>) => {
    const index = queue.value.findIndex(q => q.id === id)
    if (index > -1) {
      queue.value[index] = { ...queue.value[index], ...updates }
    }
  }

  const removeFromQueue = (id: number) => {
    const index = queue.value.findIndex(q => q.id === id)
    if (index > -1) {
      queue.value.splice(index, 1)
    }
  }

  // Actions pour les filtres
  const setSearchQuery = (query: string) => {
    searchQuery.value = query
  }

  const setStatusFilter = (status: string) => {
    statusFilter.value = status
  }

  const setCategoryFilter = (category: string) => {
    categoryFilter.value = category
  }

  // Actions pour l'état global
  const setError = (message: string) => {
    error.value = message
    setTimeout(() => {
      error.value = null
    }, 5000)
  }

  const clearError = () => {
    error.value = null
  }

  const setLoading = (loading: boolean) => {
    isLoading.value = loading
  }

  const setSystemInfo = (info: SystemInfo) => {
    systemInfo.value = info
  }

  // Actions pour l'UI
  const toggleSidebar = () => {
    sidebarOpen.value = !sidebarOpen.value
  }

  const setSidebarOpen = (open: boolean) => {
    sidebarOpen.value = open
  }

  return {
    // State
    torrents: computed(() => torrents.value),
    queue: computed(() => queue.value),
    systemInfo: computed(() => systemInfo.value),
    isLoading: computed(() => isLoading.value),
    error: computed(() => error.value),
    searchQuery: computed(() => searchQuery.value),
    statusFilter: computed(() => statusFilter.value),
    categoryFilter: computed(() => categoryFilter.value),
    sidebarOpen: computed(() => sidebarOpen.value),
    
    // Computed
    filteredTorrents,
    activeDownloads,
    completedTorrents,
    totalSize,
    
    // Actions - Torrents
    setTorrents,
    addTorrent,
    updateTorrent,
    removeTorrent,
    
    // Actions - Queue
    setQueue,
    addToQueue,
    updateQueueItem,
    removeFromQueue,
    
    // Actions - Filters
    setSearchQuery,
    setStatusFilter,
    setCategoryFilter,
    
    // Actions - Global state
    setError,
    clearError,
    setLoading,
    setSystemInfo,
    
    // Actions - UI
    toggleSidebar,
    setSidebarOpen
  }
}
