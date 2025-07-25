import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import AppLayout from '@/layout/AppLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: AppLayout,
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('@/pages/Dashboard.vue'),
        meta: {
          title: 'Dashboard - Redriva'
        }
      },
      {
        path: '/services',
        name: 'Services',
        component: () => import('@/pages/ServicesList.vue'),
        meta: {
          title: 'Services - Redriva'
        }
      },
      {
        path: '/torrents',
        name: 'Torrents',
        component: () => import('@/pages/TorrentList.vue'),
        meta: {
          title: 'Torrents - Redriva'
        }
      },
      {
        path: '/symlink',
        name: 'Symlink',
        component: () => import('@/pages/SymlinkPage.vue'),
        meta: {
          title: 'Symlink - Redriva'
        }
      },
      {
        path: '/test-primevue',
        name: 'PrimeVueTest',
        component: () => import('@/pages/PrimeVueTest.vue'),
        meta: {
          title: 'Test PrimeVue - Redriva'
        }
      },
      {
        path: '/theme-demo',
        name: 'ThemeDemo',
        component: () => import('@/pages/ThemeDemo.vue'),
        meta: {
          title: 'Démo Thème Aura - Redriva'
        }
      },
      {
        path: '/theme-settings',
        name: 'ThemeSettings',
        component: () => import('@/pages/ThemeSettings.vue'),
        meta: {
          title: 'Paramètres du Thème - Redriva'
        }
      },
      {
        path: '/sakai-demo',
        name: 'SakaiDemo',
        component: () => import('@/pages/SakaiDemo.vue'),
        meta: {
          title: 'Demo Sakai - Redriva'
        }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
