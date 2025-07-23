import 'vuetify/styles'
import { createVuetify, type ThemeDefinition } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi-svg'

// Équivalent du thème "skeleton" (par défaut)
const skeletonLight: ThemeDefinition = {
  dark: false,
  colors: {
    // Couleurs principales
    primary: '#0FBA81',      // Équivalent primary-500 Skeleton
    secondary: '#4F46E5',    // Équivalent secondary-500 Skeleton
    tertiary: '#D946EF',     // Équivalent tertiary-500 Skeleton
    
    // Statuts
    success: '#10B981',      // Équivalent success-500
    warning: '#F59E0B',      // Équivalent warning-500
    error: '#EF4444',        // Équivalent error-500
    info: '#3B82F6',         // Équivalent info-500
    
    // Surfaces (équivalent surface-* Skeleton)
    background: '#FFFFFF',   // surface-50
    surface: '#F8FAFC',      // surface-100
    'surface-bright': '#FFFFFF',
    'surface-light': '#EEEEEE',
    'surface-variant': '#424242',
    'on-surface-variant': '#EEEEEE',
    
    // Couleurs de texte
    'on-background': '#1E293B',  // surface-900
    'on-surface': '#334155',     // surface-700
    'on-primary': '#FFFFFF',
    'on-secondary': '#FFFFFF',
    'on-success': '#FFFFFF',
    'on-warning': '#FFFFFF',
    'on-error': '#FFFFFF',
    'on-info': '#FFFFFF',
    
    // Couleurs personnalisées Skeleton
    'surface-50': '#F8FAFC',
    'surface-100': '#F1F5F9',
    'surface-200': '#E2E8F0',
    'surface-300': '#CBD5E1',
    'surface-400': '#94A3B8',
    'surface-500': '#64748B',
    'surface-600': '#475569',
    'surface-700': '#334155',
    'surface-800': '#1E293B',
    'surface-900': '#0F172A'
  }
}

// Équivalent du thème "wintry" (moderne)
const wintryLight: ThemeDefinition = {
  dark: false,
  colors: {
    // Couleurs principales du thème wintry
    primary: '#3B82F6',      // blue-500
    secondary: '#8B5CF6',    // violet-500
    tertiary: '#06B6D4',     // cyan-500
    
    // Statuts
    success: '#10B981',      // emerald-500
    warning: '#F59E0B',      // amber-500
    error: '#EF4444',        // red-500
    info: '#3B82F6',         // blue-500
    
    // Surfaces
    background: '#FAFAFA',   
    surface: '#FFFFFF',      
    'surface-bright': '#FFFFFF',
    'surface-light': '#F5F5F5',
    'surface-variant': '#424242',
    'on-surface-variant': '#EEEEEE',
    
    // Couleurs de texte
    'on-background': '#1E293B',
    'on-surface': '#334155',
    'on-primary': '#FFFFFF',
    'on-secondary': '#FFFFFF',
    'on-success': '#FFFFFF',
    'on-warning': '#FFFFFF',
    'on-error': '#FFFFFF',
    'on-info': '#FFFFFF',
    
    // Couleurs personnalisées
    'surface-50': '#F8FAFC',
    'surface-100': '#F1F5F9',
    'surface-200': '#E2E8F0',
    'surface-300': '#CBD5E1',
    'surface-400': '#94A3B8',
    'surface-500': '#64748B',
    'surface-600': '#475569',
    'surface-700': '#334155',
    'surface-800': '#1E293B',
    'surface-900': '#0F172A'
  }
}

const wintryDark: ThemeDefinition = {
  dark: true,
  colors: {
    // Couleurs principales wintry mode sombre
    primary: '#60A5FA',      // blue-400
    secondary: '#A78BFA',    // violet-400
    tertiary: '#22D3EE',     // cyan-400
    
    // Statuts
    success: '#34D399',      // emerald-400
    warning: '#FBBF24',      // amber-400
    error: '#F87171',        // red-400
    info: '#60A5FA',         // blue-400
    
    // Surfaces mode sombre
    background: '#0F172A',   
    surface: '#1E293B',      // surface-800
    'surface-bright': '#334155',
    'surface-light': '#475569',
    'surface-variant': '#CBD5E1',
    'on-surface-variant': '#334155',
    
    // Couleurs de texte mode sombre
    'on-background': '#F8FAFC',
    'on-surface': '#E2E8F0',
    'on-primary': '#FFFFFF',
    'on-secondary': '#FFFFFF',
    'on-success': '#FFFFFF',
    'on-warning': '#FFFFFF',
    'on-error': '#FFFFFF',
    'on-info': '#FFFFFF',
    
    // Couleurs personnalisées inversées
    'surface-50': '#0F172A',
    'surface-100': '#1E293B',
    'surface-200': '#334155',
    'surface-300': '#475569',
    'surface-400': '#64748B',
    'surface-500': '#94A3B8',
    'surface-600': '#CBD5E1',
    'surface-700': '#E2E8F0',
    'surface-800': '#F1F5F9',
    'surface-900': '#F8FAFC'
  }
}

const skeletonDark: ThemeDefinition = {
  dark: true,
  colors: {
    // Couleurs principales
    primary: '#0FBA81',
    secondary: '#4F46E5',
    tertiary: '#D946EF',
    
    // Statuts
    success: '#10B981',
    warning: '#F59E0B',
    error: '#EF4444',
    info: '#3B82F6',
    
    // Surfaces inversées pour le mode sombre
    background: '#0F172A',   // surface-900
    surface: '#1E293B',      // surface-800
    'surface-bright': '#334155',
    'surface-light': '#475569',
    'surface-variant': '#CBD5E1',
    'on-surface-variant': '#334155',
    
    // Couleurs de texte inversées
    'on-background': '#F8FAFC',
    'on-surface': '#E2E8F0',
    'on-primary': '#FFFFFF',
    'on-secondary': '#FFFFFF',
    'on-success': '#FFFFFF',
    'on-warning': '#FFFFFF',
    'on-error': '#FFFFFF',
    'on-info': '#FFFFFF',
    
    // Couleurs personnalisées inversées
    'surface-50': '#0F172A',
    'surface-100': '#1E293B',
    'surface-200': '#334155',
    'surface-300': '#475569',
    'surface-400': '#64748B',
    'surface-500': '#94A3B8',
    'surface-600': '#CBD5E1',
    'surface-700': '#E2E8F0',
    'surface-800': '#F1F5F9',
    'surface-900': '#F8FAFC'
  }
}

// Thème Redriva (par défaut)
const redrivaLight: ThemeDefinition = {
  dark: false,
  colors: {
    // Couleurs principales
    primary: '#0FBA81',      // Équivalent primary-500 Skeleton
    secondary: '#4F46E5',    // Équivalent secondary-500 Skeleton
    tertiary: '#D946EF',     // Équivalent tertiary-500 Skeleton
    
    // Statuts
    success: '#10B981',      // Équivalent success-500
    warning: '#F59E0B',      // Équivalent warning-500
    error: '#EF4444',        // Équivalent error-500
    info: '#3B82F6',         // Équivalent info-500
    
    // Surfaces (équivalent surface-* Skeleton)
    background: '#FFFFFF',   // surface-50
    surface: '#F8FAFC',      // surface-100
    'surface-bright': '#FFFFFF',
    'surface-light': '#EEEEEE',
    'surface-variant': '#424242',
    'on-surface-variant': '#EEEEEE',
    
    // Couleurs de texte
    'on-background': '#1E293B',  // surface-900
    'on-surface': '#334155',     // surface-700
    'on-primary': '#FFFFFF',
    'on-secondary': '#FFFFFF',
    'on-success': '#FFFFFF',
    'on-warning': '#FFFFFF',
    'on-error': '#FFFFFF',
    'on-info': '#FFFFFF',
    
    // Couleurs personnalisées Skeleton
    'surface-50': '#F8FAFC',
    'surface-100': '#F1F5F9',
    'surface-200': '#E2E8F0',
    'surface-300': '#CBD5E1',
    'surface-400': '#94A3B8',
    'surface-500': '#64748B',
    'surface-600': '#475569',
    'surface-700': '#334155',
    'surface-800': '#1E293B',
    'surface-900': '#0F172A'
  }
}

const redrivaDark: ThemeDefinition = {
  dark: true,
  colors: {
    // Couleurs principales
    primary: '#0FBA81',
    secondary: '#4F46E5',
    tertiary: '#D946EF',
    
    // Statuts
    success: '#10B981',
    warning: '#F59E0B',
    error: '#EF4444',
    info: '#3B82F6',
    
    // Surfaces inversées pour le mode sombre
    background: '#0F172A',   // surface-900
    surface: '#1E293B',      // surface-800
    'surface-bright': '#334155',
    'surface-light': '#475569',
    'surface-variant': '#CBD5E1',
    'on-surface-variant': '#334155',
    
    // Couleurs de texte inversées
    'on-background': '#F8FAFC',
    'on-surface': '#E2E8F0',
    'on-primary': '#FFFFFF',
    'on-secondary': '#FFFFFF',
    'on-success': '#FFFFFF',
    'on-warning': '#FFFFFF',
    'on-error': '#FFFFFF',
    'on-info': '#FFFFFF',
    
    // Couleurs personnalisées inversées
    'surface-50': '#0F172A',
    'surface-100': '#1E293B',
    'surface-200': '#334155',
    'surface-300': '#475569',
    'surface-400': '#64748B',
    'surface-500': '#94A3B8',
    'surface-600': '#CBD5E1',
    'surface-700': '#E2E8F0',
    'surface-800': '#F1F5F9',
    'surface-900': '#F8FAFC'
  }
}

export default createVuetify({
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi
    }
  },
  theme: {
    defaultTheme: 'skeletonLight', // Thème par défaut original
    themes: {
      skeletonLight,
      skeletonDark,
      wintryLight,
      wintryDark,
      redrivaLight,
      redrivaDark,
    }
  },
  defaults: {
    VCard: {
      variant: 'flat',
      rounded: 'lg'
    },
    VSheet: {
      variant: 'flat',
      rounded: 'lg'
    },
    VBtn: {
      variant: 'flat',
      rounded: 'lg'
    },
    VList: {
      variant: 'flat',
      rounded: 'lg'
    },
    VMenu: {
      contentProps: {
        class: 'elevation-4'
      }
    }
  }
})
