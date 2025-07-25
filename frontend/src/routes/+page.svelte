<<script lang="ts">
  import { onMount } from 'svelte';
  import { Activity, Download, Server, Clock } from 'lucide-svelte';
  import { torrentService } from '$lib/api/torrents';
  import { servicesService } from '$lib/api/services';
  import { addNotification } from '$lib/stores/notifications';

  let stats = {
    totalTorrents: 0,
    activeTorrents: 0,
    completedTorrents: 0,
    servicesOnline: 0
  };

  let recentTorrents: any[] = [];
  let loading = true;

  onMount(async () => {
    try {
      // Charger les statistiques
      const [torrents, services] = await Promise.all([
        torrentService.getAll(),
        servicesService.getStatus()
      ]);

      stats = {
        totalTorrents: torrents.length,
        activeTorrents: torrents.filter(t => t.status === 'downloading').length,
        completedTorrents: torrents.filter(t => t.status === 'completed').length,
        servicesOnline: services.filter(s => s.status === 'online').length
      };

      recentTorrents = torrents.slice(0, 5);
    } catch (error) {
      addNotification({
        type: 'error',
        title: 'Erreur de chargement',
        message: 'Impossible de charger les données du dashboard'
      });
    } finally {
      loading = false;
    }
  });
</script>

<svelte:head>
  <title>Dashboard - Redriva</title>
</svelte:head>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Dashboard</h1>
    <div class="text-sm text-gray-500 dark:text-gray-400">
      Dernière mise à jour: {new Date().toLocaleTimeString('fr-FR')}
    </div>
  </div>

  {#if loading}
    <div class="flex items-center justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>
  {:else}
    <!-- Statistiques -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
        <div class="flex items-center">
          <div class="p-3 bg-blue-100 dark:bg-blue-900 rounded-full">
            <Download class="w-6 h-6 text-blue-600 dark:text-blue-400" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Torrents</p>
            <p class="text-2xl font-semibold text-gray-900 dark:text-white">{stats.totalTorrents}</p>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
        <div class="flex items-center">
          <div class="p-3 bg-green-100 dark:bg-green-900 rounded-full">
            <Activity class="w-6 h-6 text-green-600 dark:text-green-400" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Actifs</p>
            <p class="text-2xl font-semibold text-gray-900 dark:text-white">{stats.activeTorrents}</p>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
        <div class="flex items-center">
          <div class="p-3 bg-purple-100 dark:bg-purple-900 rounded-full">
            <Clock class="w-6 h-6 text-purple-600 dark:text-purple-400" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Terminés</p>
            <p class="text-2xl font-semibold text-gray-900 dark:text-white">{stats.completedTorrents}</p>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
        <div class="flex items-center">
          <div class="p-3 bg-orange-100 dark:bg-orange-900 rounded-full">
            <Server class="w-6 h-6 text-orange-600 dark:text-orange-400" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Services OK</p>
            <p class="text-2xl font-semibold text-gray-900 dark:text-white">{stats.servicesOnline}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Torrents récents -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow">
      <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Torrents récents</h2>
      </div>
      <div class="p-6">
        {#if recentTorrents.length > 0}
          <div class="space-y-4">
            {#each recentTorrents as torrent}
              <div class="flex items-center justify-between py-3 border-b border-gray-100 dark:border-gray-700 last:border-b-0">
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
                    {torrent.name}
                  </p>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {torrent.addedAt}
                  </p>
                </div>
                <div class="ml-4 flex items-center">
                  <span class="px-2 py-1 text-xs font-medium rounded-full
                    {torrent.status === 'completed' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' :
                      torrent.status === 'downloading' ? 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300' :
                      torrent.status === 'error' ? 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300' :
                      'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'}">
                    {torrent.status}
                  </span>
                </div>
              </div>
            {/each}
          </div>
        {:else}
          <p class="text-gray-500 dark:text-gray-400 text-center py-8">
            Aucun torrent récent
          </p>
        {/if}
      </div>
    </div>
  {/if}
</div>
