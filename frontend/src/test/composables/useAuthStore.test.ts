import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useAuthStore } from '@/composables/useAuthStore'

// Mock fetch globally
const mockFetch = vi.fn()
globalThis.fetch = mockFetch

// Mock localStorage
const mockLocalStorage = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn()
}

Object.defineProperty(window, 'localStorage', {
  value: mockLocalStorage
})

describe('useAuthStore', () => {
  let store: ReturnType<typeof useAuthStore>

  beforeEach(() => {
    // Reset all mocks before each test
    vi.clearAllMocks()
    mockFetch.mockClear()
    mockLocalStorage.getItem.mockClear()
    mockLocalStorage.setItem.mockClear()
    mockLocalStorage.removeItem.mockClear()
    
    // Create a fresh store instance and reset state
    store = useAuthStore()
    store.logout() // This will reset state to initial values
  })

  describe('Initial State', () => {
    it('should initialize with default values', () => {
      expect(store.isAuthenticated.value).toBe(false)
      expect(store.currentUser.value).toBeNull()
      expect(store.tokens.value).toBeNull()
      expect(store.lastCheck.value).toBeNull()
    })

    it('should return state copy with getState', () => {
      const state = store.getState()
      
      expect(state).toEqual({
        isAuthenticated: false,
        user: null,
        tokens: null,
        lastCheck: null
      })
    })
  })

  describe('Login and Logout', () => {
    const mockUser = {
      id: 'user-123',
      username: 'testuser',
      email: 'test@example.com'
    }

    const mockTokens = {
      access_token: 'access-token-123',
      refresh_token: 'refresh-token-456'
    }

    it('should login user correctly', () => {
      const beforeLogin = new Date()
      
      store.login(mockUser, mockTokens)
      
      expect(store.isAuthenticated.value).toBe(true)
      expect(store.currentUser.value).toEqual(mockUser)
      expect(store.tokens.value).toEqual(mockTokens)
      expect(store.lastCheck.value).toBeInstanceOf(Date)
      expect(store.lastCheck.value!.getTime()).toBeGreaterThanOrEqual(beforeLogin.getTime())
      
      // Check localStorage was called
      expect(mockLocalStorage.setItem).toHaveBeenCalledWith(
        'redriva_auth',
        JSON.stringify({ user: mockUser, tokens: mockTokens })
      )
    })

    it('should logout user correctly', () => {
      // First login
      store.login(mockUser, mockTokens)
      expect(store.isAuthenticated.value).toBe(true)
      
      // Then logout
      store.logout()
      
      expect(store.isAuthenticated.value).toBe(false)
      expect(store.currentUser.value).toBeNull()
      expect(store.tokens.value).toBeNull()
      expect(store.lastCheck.value).toBeNull()
      
      // Check localStorage was cleared
      expect(mockLocalStorage.removeItem).toHaveBeenCalledWith('redriva_auth')
    })
  })

  describe('User Management', () => {
    const mockUser = {
      id: 'user-123',
      username: 'testuser',
      email: 'test@example.com'
    }

    const mockTokens = {
      access_token: 'access-token-123'
    }

    it('should update user when authenticated', () => {
      store.login(mockUser, mockTokens)
      
      const userUpdate = { username: 'updateduser', email: 'updated@example.com' }
      const beforeUpdate = new Date()
      
      store.updateUser(userUpdate)
      
      expect(store.currentUser.value).toEqual({
        id: 'user-123', // Original id preserved
        username: 'updateduser', // Updated
        email: 'updated@example.com' // Updated
      })
      expect(store.lastCheck.value!.getTime()).toBeGreaterThanOrEqual(beforeUpdate.getTime())
    })

    it('should not update user when not authenticated', () => {
      expect(store.currentUser.value).toBeNull()
      
      store.updateUser({ username: 'newuser' })
      
      expect(store.currentUser.value).toBeNull()
      expect(store.lastCheck.value).toBeNull()
    })
  })

  describe('Storage Operations', () => {
    const mockStoredData = {
      user: { id: 'stored-user', username: 'storeduser' },
      tokens: { access_token: 'stored-token' }
    }

    it('should load from storage successfully', () => {
      mockLocalStorage.getItem.mockReturnValue(JSON.stringify(mockStoredData))
      
      const beforeLoad = new Date()
      store.loadFromStorage()
      
      expect(store.isAuthenticated.value).toBe(true)
      expect(store.currentUser.value).toEqual(mockStoredData.user)
      expect(store.tokens.value).toEqual(mockStoredData.tokens)
      expect(store.lastCheck.value!.getTime()).toBeGreaterThanOrEqual(beforeLoad.getTime())
      
      expect(mockLocalStorage.getItem).toHaveBeenCalledWith('redriva_auth')
    })

    it('should handle empty storage gracefully', () => {
      mockLocalStorage.getItem.mockReturnValue(null)
      
      store.loadFromStorage()
      
      expect(store.isAuthenticated.value).toBe(false)
      expect(store.currentUser.value).toBeNull()
      expect(store.tokens.value).toBeNull()
    })

    it('should handle corrupted storage data', () => {
      mockLocalStorage.getItem.mockReturnValue('invalid-json')
      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
      
      store.loadFromStorage()
      
      expect(store.isAuthenticated.value).toBe(false)
      expect(mockLocalStorage.removeItem).toHaveBeenCalledWith('redriva_auth')
      expect(consoleSpy).toHaveBeenCalled()
      
      consoleSpy.mockRestore()
    })

    it('should initialize by loading from storage', () => {
      mockLocalStorage.getItem.mockReturnValue(null)
      
      store.initialize()
      
      // Verify that getItem was called (which means loadFromStorage was executed)
      expect(mockLocalStorage.getItem).toHaveBeenCalledWith('redriva_auth')
    })
  })

  describe('Authentication Check', () => {
    it('should handle successful auth check', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ authenticated: true })
      })

      const beforeCheck = new Date()
      const result = await store.checkAuth()

      expect(result).toBe(true)
      expect(store.isAuthenticated.value).toBe(true)
      expect(store.lastCheck.value!.getTime()).toBeGreaterThanOrEqual(beforeCheck.getTime())
      expect(mockFetch).toHaveBeenCalledWith('/api/auth/status')
    })

    it('should handle failed auth check', async () => {
      // First login user
      store.login({ id: 'user' }, { access_token: 'token' })
      expect(store.isAuthenticated.value).toBe(true)

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ authenticated: false })
      })

      const result = await store.checkAuth()

      expect(result).toBe(false)
      expect(store.isAuthenticated.value).toBe(false)
      expect(store.currentUser.value).toBeNull()
      expect(store.tokens.value).toBeNull()
    })

    it('should handle network errors during auth check', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'))
      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})

      const result = await store.checkAuth()

      expect(result).toBe(false)
      expect(consoleSpy).toHaveBeenCalled()
      
      consoleSpy.mockRestore()
    })
  })

  describe('State Transitions', () => {
    it('should handle complete authentication flow', () => {
      // Start unauthenticated
      expect(store.isAuthenticated.value).toBe(false)

      // Login
      const user = { id: '1', username: 'user' }
      const tokens = { access_token: 'token' }
      store.login(user, tokens)
      
      expect(store.isAuthenticated.value).toBe(true)
      expect(store.currentUser.value).toEqual(user)

      // Update user
      store.updateUser({ username: 'updated' })
      expect(store.currentUser.value?.username).toBe('updated')

      // Logout
      store.logout()
      expect(store.isAuthenticated.value).toBe(false)
      expect(store.currentUser.value).toBeNull()
    })
  })

  describe('Error Handling', () => {
    it('should handle localStorage errors gracefully', () => {
      // Mock localStorage to throw an error
      mockLocalStorage.getItem.mockImplementation(() => {
        throw new Error('Storage error')
      })
      
      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
      
      store.loadFromStorage()
      
      expect(store.isAuthenticated.value).toBe(false)
      expect(consoleSpy).toHaveBeenCalled()
      
      consoleSpy.mockRestore()
    })
  })
})
