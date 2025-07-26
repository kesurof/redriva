<script lang="ts">
  import { onMount } from 'svelte';
  import { RefreshCw, Download, ExternalLink, Clock, HardDrive, Signal, Search, Copy, RotateCcw, Trash2 } from 'lucide-svelte';

  let torrents: any[] = [];
  let filteredTorrents: any[] = [];
  let loading = true;
  let refreshing = false;
  let searchTerm = '';

  async function loadTorrents() {
    try {
      loading = true;
      const response = await fetch('/api/torrents?limit=0'); // limit=0 pour récupération complète RDM
      
      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`);
      }
      
      const result = await response.json();
      
      // Format de réponse RDM
      if (result.success) {
        torrents = result.data || [];
        filteredTorrents = torrents;
        console.log(`Chargé ${torrents.length} torrents depuis l'API RDM`);
        console.log('Métadonnées:', result.meta);
      } else {
        throw new Error(result.error || 'Erreur inconnue');
      }
      
    } catch (err) {
      console.error('Erreur lors du chargement des torrents:', err);
      torrents = [];
      filteredTorrents = [];
    } finally {
      loading = false;
    }
  }

  // Fonction de recherche réactive
  function filterTorrents() {
    if (!searchTerm.trim()) {
      filteredTorrents = torrents;
    } else {
      const search = searchTerm.toLowerCase();
      filteredTorrents = torrents.filter(torrent => 
        (torrent.filename || torrent.original_filename || '').toLowerCase().includes(search) ||
        (torrent.status || '').toLowerCase().includes(search) ||
        (torrent.host || '').toLowerCase().includes(search)
      );
    }
  }

  // Réactivité pour la recherche
  $: if (searchTerm !== undefined) {
    filterTorrents();
  }

  async function refreshTorrents() {
    try {
      refreshing = true;
      
      // Appel de l'endpoint de rafraîchissement RDM
      const response = await fetch('/api/torrents/refresh', {
        method: 'POST'
      });
      
      if (response.ok) {
        const result = await response.json();
        if (result.success) {
          console.log(result.message);
          console.log('Stats de cache:', result.data);
          await loadTorrents();
        } else {
          throw new Error(result.error);
        }
      }
      
    } catch (error) {
      console.error('Erreur lors du rafraîchissement:', error);
    } finally {
      refreshing = false;
    }
  }

  onMount(loadTorrents);

  // Fonction utilitaire pour formater les bytes
  function formatBytes(bytes: number): string {
    if (!bytes || bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  // Fonction pour formater la date
  function formatDate(dateString: string): string {
    if (!dateString) return 'Date inconnue';
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch {
      return 'Date invalide';
    }
  }

  // Fonction pour obtenir la couleur du statut
  function getStatusColor(status: string): string {
    switch (status?.toLowerCase()) {
      case 'downloaded':
      case 'terminé':
        return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
      case 'downloading':
      case 'en cours':
        return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200';
      case 'waiting':
      case 'en attente':
        return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
      case 'error':
      case 'erreur':
        return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200';
      default:
        return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200';
    }
  }

  // Fonction pour copier l'ID dans le presse-papiers
  async function copyToClipboard(text: string) {
    try {
      await navigator.clipboard.writeText(text);
      // On pourrait ajouter une notification toast ici
    } catch (err) {
      console.error('Erreur lors de la copie:', err);
    }
  }

  // Fonction pour ouvrir un lien
  function openLink(url: string) {
    window.open(url, '_blank', 'noopener,noreferrer');
  }
</script>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <div class="container mx-auto px-4 py-8">
    <!-- Header avec titre et actions -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Torrents</h1>
        <p class="text-gray-600 dark:text-gray-400 mt-1">
          Gestion de vos téléchargements Real-Debrid
        </p>
      </div>
      
      <div class="flex items-center space-x-3">
        <button
          on:click={refreshTorrents}
          disabled={refreshing || loading}
          class="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed shadow-sm hover:shadow-md transform hover:-translate-y-0.5"
          title="Actualiser la liste des torrents"
          aria-label="Actualiser la liste des torrents"
        >
          <RefreshCw class="w-4 h-4 {refreshing ? 'animate-spin' : ''}" />
          <span class="font-medium">
            {refreshing ? 'Actualisation...' : 'Actualiser'}
          </span>
        </button>
      </div>
    </div>

    <!-- Barre de recherche -->
    {#if !loading && torrents.length > 0}
      <div class="mb-6">
        <div class="relative max-w-md">
          <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search class="h-5 w-5 text-gray-400" />
          </div>
          <input
            type="text"
            bind:value={searchTerm}
            placeholder="Rechercher dans les torrents..."
            class="block w-full pl-10 pr-3 py-3 border border-gray-300 dark:border-gray-600 rounded-lg leading-5 bg-white dark:bg-gray-800 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
          />
          {#if searchTerm}
            <div class="absolute inset-y-0 right-0 pr-3 flex items-center">
              <button
                on:click={() => searchTerm = ''}
                class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                title="Effacer la recherche"
                aria-label="Effacer la recherche"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          {/if}
        </div>
        
        {#if searchTerm && filteredTorrents.length !== torrents.length}
          <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
            {filteredTorrents.length} résultat{filteredTorrents.length > 1 ? 's' : ''} pour "<span class="font-medium">{searchTerm}</span>"
          </p>
        {/if}
      </div>
    {/if}

    <!-- États de chargement et contenu -->
    {#if loading}
      <div class="flex flex-col items-center justify-center py-16">
        <div class="relative">
          <div class="w-12 h-12 border-4 border-blue-200 rounded-full animate-spin border-t-blue-600"></div>
        </div>
        <p class="mt-4 text-gray-600 dark:text-gray-400 font-medium">Chargement des torrents...</p>
      </div>
    {:else if filteredTorrents.length === 0}
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-12 text-center">
        <Download class="w-12 h-12 text-gray-400 mx-auto mb-4" />
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
          {searchTerm.trim() ? 'Aucun torrent trouvé' : 'Aucun torrent disponible'}
        </h3>
        <p class="text-gray-500 dark:text-gray-400">
          {searchTerm.trim() 
            ? `Aucun résultat pour "${searchTerm}"`
            : 'Vous n\'avez pas encore de torrents dans votre compte Real-Debrid'}
        </p>
      </div>
    {:else}
      <!-- Liste des torrents avec la même présentation que le dashboard -->
      <div class="space-y-3">
        {#each filteredTorrents as torrent}
          <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-4 hover:shadow-md transition-shadow duration-200">
            <div class="flex items-center justify-between">
              <!-- Informations principales (première ligne) -->
              <div class="flex-1 min-w-0 pr-4">
                <div class="flex items-center space-x-3">
                  <div class="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                    <HardDrive class="w-5 h-5 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div class="flex-1 min-w-0">
                    <h3 class="text-sm font-medium text-gray-900 dark:text-white truncate">
                      {torrent.filename || torrent.original_filename || torrent.name || 'Nom non disponible'}
                    </h3>
                    <!-- Métadonnées (deuxième ligne) -->
                    <div class="flex items-center space-x-4 mt-1 text-xs text-gray-500 dark:text-gray-400">
                      <span class="flex items-center space-x-1">
                        <Signal class="w-3 h-3" />
                        <span>{formatBytes(torrent.size || torrent.bytes || 0)}</span>
                      </span>
                      <span class="flex items-center space-x-1">
                        <Clock class="w-3 h-3" />
                        <span>{new Date(torrent.added || torrent.addedAt).toLocaleDateString('fr-FR')}</span>
                      </span>
                      <span class="flex items-center space-x-1">
                        <span>Host: {torrent.host || 'Real-Debrid'}</span>
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- Badge de statut et actions -->
              <div class="flex items-center space-x-3">
                <!-- Badge de statut -->
                <span class="inline-flex px-2 py-1 text-xs font-medium rounded-full {getStatusColor(torrent.status)}">
                  {torrent.status}
                </span>
                
                <!-- Actions -->
                <div class="flex items-center space-x-2">
                  {#if torrent.links && torrent.links.length > 0}
                    <button
                      on:click={() => copyToClipboard(torrent.links[0])}
                      class="w-8 h-8 bg-blue-600 hover:bg-blue-700 text-white rounded-lg
                             flex items-center justify-center transition-colors duration-200"
                      title="Copier le lien"
                      aria-label="Copier le lien de téléchargement"
                    >
                      <Copy class="w-4 h-4" />
                    </button>
                    <button
                      on:click={() => openLink(torrent.links[0])}
                      class="w-8 h-8 bg-green-600 hover:bg-green-700 text-white rounded-lg
                             flex items-center justify-center transition-colors duration-200"
                      title="Ouvrir le lien"
                      aria-label="Ouvrir le lien dans un nouvel onglet"
                    >
                      <ExternalLink class="w-4 h-4" />
                    </button>
                  {/if}
                  <button
                    class="w-8 h-8 bg-orange-600 hover:bg-orange-700 text-white rounded-lg
                           flex items-center justify-center transition-colors duration-200"
                    title="Réinsérer"
                    aria-label="Réinsérer le torrent"
                  >
                    <RotateCcw class="w-4 h-4" />
                  </button>
                  <button
                    class="w-8 h-8 bg-red-600 hover:bg-red-700 text-white rounded-lg
                           flex items-center justify-center transition-colors duration-200"
                    title="Supprimer"
                    aria-label="Supprimer le torrent"
                  >
                    <Trash2 class="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        {/each}
      </div>
      
      <!-- Footer avec stats -->
      <div class="mt-8 text-center text-sm text-gray-500 dark:text-gray-400">
        <p>
          <span class="font-medium">{filteredTorrents.length}</span> torrent{filteredTorrents.length > 1 ? 's' : ''} affiché{filteredTorrents.length > 1 ? 's' : ''}
          {#if searchTerm && filteredTorrents.length !== torrents.length}
            sur <span class="font-medium">{torrents.length}</span> au total
          {/if}
        </p>
      </div>
    {/if}
  </div>
</div>
