<script lang="ts">
  import { onMount } from 'svelte';

  let torrents: any[] = [];
  let loading = true;

  onMount(async () => {
    try {
      const response = await fetch('/api/torrents');
      const data = await response.json();
      torrents = data || [];
    } catch (err) {
      console.error('Erreur:', err);
    } finally {
      loading = false;
    }
  });
</script>

<div class="container mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">Torrents</h1>
  
  {#if loading}
    <div class="text-center py-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      <p class="mt-2 text-gray-600">Chargement...</p>
    </div>
  {:else if torrents.length === 0}
    <p class="text-gray-500">Aucun torrent trouvé</p>
  {:else}
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow">
      <div class="p-6">
        <p class="mb-4 text-gray-600 dark:text-gray-400">
          {torrents.length} torrent{torrents.length > 1 ? 's' : ''}
        </p>
        
        <div class="space-y-4">
          {#each torrents as torrent}
            <div class="border-b border-gray-200 dark:border-gray-700 pb-4 last:border-b-0">
              <div class="flex justify-between items-start">
                <div class="flex-1">
                  <h3 class="font-medium text-gray-900 dark:text-white">
                    {torrent.original_filename || 'Nom non disponible'}
                  </h3>
                  <div class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                    <span class="mr-4">Taille: {torrent.bytes ? Math.round(torrent.bytes / 1024 / 1024) + ' MB' : 'Inconnue'}</span>
                    <span class="mr-4">Status: {torrent.status || 'Inconnu'}</span>
                    <span>Host: {torrent.host || 'Inconnu'}</span>
                  </div>
                </div>
              </div>
            </div>
          {/each}
        </div>
      </div>
    </div>
  {/if}
</div>
