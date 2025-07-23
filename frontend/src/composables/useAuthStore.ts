/**
 * Composable pour la gestion de l'authentification
 * Équivalent du store auth.ts de Svelte
 */
import { ref, computed, reactive } from 'vue'

export interface AuthState {
  isAuthenticated: boolean
  user: {
    id?: string
    username?: string
    email?: string
  } | null
  tokens: {
    access_token?: string
    refresh_token?: string
  } | null
  lastCheck: Date | null
}

// État réactif global
const authState = reactive<AuthState>({
  isAuthenticated: false,
  user: null,
  tokens: null,
  lastCheck: null
})

export function useAuthStore() {
  // Computed properties (équivalent aux derived stores)
  const isAuthenticated = computed(() => authState.isAuthenticated)
  const currentUser = computed(() => authState.user)
  const tokens = computed(() => authState.tokens)
  const lastCheck = computed(() => authState.lastCheck)

  // Actions
  const login = (user: any, tokens: any) => {
    authState.isAuthenticated = true
    authState.user = user
    authState.tokens = tokens
    authState.lastCheck = new Date()
    
    // Sauvegarder dans le localStorage
    if (typeof window !== 'undefined') {
      localStorage.setItem('redriva_auth', JSON.stringify({ user, tokens }))
    }
  }

  const logout = () => {
    authState.isAuthenticated = false
    authState.user = null
    authState.tokens = null
    authState.lastCheck = null
    
    if (typeof window !== 'undefined') {
      localStorage.removeItem('redriva_auth')
    }
  }

  const loadFromStorage = () => {
    if (typeof window === 'undefined') return
    
    try {
      const stored = localStorage.getItem('redriva_auth')
      if (stored) {
        const { user, tokens } = JSON.parse(stored)
        authState.isAuthenticated = true
        authState.user = user
        authState.tokens = tokens
        authState.lastCheck = new Date()
      }
    } catch (error) {
      console.error('Erreur lors du chargement de l\'état d\'auth:', error)
      // En cas d'erreur, nettoyer le localStorage
      localStorage.removeItem('redriva_auth')
    }
  }

  const updateUser = (user: any) => {
    if (authState.user) {
      authState.user = { ...authState.user, ...user }
      authState.lastCheck = new Date()
    }
  }

  const checkAuth = async () => {
    try {
      const response = await fetch('/api/auth/status')
      const result = await response.json()
      
      if (result.authenticated) {
        authState.isAuthenticated = true
        authState.lastCheck = new Date()
        return true
      } else {
        logout()
        return false
      }
    } catch (error) {
      console.error('Erreur lors de la vérification d\'auth:', error)
      return false
    }
  }

  // Initialiser lors du premier appel
  const initialize = () => {
    loadFromStorage()
  }

  // Getters pour l'état
  const getState = () => ({ ...authState })

  return {
    // State
    isAuthenticated,
    currentUser,
    tokens,
    lastCheck,
    
    // Actions
    login,
    logout,
    loadFromStorage,
    updateUser,
    checkAuth,
    initialize,
    getState
  }
}
