import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useThemeStore, type ThemeName } from '@/composables/useThemeStore'

// Mock Vuetify theme
const mockTheme = {
  global: {
    name: { value: 'skeletonLight' }
  }
}

vi.mock('vuetify', () => ({
  useTheme: () => mockTheme
}))

describe('useThemeStore', () => {
  beforeEach(() => {
    // Reset localStorage avant chaque test
    vi.clearAllMocks()
    localStorage.clear()
    mockTheme.global.name.value = 'skeletonLight'
  })

  it('should initialize with default values', () => {
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
    expect(mockTheme.global.name.value).toBe('wintryDark')
    expect(localStorage.setItem).toHaveBeenCalledWith('redriva-theme', 'wintryDark')
  })

  it('should toggle dark mode correctly', () => {
    const { toggleDarkMode, themeName, isDark } = useThemeStore()
    
    // Commencer en mode light skeleton
    expect(themeName.value).toBe('skeletonLight')
    expect(isDark.value).toBe(false)
    
    // Basculer vers dark
    toggleDarkMode()
    expect(themeName.value).toBe('skeletonDark')
    expect(isDark.value).toBe(true)
    
    // Basculer vers light
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
    
    // Commencer en light (par défaut)
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
    
    // Commencer avec skeleton (par défaut)
    expect(themeName.value).toBe('skeletonLight')
    
    // Basculer vers wintry (garde le mode light)
    setWintry()
    expect(themeName.value).toBe('wintryLight')
  })

  it('should initialize from localStorage', () => {
    // Mock localStorage pour retourner un thème sauvegardé
    localStorage.getItem = vi.fn().mockReturnValue('wintryDark')
    
    const { initTheme, themeName, isDark } = useThemeStore()
    
    initTheme()
    
    expect(themeName.value).toBe('wintryDark')
    expect(isDark.value).toBe(true)
    expect(localStorage.getItem).toHaveBeenCalledWith('redriva-theme')
  })

  it('should detect system theme preference when no saved theme', () => {
    // Mock localStorage pour ne rien retourner
    localStorage.getItem = vi.fn().mockReturnValue(null)
    
    // Mock matchMedia pour préférences dark
    Object.defineProperty(window, 'matchMedia', {
      writable: true,
      value: vi.fn().mockImplementation((query: string) => ({
        matches: query === '(prefers-color-scheme: dark)',
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
      })),
    })
    
    const { initTheme, themeName, isDark } = useThemeStore()
    
    initTheme()
    
    expect(themeName.value).toBe('skeletonDark')
    expect(isDark.value).toBe(true)
  })

  it('should handle invalid saved theme', () => {
    // Mock localStorage avec un thème invalide
    localStorage.getItem = vi.fn().mockReturnValue('invalidTheme')
    
    // Mock matchMedia pour préférences light
    Object.defineProperty(window, 'matchMedia', {
      writable: true,
      value: vi.fn().mockImplementation(() => ({
        matches: false,
        media: '(prefers-color-scheme: dark)',
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
      })),
    })
    
    const { initTheme, themeName, isDark } = useThemeStore()
    
    initTheme()
    
    // Devrait fallback sur le thème système (light dans ce cas)
    expect(themeName.value).toBe('skeletonLight')
    expect(isDark.value).toBe(false)
  })
})
