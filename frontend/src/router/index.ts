import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
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
    path: '/torrents/:id',
    name: 'TorrentDetail',
    component: () => import('@/pages/TorrentDetail.vue'),
    meta: {
      title: 'Détails Torrent - Redriva'
    }
  },
  {
    path: '/demo',
    name: 'Demo',
    component: () => import('@/pages/DemoPage.vue'),
    meta: {
      title: 'Démonstration - Redriva'
    }
  },
  {
    path: '/composables',
    name: 'ComposablesDemo',
    component: () => import('@/views/ComposablesDemo.vue'),
    meta: {
      title: 'Démonstration Composables - Redriva'
    }
  },
  {
    path: '/components',
    name: 'ComponentsDemo',
    component: () => import('@/views/ComponentsDemo.vue'),
    meta: {
      title: 'Démonstration Composants - Redriva'
    }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('@/pages/SettingsPage.vue'),
    meta: {
      title: 'Paramètres - Redriva'
    }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    }
    return { top: 0 }
  }
})

// Guard pour les titres
router.beforeEach((to, from, next) => {
  if (to.meta.title) {
    document.title = to.meta.title as string
  }
  next()
})

export default router
