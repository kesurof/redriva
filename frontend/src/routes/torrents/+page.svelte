<script lang="ts">
  import { onMount } from 'svelte';
  import { Plus, Download, Trash2, ExternalLink } from 'lucide-svelte';
  import { torrentService, type TorrentItem } from '$lib/api/torrents';
  import { addNotification } from '$lib/stores/notifications';

  let torrents: TorrentItem[] = [];
  let loading = true;
  let showAddModal = false;
  let newTorrentUrl = '';

  onMount(async () => {
    await loadTorrents();
  });

  async function loadTorrents() {
    try {
      loading = true;
      torrents = await torrentService.getAll();
    } catch (error) {
      addNotification({
        type: 'error',
        title: 'Erreur de chargement',
        message: 'Impossible de charger la liste des torrents'
      });
    } finally {
      loading = false;
    }
  }

  async function addTorrent() {
    if (!newTorrentUrl.trim()) return;

    try {
      await torrentService.add(newTorrentUrl);
      addNotification({
        type: 'success',
        title: 'Torrent ajouté',
        message: 'Le torrent a été ajouté avec succès'
      });
      
      newTorrentUrl = '';
      showAddModal = false;
      await loadTorrents();
    } catch (error) {
      addNotification({
        type: 'error',
        title: 'Erreur d\'ajout',
        message: 'Impossible d\'ajouter le torrent'
      });
    }
  }

  async function deleteTorrent(id: string) {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce torrent ?')) return;

    try {
      await torrentService.delete(id);
      addNotification({
        type: 'success',
        title: 'Torrent supprimé',
        message: 'Le torrent a été supprimé avec succès'
      });
      await loadTorrents();
    } catch (error) {
      addNotification({
        type: 'error',
        title: 'Erreur de suppression',
        message: 'Impossible de supprimer le torrent'
      });
    }
  }

  function formatFileSize(bytes: number): string {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    let size = bytes;
    let unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return `${size.toFixed(1)} ${units[unitIndex]}`;
  }

  function getStatusColor(status: string): string {
    switch (status) {
      case 'completed': return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300';
      case 'downloading': return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300';
      case 'error': return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300';
      default: return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
    }
  }
</script>

<svelte:head>
  <title>Torrents - Redriva</title>
</svelte:head>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Gestion des Torrents</h1>
    <button
      on:click={() => showAddModal = true}
      class="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
    >
      <Plus class="w-4 h-4" />
      <span>Ajouter un torrent</span>
    </button>
  </div>

  {#if loading}
    <div class="flex items-center justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>
  {:else}
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
      {#if torrents.length > 0}
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Nom
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Taille
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Progression
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Statut
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              {#each torrents as torrent}
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm font-medium text-gray-900 dark:text-white">
                      {torrent.name}
                    </div>
                    <div class="text-sm text-gray-500 dark:text-gray-400">
                      Ajouté le {new Date(torrent.addedAt).toLocaleDateString('fr-FR')}
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                    {formatFileSize(torrent.size)}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <div class="w-16 bg-gray-200 dark:bg-gray-700 rounded-full h-2 mr-2">
                        <div 
                          class="bg-blue-600 h-2 rounded-full transition-all duration-300" 
                          style="width: {torrent.progress}%"
                        ></div>
                      </div>
                      <span class="text-sm text-gray-900 dark:text-white">{torrent.progress}%</span>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="px-2 py-1 text-xs font-medium rounded-full {getStatusColor(torrent.status)}">
                      {torrent.status}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                    {#if torrent.downloadUrl}
                      <a
                        href={torrent.downloadUrl}
                        target="_blank"
                        class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                        title="Télécharger"
                      >
                        <Download class="w-4 h-4" />
                      </a>
                    {/if}
                    <button
                      on:click={() => deleteTorrent(torrent.id)}
                      class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300"
                      title="Supprimer"
                    >
                      <Trash2 class="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {:else}
        <div class="text-center py-12">
          <Download class="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">Aucun torrent</h3>
          <p class="text-gray-500 dark:text-gray-400 mb-4">Commencez par ajouter votre premier torrent</p>
          <button
            on:click={() => showAddModal = true}
            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Ajouter un torrent
          </button>
        </div>
      {/if}
    </div>
  {/if}
</div>

<!-- Modal d'ajout de torrent -->
{#if showAddModal}
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-xl p-6 w-full max-w-md mx-4">
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Ajouter un torrent</h2>
      
      <div class="space-y-4">
        <div>
          <label for="torrent-url" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            URL Magnet ou lien torrent
          </label>
          <input
            id="torrent-url"
            type="text"
            bind:value={newTorrentUrl}
            placeholder="magnet:?xt=urn:btih:..."
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                   bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                   focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>
      </div>

      <div class="flex justify-end space-x-3 mt-6">
        <button
          on:click={() => { showAddModal = false; newTorrentUrl = ''; }}
          class="px-4 py-2 text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 
                 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
        >
          Annuler
        </button>
        <button
          on:click={addTorrent}
          disabled={!newTorrentUrl.trim()}
          class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 
                 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          Ajouter
        </button>
      </div>
    </div>
  </div>
{/if}
