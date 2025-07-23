import { describe, it, expect, vi } from 'vitest'

describe('Test environment', () => {
  it('should run basic test', () => {
    expect(1 + 1).toBe(2)
  })

  it('should have access to DOM', () => {
    expect(typeof document).toBe('object')
  })

  it('should have localStorage mock', () => {
    // Définir un mock simple pour ce test
    const mockSetItem = vi.fn()
    const mockGetItem = vi.fn().mockReturnValue('value')
    
    Object.defineProperty(window, 'localStorage', {
      value: {
        getItem: mockGetItem,
        setItem: mockSetItem,
      },
      writable: true
    })
    
    localStorage.setItem('test', 'value')
    expect(localStorage.getItem('test')).toBe('value')
    expect(mockSetItem).toHaveBeenCalledWith('test', 'value')
    expect(mockGetItem).toHaveBeenCalledWith('test')
  })
})
