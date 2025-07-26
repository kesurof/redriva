<script lang="ts">
  import { onMount } from 'svelte';
  import { Activity, Download, Server, Clock, RefreshCw, Trash2, RotateCcw, Search, ChevronUp, ChevronDown, HardDrive, Signal, ExternalLink, Copy } from 'lucide-svelte';
  import api from '$lib/api/client';

  let stats = {
    totalTorrents: 0,
    activeTorrents: 0,
    completedTorrents: 0,
    servicesOnline: 0
  };

  let data = { torrents: [] };
  let filteredTorrents: any[] = [];
  let loading = true;
  let lastUpdate = new Date();
  let searchTerm = '';
  let sortField = 'addedAt';
  let sortDirection = 'desc';

  async function loadData() {
    try {
      loading = true;
      // Charger les vrais torrents récents depuis l'API (même endpoint que la page torrents)
      const response = await api.get('/torrents?limit=25');
      
      // L'API retourne un format RDM avec {success, data, error, meta}
      if (response.success) {
        data.torrents = response.data || [];
      } else {
        throw new Error(response.error || 'Erreur lors du chargement');
      }
      
      // Calculer les statistiques à partir des vrais données
      stats = {
        totalTorrents: data.torrents.length,
        activeTorrents: data.torrents.filter(t => t.status === 'downloading').length,
        completedTorrents: data.torrents.filter(t => t.status === 'downloaded' || t.status === 'completed').length,
        servicesOnline: 7 // Nombre de services configurés
      };
      
      lastUpdate = new Date();
    } catch (error) {
      console.error('Erreur lors du chargement des données:', error);
      // Utiliser des données par défaut en cas d'erreur
      data.torrents = [];
      stats = {
        totalTorrents: 0,
        activeTorrents: 0,
        completedTorrents: 0,
        servicesOnline: 0
      };
    } finally {
      loading = false;
    }
  }

  // Gestion de la recherche
  function handleSearch() {
    // La recherche est automatiquement réactive avec filteredTorrents
  }
  
  // Gestion du tri
  function handleSort(field) {
    if (sortField === field) {
      sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      sortField = field;
      sortDirection = 'asc';
    }
  }

  // Fonction pour trier les torrents
  function sortTorrents(torrents) {
    return [...torrents].sort((a, b) => {
      let aVal = a[sortField];
      let bVal = b[sortField];
      
      // Gestion spéciale pour les noms (support des différents formats)
      if (sortField === 'original_filename') {
        aVal = a.filename || a.original_filename || a.name || '';
        bVal = b.filename || b.original_filename || b.name || '';
      }
      
      // Gestion spéciale pour les dates (support des différents formats)
      if (sortField === 'addedAt') {
        aVal = new Date(a.added || a.addedAt);
        bVal = new Date(b.added || b.addedAt);
      }
      
      // Gestion spéciale pour les tailles (support des différents formats)
      if (sortField === 'bytes') {
        aVal = parseInt(a.size || a.bytes || 0);
        bVal = parseInt(b.size || b.bytes || 0);
      }
      
      // Gestion des chaînes
      if (typeof aVal === 'string' && typeof bVal === 'string') {
        aVal = aVal.toLowerCase();
        bVal = bVal.toLowerCase();
      }
      
      if (aVal < bVal) return sortDirection === 'asc' ? -1 : 1;
      if (aVal > bVal) return sortDirection === 'asc' ? 1 : -1;
      return 0;
    });
  }
  
  // Filtrage et tri réactifs
  $: filteredTorrents = sortTorrents(
    data.torrents.filter(torrent =>
      !searchTerm.trim() || 
      (torrent.filename || torrent.original_filename || torrent.name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (torrent.host || 'Real-Debrid').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (torrent.status || '').toLowerCase().includes(searchTerm.toLowerCase())
    )
  );

  // Fonctions utilitaires
  function formatDate(dateString: string): string {
    try {
      if (!dateString) return 'Date inconnue';
      const date = new Date(dateString);
      if (isNaN(date.getTime())) return 'Date invalide';
      return date.toLocaleDateString('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (error) {
      return 'Date invalide';
    }
  }

  function formatBytes(bytes: string | number): string {
    const size = typeof bytes === 'string' ? parseInt(bytes) : bytes;
    if (!size || isNaN(size)) return '0 B';
    
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(size) / Math.log(k));
    return parseFloat((size / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  // Fonction pour obtenir la couleur du statut
  function getStatusColor(status: string): string {
    switch (status?.toLowerCase()) {
      case 'downloaded':
      case 'completed':
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
    } catch (err) {
      console.error('Erreur lors de la copie:', err);
    }
  }

  // Fonction pour ouvrir un lien
  function openLink(url: string) {
    window.open(url, '_blank', 'noopener,noreferrer');
  }

  onMount(() => {
    loadData();
  });
</script>

<svelte:head>
  <title>Torrents - Redriva</title>
</svelte:head>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Torrents</h1>
    <div class="text-sm text-gray-500 dark:text-gray-400">
      Dernière mise à jour: {lastUpdate.toLocaleTimeString('fr-FR')}
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

    <!-- Header avec recherche et bouton actualiser -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
      <div class="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0">
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Torrents Récents</h2>
        
        <div class="flex items-center space-x-4">
          <!-- Recherche -->
          <div class="relative">
            <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Rechercher un torrent..."
              bind:value={searchTerm}
              on:input={handleSearch}
              class="pl-10 pr-4 py-2 w-64 border border-gray-300 dark:border-gray-600 rounded-lg
                     bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                     focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          
          <!-- Bouton actualiser -->
          <button
            on:click={loadData}
            class="w-10 h-10 bg-blue-600 hover:bg-blue-700 text-white rounded-lg
                   flex items-center justify-center transition-colors duration-200"
            title="Actualiser"
            aria-label="Actualiser la liste des torrents"
          >
            <RefreshCw class="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>

    <!-- Liste des torrents récents en cartes modernes -->
    <div class="space-y-3">
      {#if filteredTorrents.length > 0}
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
      {:else}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-12 text-center">
          <Download class="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
            {searchTerm.trim() ? 'Aucun torrent trouvé' : 'Aucun torrent récent'}
          </h3>
          <p class="text-gray-500 dark:text-gray-400">
            {searchTerm.trim() 
              ? `Aucun résultat pour "${searchTerm}"`
              : 'Les torrents récents apparaîtront ici'}
          </p>
        </div>
      {/if}
    </div>
  {/if}
</div>
