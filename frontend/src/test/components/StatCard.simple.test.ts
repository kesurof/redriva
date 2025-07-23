import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { createVuetify } from 'vuetify'
import StatCard from '@/components/StatCard.vue'

// Créer une instance Vuetify pour les tests
const vuetify = createVuetify()

// Helper pour créer un wrapper avec Vuetify
const createWrapper = (props: any) => {
  return mount(StatCard, {
    props,
    global: {
      plugins: [vuetify],
    },
  })
}

describe('StatCard.vue', () => {
  it('should render basic props correctly', () => {
    const wrapper = createWrapper({
      title: 'CPU Usage',
      value: '45%',
      subtitle: 'Current usage'
    })

    expect(wrapper.text()).toContain('CPU Usage')
    expect(wrapper.text()).toContain('45%')
    expect(wrapper.text()).toContain('Current usage')
  })

  it('should render with icon when provided', () => {
    const wrapper = createWrapper({
      title: 'Memory',
      value: '8 GB',
      icon: 'mdi-memory'
    })

    expect(wrapper.text()).toContain('Memory')
    expect(wrapper.text()).toContain('8 GB')
    // L'icône est gérée par Vuetify, on vérifie qu'elle est présente dans les props
    expect(wrapper.props('icon')).toBe('mdi-memory')
  })

  it('should apply correct variant prop', () => {
    const wrapper = createWrapper({
      title: 'Test',
      value: '100',
      variant: 'success'
    })

    expect(wrapper.props('variant')).toBe('success')
    expect(wrapper.text()).toContain('Test')
    expect(wrapper.text()).toContain('100')
  })

  it('should display progress when progress prop is provided', () => {
    const wrapper = createWrapper({
      title: 'Download',
      value: '75%',
      progress: 75
    })

    expect(wrapper.props('progress')).toBe(75)
    expect(wrapper.text()).toContain('Download')
    expect(wrapper.text()).toContain('75%')
  })

  it('should display trend when trend prop is provided', () => {
    const wrapper = createWrapper({
      title: 'Revenue',
      value: '$1,234',
      trend: 'up'
    })

    expect(wrapper.props('trend')).toBe('up')
    expect(wrapper.text()).toContain('Revenue')
    expect(wrapper.text()).toContain('$1,234')
  })

  it('should handle different sizes', () => {
    const wrapper = createWrapper({
      title: 'Test',
      value: '100',
      size: 'lg'
    })

    expect(wrapper.props('size')).toBe('lg')
    expect(wrapper.text()).toContain('Test')
  })

  it('should handle numeric values', () => {
    const wrapper = createWrapper({
      title: 'Count',
      value: 42
    })

    expect(wrapper.props('value')).toBe(42)
    expect(wrapper.text()).toContain('Count')
    expect(wrapper.text()).toContain('42')
  })

  it('should render without optional props', () => {
    const wrapper = createWrapper({
      title: 'Basic Card',
      value: 'Test Value'
    })

    expect(wrapper.text()).toContain('Basic Card')
    expect(wrapper.text()).toContain('Test Value')
    expect(wrapper.exists()).toBe(true)
  })

  it('should have v-card as root element', () => {
    const wrapper = createWrapper({
      title: 'Test Card',
      value: '123'
    })

    // Vérifier que le composant a bien un v-card comme élément racine
    expect(wrapper.find('.v-card').exists()).toBe(true)
  })

  it('should pass all props correctly', () => {
    const props = {
      title: 'Test Title',
      value: 'Test Value',
      subtitle: 'Test Subtitle',
      icon: 'mdi-test',
      variant: 'primary' as const,
      trend: 'up' as const,
      progress: 50,
      size: 'md' as const
    }

    const wrapper = createWrapper(props)

    // Vérifier que toutes les props sont passées correctement
    Object.keys(props).forEach(key => {
      expect(wrapper.props(key)).toEqual(props[key as keyof typeof props])
    })
  })
})
