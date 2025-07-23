import { describe, it, expect, vi, beforeEach } from 'vitest'

// Mock simple de useTheme avant l'import du composable
vi.mock('vuetify', () => ({
  useTheme: () => ({
    global: {
      name: { value: 'skeletonLight' }
    }
  })
}))

// Import du composable après les mocks
import { useThemeStore } from '@/composables/useThemeStore'

describe('useThemeStore', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    
    // Mock localStorage pour chaque test
    const mockStorage = {
      getItem: vi.fn(),
      setItem: vi.fn(),
      removeItem: vi.fn(),
      clear: vi.fn(),
    }
    
    Object.defineProperty(window, 'localStorage', {
      value: mockStorage,
      writable: true
    })
    
    // Reset du thème à l'état initial pour chaque test
    const { setTheme } = useThemeStore()
    setTheme('skeletonLight')
  })

  it('should initialize with correct state', () => {
    const { themeName, isDark, isLight } = useThemeStore()
    
    expect(themeName.value).toBe('skeletonLight')
    expect(isDark.value).toBe(false)
    expect(isLight.value).toBe(true)
  })

  it('should set theme correctly', () => {
    const { setTheme, themeName, isDark } = useThemeStore()
    
    setTheme('wintryDark')
    
    expect(themeName.value).toBe('wintryDark')
    expect(isDark.value).toBe(true)
    expect(localStorage.setItem).toHaveBeenCalledWith('redriva-theme', 'wintryDark')
  })

  it('should toggle dark mode from light', () => {
    const { toggleDarkMode, themeName, isDark } = useThemeStore()
    
    // Vérifier état initial
    expect(themeName.value).toBe('skeletonLight')
    expect(isDark.value).toBe(false)
    
    // Basculer vers dark
    toggleDarkMode()
    expect(themeName.value).toBe('skeletonDark')
    expect(isDark.value).toBe(true)
  })

  it('should toggle back to light mode from dark', () => {
    const { setTheme, toggleDarkMode, themeName, isDark } = useThemeStore()
    
    // D'abord mettre en dark
    setTheme('skeletonDark')
    expect(isDark.value).toBe(true)
    
    // Puis basculer vers light
    toggleDarkMode()
    expect(themeName.value).toBe('skeletonLight')
    expect(isDark.value).toBe(false)
  })

  it('should set light mode correctly', () => {
    const { setTheme, setLightMode, themeName, isDark } = useThemeStore()
    
    // Commencer en dark
    setTheme('wintryDark')
    expect(isDark.value).toBe(true)
    
    // Passer en light
    setLightMode()
    expect(themeName.value).toBe('wintryLight')
    expect(isDark.value).toBe(false)
  })

  it('should set dark mode correctly', () => {
    const { setDarkMode, themeName, isDark } = useThemeStore()
    
    // Commencer en light (état initial)
    expect(isDark.value).toBe(false)
    
    // Passer en dark
    setDarkMode()
    expect(themeName.value).toBe('skeletonDark')
    expect(isDark.value).toBe(true)
  })

  it('should switch to skeleton theme', () => {
    const { setTheme, setSkeleton, themeName } = useThemeStore()
    
    // Commencer avec wintry
    setTheme('wintryLight')
    expect(themeName.value).toBe('wintryLight')
    
    // Basculer vers skeleton (garde le mode light)
    setSkeleton()
    expect(themeName.value).toBe('skeletonLight')
  })

  it('should switch to wintry theme', () => {
    const { setWintry, themeName } = useThemeStore()
    
    // Commencer avec skeleton (état initial)
    expect(themeName.value).toBe('skeletonLight')
    
    // Basculer vers wintry (garde le mode light)
    setWintry()
    expect(themeName.value).toBe('wintryLight')
  })

  it('should preserve mode when switching variants', () => {
    const { setTheme, setSkeleton, setWintry, themeName, isDark } = useThemeStore()
    
    // Mettre en dark mode
    setTheme('skeletonDark')
    expect(isDark.value).toBe(true)
    
    // Changer vers wintry, devrait garder le mode dark
    setWintry()
    expect(themeName.value).toBe('wintryDark')
    expect(isDark.value).toBe(true)
    
    // Retour vers skeleton, devrait garder le mode dark
    setSkeleton()
    expect(themeName.value).toBe('skeletonDark')
    expect(isDark.value).toBe(true)
  })
})
