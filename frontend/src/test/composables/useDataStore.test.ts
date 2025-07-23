import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useDataStore, type Torrent, type QueueItem, type SystemInfo } from '@/composables/useDataStore'

describe('useDataStore', () => {
  let store: ReturnType<typeof useDataStore>

  beforeEach(() => {
    // Create a fresh store instance and reset state
    store = useDataStore()
    
    // Reset all state to initial values
    store.setTorrents([])
    store.setQueue([])
    store.setSystemInfo({
      cpu_usage: 0,
      memory_usage: 0,
      disk_usage: 0,
      network_in: 0,
      network_out: 0,
      uptime: '0'
    })
    store.setLoading(false)
    store.clearError()
    store.setSearchQuery('')
    store.setStatusFilter('all')
    store.setCategoryFilter('all')
    store.setSidebarOpen(false)
  })

  describe('Initial State', () => {
    it('should initialize with default values', () => {
      expect(store.torrents.value).toEqual([])
      expect(store.queue.value).toEqual([])
      expect(store.systemInfo.value).toBeDefined()
      expect(store.isLoading.value).toBe(false)
      expect(store.error.value).toBeNull()
      expect(store.searchQuery.value).toBe('')
      expect(store.statusFilter.value).toBe('all')
      expect(store.categoryFilter.value).toBe('all')
      expect(store.sidebarOpen.value).toBe(false)
    })

    it('should have empty computed properties initially', () => {
      expect(store.filteredTorrents.value).toEqual([])
      expect(store.activeDownloads.value).toEqual([])
      expect(store.completedTorrents.value).toEqual([])
      expect(store.totalSize.value).toBe('0.0 GB')
    })
  })

  describe('Torrent Management', () => {
    const mockTorrent: Torrent = {
      id: '1',
      name: 'test-torrent',
      title: 'Test Torrent',
      status: 'downloading',
      size: '1.5 GB',
      progress: 50,
      category: 'movies',
      downloadSpeed: '10 MB/s',
      uploadSpeed: '2 MB/s',
      eta: '5 min',
      seeders: 10,
      leechers: 5
    }

    it('should add torrents correctly', () => {
      store.addTorrent(mockTorrent)
      expect(store.torrents.value).toHaveLength(1)
      expect(store.torrents.value[0]).toEqual(mockTorrent)
    })

    it('should set multiple torrents', () => {
      const torrents = [mockTorrent, { ...mockTorrent, id: '2', name: 'test-2' }]
      store.setTorrents(torrents)
      expect(store.torrents.value).toHaveLength(2)
      expect(store.torrents.value).toEqual(torrents)
    })

    it('should update existing torrent', () => {
      store.addTorrent(mockTorrent)
      store.updateTorrent('1', { progress: 75, status: 'completed' })
      
      const updated = store.torrents.value[0]
      expect(updated.progress).toBe(75)
      expect(updated.status).toBe('completed')
      expect(updated.name).toBe(mockTorrent.name) // Other properties unchanged
    })

    it('should remove torrent by id', () => {
      store.addTorrent(mockTorrent)
      store.addTorrent({ ...mockTorrent, id: '2', name: 'test-2' })
      
      expect(store.torrents.value).toHaveLength(2)
      
      store.removeTorrent('1')
      expect(store.torrents.value).toHaveLength(1)
      expect(store.torrents.value[0].id).toBe('2')
    })

    it('should not fail when updating non-existent torrent', () => {
      store.updateTorrent('non-existent', { progress: 100 })
      expect(store.torrents.value).toHaveLength(0)
    })

    it('should not fail when removing non-existent torrent', () => {
      store.addTorrent(mockTorrent)
      store.removeTorrent('non-existent')
      expect(store.torrents.value).toHaveLength(1)
    })
  })

  describe('Queue Management', () => {
    const mockQueueItem: QueueItem = {
      id: 1,
      torrent_id: 'torrent-1',
      priority: 'normal',
      status: 'pending',
      added_at: '2024-01-01T10:00:00Z',
      updated_at: '2024-01-01T10:00:00Z'
    }

    it('should add items to queue', () => {
      store.addToQueue(mockQueueItem)
      expect(store.queue.value).toHaveLength(1)
      expect(store.queue.value[0]).toEqual(mockQueueItem)
    })

    it('should set entire queue', () => {
      const queueItems = [mockQueueItem, { ...mockQueueItem, id: 2, torrent_id: 'torrent-2' }]
      store.setQueue(queueItems)
      expect(store.queue.value).toHaveLength(2)
      expect(store.queue.value).toEqual(queueItems)
    })

    it('should update queue item', () => {
      store.addToQueue(mockQueueItem)
      store.updateQueueItem(1, { status: 'running', priority: 'high' })
      
      const updated = store.queue.value[0]
      expect(updated.status).toBe('running')
      expect(updated.priority).toBe('high')
      expect(updated.torrent_id).toBe(mockQueueItem.torrent_id) // Other properties unchanged
    })

    it('should remove queue item by id', () => {
      store.addToQueue(mockQueueItem)
      store.addToQueue({ ...mockQueueItem, id: 2, torrent_id: 'torrent-2' })
      
      expect(store.queue.value).toHaveLength(2)
      
      store.removeFromQueue(1)
      expect(store.queue.value).toHaveLength(1)
      expect(store.queue.value[0].id).toBe(2)
    })
  })

  describe('Filtering and Search', () => {
    beforeEach(() => {
      const torrents: Torrent[] = [
        {
          id: '1',
          name: 'movie-action',
          title: 'Action Movie',
          status: 'downloading',
          size: '2.0 GB',
          progress: 30,
          category: 'movies'
        },
        {
          id: '2',
          name: 'series-drama',
          title: 'Drama Series',
          status: 'completed',
          size: '1.5 GB',
          progress: 100,
          category: 'tv'
        },
        {
          id: '3',
          name: 'documentary',
          title: 'Nature Documentary',
          status: 'paused',
          size: '800 MB',
          progress: 60,
          category: 'documentaries'
        }
      ]
      store.setTorrents(torrents)
    })

    it('should filter by search query', () => {
      store.setSearchQuery('movie')
      expect(store.filteredTorrents.value).toHaveLength(1)
      expect(store.filteredTorrents.value[0].name).toBe('movie-action')
    })

    it('should filter by status', () => {
      store.setStatusFilter('completed')
      expect(store.filteredTorrents.value).toHaveLength(1)
      expect(store.filteredTorrents.value[0].status).toBe('completed')
    })

    it('should filter by category', () => {
      store.setCategoryFilter('movies')
      expect(store.filteredTorrents.value).toHaveLength(1)
      expect(store.filteredTorrents.value[0].category).toBe('movies')
    })

    it('should combine multiple filters', () => {
      store.setSearchQuery('series')
      store.setStatusFilter('completed')
      store.setCategoryFilter('tv')
      
      expect(store.filteredTorrents.value).toHaveLength(1)
      expect(store.filteredTorrents.value[0].name).toBe('series-drama')
    })

    it('should return empty array when no matches', () => {
      store.setSearchQuery('nonexistent')
      expect(store.filteredTorrents.value).toHaveLength(0)
    })
  })

  describe('Computed Properties', () => {
    beforeEach(() => {
      const torrents: Torrent[] = [
        {
          id: '1',
          name: 'torrent1',
          title: 'Torrent 1',
          status: 'downloading',
          size: '2.0 GB',
          progress: 50
        },
        {
          id: '2',
          name: 'torrent2',
          title: 'Torrent 2',
          status: 'completed',
          size: '1.5 GB',
          progress: 100
        },
        {
          id: '3',
          name: 'torrent3',
          title: 'Torrent 3',
          status: 'downloading',
          size: '500 MB',
          progress: 25
        }
      ]
      store.setTorrents(torrents)
    })

    it('should count active downloads correctly', () => {
      expect(store.activeDownloads.value).toHaveLength(2)
      expect(store.activeDownloads.value.every(t => t.status === 'downloading')).toBe(true)
    })

    it('should count completed torrents correctly', () => {
      expect(store.completedTorrents.value).toHaveLength(1)
      expect(store.completedTorrents.value[0].status).toBe('completed')
    })

    it('should calculate total size correctly', () => {
      // 2.0 GB + 1.5 GB + 0.5 GB = 4.0 GB
      expect(store.totalSize.value).toBe('4.0 GB')
    })
  })

  describe('System Info Management', () => {
    const mockSystemInfo: SystemInfo = {
      cpu_usage: 45.5,
      memory_usage: 60.2,
      disk_usage: 75.0,
      network_in: 1024,
      network_out: 512,
      uptime: '2d 5h 30m'
    }

    it('should set system info', () => {
      store.setSystemInfo(mockSystemInfo)
      expect(store.systemInfo.value).toEqual(mockSystemInfo)
    })
  })

  describe('Error and Loading State', () => {
    it('should set and clear loading state', () => {
      store.setLoading(true)
      expect(store.isLoading.value).toBe(true)
      
      store.setLoading(false)
      expect(store.isLoading.value).toBe(false)
    })

    it('should set and clear error', () => {
      store.setError('Test error')
      expect(store.error.value).toBe('Test error')
      
      store.clearError()
      expect(store.error.value).toBeNull()
    })

    it('should auto-clear error after timeout', (done) => {
      vi.useFakeTimers()
      
      store.setError('Auto-clear error')
      expect(store.error.value).toBe('Auto-clear error')
      
      // Fast-forward time by 5 seconds
      vi.advanceTimersByTime(5000)
      
      setTimeout(() => {
        expect(store.error.value).toBeNull()
        vi.useRealTimers()
        done()
      }, 10)
    })
  })

  describe('UI State Management', () => {
    it('should toggle sidebar state', () => {
      expect(store.sidebarOpen.value).toBe(false)
      
      store.toggleSidebar()
      expect(store.sidebarOpen.value).toBe(true)
      
      store.toggleSidebar()
      expect(store.sidebarOpen.value).toBe(false)
    })

    it('should set sidebar state directly', () => {
      store.setSidebarOpen(true)
      expect(store.sidebarOpen.value).toBe(true)
      
      store.setSidebarOpen(false)
      expect(store.sidebarOpen.value).toBe(false)
    })
  })
})
