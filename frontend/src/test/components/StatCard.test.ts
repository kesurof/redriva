import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import StatCard from '@/components/StatCard.vue'

describe('StatCard.vue', () => {
  it('should render basic props correctly', () => {
    const wrapper = mount(StatCard, {
      props: {
        title: 'CPU Usage',
        value: '45%',
        subtitle: 'Current usage'
      }
    })

    expect(wrapper.text()).toContain('CPU Usage')
    expect(wrapper.text()).toContain('45%')
    expect(wrapper.text()).toContain('Current usage')
  })

  it('should display icon when provided', () => {
    const wrapper = mount(StatCard, {
      props: {
        title: 'Memory',
        value: '8 GB',
        icon: 'mdi-memory'
      }
    })

    const icon = wrapper.find('.mdi-memory')
    expect(icon.exists()).toBe(true)
  })

  it('should apply correct variant classes', () => {
    const wrapper = mount(StatCard, {
      props: {
        title: 'Test',
        value: '100',
        variant: 'success'
      }
    })

    // Vérifier que le composant applique la variante
    expect(wrapper.classes()).toContain('variant-success')
  })

  it('should display progress bar when progress prop is provided', () => {
    const wrapper = mount(StatCard, {
      props: {
        title: 'Download',
        value: '75%',
        progress: 75
      }
    })

    const progressBar = wrapper.find('v-progress-linear')
    expect(progressBar.exists()).toBe(true)
  })

  it('should display trend chip when trend prop is provided', () => {
    const wrapper = mount(StatCard, {
      props: {
        title: 'Revenue',
        value: '$1,234',
        trend: 'up'
      }
    })

    const trendChip = wrapper.find('.trend-chip')
    expect(trendChip.exists()).toBe(true)
    expect(trendChip.classes()).toContain('trend-up')
  })

  it('should handle different sizes', () => {
    const wrapper = mount(StatCard, {
      props: {
        title: 'Test',
        value: '100',
        size: 'lg'
      }
    })

    expect(wrapper.classes()).toContain('size-lg')
  })

  it('should handle numeric values', () => {
    const wrapper = mount(StatCard, {
      props: {
        title: 'Count',
        value: 42
      }
    })

    expect(wrapper.text()).toContain('42')
  })

  it('should render without optional props', () => {
    const wrapper = mount(StatCard, {
      props: {
        title: 'Basic Card',
        value: 'Test Value'
      }
    })

    expect(wrapper.text()).toContain('Basic Card')
    expect(wrapper.text()).toContain('Test Value')
    expect(wrapper.exists()).toBe(true)
  })
})
