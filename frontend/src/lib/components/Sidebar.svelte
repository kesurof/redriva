<script lang="ts">
  import { page } from '$app/stores';
  import { Home, Download, Settings, Activity, Palette } from 'lucide-svelte';

  const navigation = [
    { name: 'Dashboard', href: '/', icon: Home },
    { name: 'Torrents', href: '/torrents', icon: Download },
    { name: 'Services', href: '/services', icon: Activity },
    { name: 'Thèmes', href: '/themes', icon: Palette },
    { name: 'Paramètres', href: '/settings', icon: Settings }
  ];

  $: currentPath = $page.url.pathname;
</script>

<aside class="fixed left-0 top-0 h-full w-64 bg-white dark:bg-gray-800 shadow-lg border-r border-gray-200 dark:border-gray-700">
  <div class="p-6 border-b border-gray-200 dark:border-gray-700">
    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Redriva</h1>
    <p class="text-sm text-gray-500 dark:text-gray-400">Gestionnaire Real-Debrid</p>
  </div>

  <nav class="p-4">
    <ul class="space-y-2">
      {#each navigation as item}
        <li>
          <a
            href={item.href}
            class="flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors duration-200
                   {currentPath === item.href 
                     ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400' 
                     : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700'}"
          >
            <svelte:component this={item.icon} class="w-5 h-5" />
            <span class="font-medium">{item.name}</span>
          </a>
        </li>
      {/each}
    </ul>
  </nav>

  <div class="absolute bottom-4 left-4 right-4">
    <div class="text-xs text-gray-500 dark:text-gray-400 text-center">
      Version 2.0.0 - SvelteKit
    </div>
  </div>
</aside>
