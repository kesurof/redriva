import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useAppStore } from '@/composables/useAppStore'

// Mock fetch globally
const mockFetch = vi.fn()
globalThis.fetch = mockFetch

describe('useAppStore', () => {
  let store: ReturnType<typeof useAppStore>

  beforeEach(() => {
    // Reset all mocks before each test
    vi.clearAllMocks()
    mockFetch.mockClear()
    
    // Create a fresh store instance and reset its state
    store = useAppStore()
    store.setLoading(false)
    store.clearError()
    // Note: systemStatus starts as null by design
  })

  describe('Initial State', () => {
    it('should initialize with default values', () => {
      expect(store.isLoading.value).toBe(false)
      expect(store.systemStatus.value).toBeNull()
      expect(store.lastUpdated.value).toBeNull()
      expect(store.error.value).toBeNull()
    })

    it('should return state copy with getState', () => {
      const state = store.getState()
      
      expect(state).toEqual({
        isLoading: false,
        systemStatus: null,
        lastUpdated: null,
        error: null
      })
    })
  })

  describe('Loading State Management', () => {
    it('should set loading state', () => {
      store.setLoading(true)
      expect(store.isLoading.value).toBe(true)
      
      store.setLoading(false)
      expect(store.isLoading.value).toBe(false)
    })
  })

  describe('System Status Management', () => {
    it('should update system status and clear error', () => {
      const mockStatus = {
        cpu_percent: 45.2,
        memory: {
          total: 8589934592,
          available: 4294967296,
          used: 4294967296
        },
        disk: {
          total: 1000000000000,
          used: 500000000000,
          free: 500000000000
        },
        uptime: '1d 0h 0m'
      }

      // Set an initial error to test clearing
      store.setError('Test error')
      expect(store.error.value).toBe('Test error')

      store.updateSystemStatus(mockStatus)
      
      expect(store.systemStatus.value).toEqual(mockStatus)
      expect(store.lastUpdated.value).toBeInstanceOf(Date)
      expect(store.error.value).toBeNull()
    })

    it('should update lastUpdated when system status changes', () => {
      const beforeUpdate = new Date()
      
      store.updateSystemStatus({
        cpu_percent: 25.0,
        memory: { total: 0, available: 0, used: 0 },
        disk: { total: 0, used: 0, free: 0 },
        uptime: '1h 0m'
      })
      
      const afterUpdate = new Date()
      expect(store.lastUpdated.value).toBeInstanceOf(Date)
      expect(store.lastUpdated.value!.getTime()).toBeGreaterThanOrEqual(beforeUpdate.getTime())
      expect(store.lastUpdated.value!.getTime()).toBeLessThanOrEqual(afterUpdate.getTime())
    })
  })

  describe('Error Management', () => {
    it('should set error and stop loading', () => {
      store.setLoading(true)
      store.setError('Something went wrong')
      
      expect(store.error.value).toBe('Something went wrong')
      expect(store.isLoading.value).toBe(false)
    })

    it('should clear error', () => {
      store.setError('Test error')
      expect(store.error.value).toBe('Test error')
      
      store.clearError()
      expect(store.error.value).toBeNull()
    })
  })

  describe('System Status Refresh', () => {
    it('should successfully refresh system status', async () => {
      const mockSystemStatus = {
        cpu_percent: 35.5,
        memory: {
          total: 16777216000,
          available: 8388608000,
          used: 8388608000
        },
        disk: {
          total: 2000000000000,
          used: 1000000000000,
          free: 1000000000000
        },
        uptime: '2d 0h 0m'
      }

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockSystemStatus)
      })

      await store.refreshSystemStatus()

      expect(mockFetch).toHaveBeenCalledWith('/api/system')
      expect(store.systemStatus.value).toEqual(mockSystemStatus)
      expect(store.isLoading.value).toBe(false)
      expect(store.error.value).toBeNull()
      expect(store.lastUpdated.value).toBeInstanceOf(Date)
    })

    it('should handle HTTP errors', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500
      })

      await store.refreshSystemStatus()

      expect(mockFetch).toHaveBeenCalledWith('/api/system')
      expect(store.error.value).toBe('Erreur HTTP: 500')
      expect(store.isLoading.value).toBe(false)
    })

    it('should handle network errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'))

      await store.refreshSystemStatus()

      expect(mockFetch).toHaveBeenCalledWith('/api/system')
      expect(store.error.value).toBe('Network error')
      expect(store.isLoading.value).toBe(false)
    })

    it('should handle unknown errors', async () => {
      mockFetch.mockRejectedValueOnce('String error')

      await store.refreshSystemStatus()

      expect(mockFetch).toHaveBeenCalledWith('/api/system')
      expect(store.error.value).toBe('Erreur inconnue')
      expect(store.isLoading.value).toBe(false)
    })

    it('should set loading state during refresh', async () => {
      // Mock a slow response
      mockFetch.mockImplementationOnce(() => 
        new Promise(resolve => 
          setTimeout(() => resolve({
            ok: true,
            json: () => Promise.resolve({
              cpu_percent: 0,
              memory: { total: 0, available: 0, used: 0 },
              disk: { total: 0, used: 0, free: 0 },
              uptime: '0'
            })
          }), 10)
        )
      )

      const refreshPromise = store.refreshSystemStatus()
      
      // Check loading state is true during request
      expect(store.isLoading.value).toBe(true)
      
      await refreshPromise
      
      // Check loading state is false after request
      expect(store.isLoading.value).toBe(false)
    })
  })

  describe('State Behavior', () => {
    it('should handle state transitions correctly', () => {
      // Initial state
      expect(store.isLoading.value).toBe(false)
      expect(store.error.value).toBeNull()
      
      // Set loading
      store.setLoading(true)
      expect(store.isLoading.value).toBe(true)
      
      // Set error (should stop loading)
      store.setError('An error occurred')
      expect(store.isLoading.value).toBe(false)
      expect(store.error.value).toBe('An error occurred')
      
      // Clear error
      store.clearError()
      expect(store.error.value).toBeNull()
    })
  })
})
