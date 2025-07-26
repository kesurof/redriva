<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { RefreshCw, CheckCircle, XCircle, AlertCircle, Server, Link, AlertTriangle, Clock, Play, Square, RotateCcw, Search } from 'lucide-svelte';
  import { servicesService, type ServiceStatus } from '$lib/api/services';
  import { addNotification } from '$lib/stores/notifications';
  import { env } from '$env/dynamic/public';

  // Configuration réseau depuis l'environnement
  const DOCKER_NETWORK = env.PUBLIC_VITE_DOCKER_NETWORK || 'redriva-net';

  let services: ServiceStatus[] = [];
  let loading = true;
  let refreshing = false;
  
  // Containers Docker
  let dockerContainers: any[] = [];
  let dockerLoading = true;
  let searchTerm = '';
  
  // Containers filtrés basés sur la recherche
  $: filteredContainers = dockerContainers.filter(container => 
    container.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    container.image.toLowerCase().includes(searchTerm.toLowerCase()) ||
    container.network.toLowerCase().includes(searchTerm.toLowerCase())
  );
  
  // Statistiques pour les modules dashboard
  let dashboardStats = {
    servicesActifs: 0,
    symlinksErrorCount: 0,
    torrentsError: 0,
    lastUpdate: new Date()
  };
  
  // Heure actuelle (mise à jour chaque seconde)
  let currentTime = new Date();
  
  // Mettre à jour l'heure toutes les secondes
  let timeInterval: any;
  
  onMount(async () => {
    await loadServices();
    await loadDockerContainers();
    
    // Démarrer l'horloge en temps réel
    timeInterval = setInterval(() => {
      currentTime = new Date();
    }, 1000);
  });
  
  // Nettoyer l'interval quand le composant est détruit
  onDestroy(() => {
    if (timeInterval) clearInterval(timeInterval);
  });

  async function loadServices() {
    try {
      loading = true;
      services = await servicesService.getStatus();
      
      // Calculer les statistiques pour les modules
      dashboardStats = {
        servicesActifs: services.filter(s => s.status === 'online').length,
        symlinksErrorCount: Math.floor(Math.random() * 5), // Simulé pour l'instant
        torrentsError: Math.floor(Math.random() * 3), // Simulé pour l'instant
        lastUpdate: new Date()
      };
    } catch (error) {
      addNotification({
        type: 'error',
        title: 'Erreur de chargement',
        message: 'Impossible de charger le statut des services'
      });
    } finally {
      loading = false;
    }
  }

  // Charger les containers Docker (appel API réel)
  async function loadDockerContainers() {
    try {
      dockerLoading = true;
      
      // Appel API réel vers le backend
      const response = await fetch('/api/docker/containers');
      
      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`);
      }
      
      const containers = await response.json();
      
      // Tri alphabétique par nom
      dockerContainers = containers.sort((a, b) => a.name.localeCompare(b.name));
      
    } catch (error) {
      console.error('Erreur lors du chargement des containers:', error);
      
      // Liste vide si l'API échoue - pas de simulation
      dockerContainers = [];
      
      addNotification({
        type: 'error',
        title: 'API Docker indisponible',
        message: 'Impossible de récupérer la liste des containers Docker'
      });
      
    } finally {
      dockerLoading = false;
    }
  }

  // Actions Docker réelles
  async function restartContainer(containerId: string, containerName: string) {
    try {
      addNotification({
        type: 'info',
        title: 'Container en cours de redémarrage',
        message: `Redémarrage de ${containerName}...`
      });
      
      // Appel API réel vers le backend pour redémarrer le container
      const response = await fetch(`/api/docker/containers/${containerName}/restart`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`);
      }
      
      // Recharger la liste des containers après redémarrage
      await loadDockerContainers();
      
      addNotification({
        type: 'success',
        title: 'Container redémarré',
        message: `${containerName} a été redémarré avec succès`
      });
    } catch (error) {
      console.error('Erreur lors du redémarrage:', error);
      addNotification({
        type: 'error',
        title: 'Erreur de redémarrage',
        message: `Impossible de redémarrer ${containerName}: ${error.message}`
      });
    }
  }

  async function stopContainer(containerId: string, containerName: string) {
    try {
      addNotification({
        type: 'warning',
        title: 'Container en cours d\'arrêt',
        message: `Arrêt de ${containerName}...`
      });
      
      // Appel API réel vers le backend pour arrêter le container
      const response = await fetch(`/api/docker/containers/${containerName}/stop`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`);
      }
      
      // Mettre à jour le statut localement
      dockerContainers = dockerContainers.map(container => 
        container.id === containerId 
          ? { ...container, status: 'stopped' }
          : container
      );
      
      addNotification({
        type: 'success',
        title: 'Container arrêté',
        message: `${containerName} a été arrêté avec succès`
      });
    } catch (error) {
      console.error('Erreur lors de l\'arrêt:', error);
      addNotification({
        type: 'error',
        title: 'Erreur d\'arrêt',
        message: `Impossible d'arrêter ${containerName}: ${error.message}`
      });
    }
  }

  async function refreshServices() {
    refreshing = true;
    await loadServices();
    await loadDockerContainers();
    refreshing = false;
    
    addNotification({
      type: 'info',
      title: 'Dashboard actualisé',
      message: 'Le statut des services et containers a été mis à jour'
    });
  }

  async function checkService(serviceName: string) {
    try {
      const updatedService = await servicesService.checkService(serviceName);
      services = services.map(s => 
        s.name === serviceName ? updatedService : s
      );
      
      addNotification({
        type: 'success',
        title: 'Service vérifié',
        message: `Le service ${serviceName} a été vérifié`
      });
    } catch (error) {
      addNotification({
        type: 'error',
        title: 'Erreur de vérification',
        message: `Impossible de vérifier le service ${serviceName}`
      });
    }
  }

  function getStatusIcon(status: string) {
    switch (status) {
      case 'online': return CheckCircle;
      case 'offline': return XCircle;
      default: return AlertCircle;
    }
  }

  function getStatusColor(status: string): string {
    switch (status) {
      case 'online': return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300';
      case 'offline': return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300';
      default: return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300';
    }
  }

  function getNetworkColor(network: string): string {
    switch (network) {
      case DOCKER_NETWORK: return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300';
      case 'traefik_proxy': return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300';
      default: return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-300';
    }
  }

  function formatResponseTime(responseTime?: number): string {
    if (!responseTime) return 'N/A';
    return `${responseTime}ms`;
  }
</script>

<svelte:head>
  <title>Dashboard - Redriva</title>
</svelte:head>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Dashboard</h1>
    <button
      on:click={refreshServices}
      disabled={refreshing}
      class="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg 
             hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
    >
      <RefreshCw class="w-4 h-4 {refreshing ? 'animate-spin' : ''}" />
      <span>Actualiser</span>
    </button>
  </div>

  <!-- Modules dashboard (4 cartes) -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
    <!-- Services Actifs -->
    <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
      <div class="flex items-center">
        <div class="p-3 bg-green-100 dark:bg-green-900 rounded-full">
          <Server class="w-6 h-6 text-green-600 dark:text-green-400" />
        </div>
        <div class="ml-4">
          <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Services Actifs</p>
          <p class="text-2xl font-semibold text-gray-900 dark:text-white">{dashboardStats.servicesActifs}</p>
        </div>
      </div>
    </div>

    <!-- Symlinks (liens cassés) -->
    <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
      <div class="flex items-center">
        <div class="p-3 bg-orange-100 dark:bg-orange-900 rounded-full">
          <Link class="w-6 h-6 text-orange-600 dark:text-orange-400" />
        </div>
        <div class="ml-4">
          <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Symlinks</p>
          <p class="text-2xl font-semibold text-gray-900 dark:text-white">{dashboardStats.symlinksErrorCount}</p>
        </div>
      </div>
    </div>

    <!-- Torrents (Error) -->
    <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
      <div class="flex items-center">
        <div class="p-3 bg-red-100 dark:bg-red-900 rounded-full">
          <AlertTriangle class="w-6 h-6 text-red-600 dark:text-red-400" />
        </div>
        <div class="ml-4">
          <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Torrents Error</p>
          <p class="text-2xl font-semibold text-gray-900 dark:text-white">{dashboardStats.torrentsError}</p>
        </div>
      </div>
    </div>

    <!-- Heure et Date actuelles -->
    <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
      <div class="flex items-center">
        <div class="p-3 bg-blue-100 dark:bg-blue-900 rounded-full">
          <Clock class="w-6 h-6 text-blue-600 dark:text-blue-400" />
        </div>
        <div class="ml-4">
          <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Heure actuelle</p>
          <p class="text-lg font-semibold text-gray-900 dark:text-white">
            {currentTime.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400">
            {currentTime.toLocaleDateString('fr-FR')}
          </p>
        </div>
      </div>
    </div>
  </div>

  {#if services.length > 0}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each services as service}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center space-x-3">
              <svelte:component 
                this={getStatusIcon(service.status)} 
                class="w-6 h-6 {service.status === 'online' ? 'text-green-500' : 
                                service.status === 'offline' ? 'text-red-500' : 'text-yellow-500'}"
              />
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                {service.name}
              </h3>
            </div>
            <span class="px-2 py-1 text-xs font-medium rounded-full {getStatusColor(service.status)}">
              {service.status}
            </span>
          </div>

          <div class="space-y-2 text-sm text-gray-600 dark:text-gray-400">
            <div class="flex justify-between">
              <span>Dernière vérification:</span>
              <span>{new Date(service.lastCheck).toLocaleString('fr-FR')}</span>
            </div>
            
            {#if service.responseTime}
              <div class="flex justify-between">
                <span>Temps de réponse:</span>
                <span>{formatResponseTime(service.responseTime)}</span>
              </div>
            {/if}
            
            {#if service.version}
              <div class="flex justify-between">
                <span>Version:</span>
                <span>{service.version}</span>
              </div>
            {/if}
          </div>

          <div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
            <button
              on:click={() => checkService(service.name)}
              class="w-full px-4 py-2 text-sm bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300
                     rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
            >
              Vérifier maintenant
            </button>
          </div>
        </div>
      {/each}
    </div>
  {/if}

  <!-- Section Docker Containers -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0 mb-6">
      <div>
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Containers Docker</h2>
        <p class="text-sm text-gray-500 dark:text-gray-400">
          {filteredContainers.length} / {dockerContainers.length} containers • Tri alphabétique
        </p>
      </div>
      
      <div class="flex items-center space-x-4">
        <!-- Champ de recherche -->
        <div class="relative">
          <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search class="w-4 h-4 text-gray-400" />
          </div>
          <input
            type="text"
            bind:value={searchTerm}
            placeholder="Rechercher un container..."
            class="pl-10 pr-4 py-2 w-64 text-sm border border-gray-300 dark:border-gray-600 
                   rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                   placeholder-gray-500 dark:placeholder-gray-400
                   focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
          />
          {#if searchTerm}
            <button
              on:click={() => searchTerm = ''}
              class="absolute inset-y-0 right-0 pr-3 flex items-center"
              title="Effacer la recherche"
            >
              <XCircle class="w-4 h-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" />
            </button>
          {/if}
        </div>
      </div>
    </div>

    <!-- Grille des containers (style torrents) -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each filteredContainers as container}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-4 hover:shadow-md transition-shadow duration-200">
          <!-- En-tête du container -->
          <div class="flex items-center justify-between mb-3">
            <div class="flex items-center space-x-3">
              <div class="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                <Server class="w-4 h-4 text-blue-600 dark:text-blue-400" />
              </div>
              <div class="flex-1 min-w-0">
                <h3 class="text-sm font-medium text-gray-900 dark:text-white truncate">
                  {container.name}
                </h3>
                <p class="text-xs text-gray-500 dark:text-gray-400 truncate">
                  {container.image}
                </p>
              </div>
            </div>
            
            <!-- Badge de statut -->
            <span class="inline-flex px-2 py-1 text-xs font-medium rounded-full {container.status === 'running' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'}">
              {container.status}
            </span>
          </div>

          <!-- Badge réseau -->
          <div class="mb-3">
            <span class="inline-flex px-2 py-1 text-xs font-medium rounded-full {getNetworkColor(container.network)}">
              {container.network}
            </span>
          </div>

          <!-- Métadonnées du container -->
          <div class="space-y-1 text-xs text-gray-600 dark:text-gray-400 mb-4">
            <div class="flex justify-between">
              <span>CPU:</span>
              <span>{container.cpu}</span>
            </div>
            <div class="flex justify-between">
              <span>RAM:</span>
              <span>{container.memory}</span>
            </div>
            <div class="flex justify-between">
              <span>Uptime:</span>
              <span>{container.uptime}</span>
            </div>
            <div class="flex justify-between">
              <span>Ports:</span>
              <span>{container.ports}</span>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex items-center space-x-2 pt-3 border-t border-gray-200 dark:border-gray-700">
            <button
              on:click={() => restartContainer(container.id, container.name)}
              class="flex-1 px-3 py-2 text-xs bg-orange-600 hover:bg-orange-700 text-white rounded-lg
                     flex items-center justify-center space-x-1 transition-colors duration-200"
              title="Redémarrer le container"
            >
              <RotateCcw class="w-3 h-3" />
              <span>Restart</span>
            </button>
            <button
              on:click={() => stopContainer(container.id, container.name)}
              class="flex-1 px-3 py-2 text-xs bg-red-600 hover:bg-red-700 text-white rounded-lg
                     flex items-center justify-center space-x-1 transition-colors duration-200"
              title="Arrêter le container"
            >
              <Square class="w-3 h-3" />
              <span>Stop</span>
            </button>
          </div>
        </div>
      {/each}
    </div>

    {#if filteredContainers.length === 0 && dockerContainers.length > 0}
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-12 text-center">
        <Search class="w-12 h-12 text-gray-400 mx-auto mb-4" />
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
          Aucun container trouvé
        </h3>
        <p class="text-gray-500 dark:text-gray-400">
          Aucun container ne correspond à votre recherche "{searchTerm}"
        </p>
        <button
          on:click={() => searchTerm = ''}
          class="mt-4 px-4 py-2 text-sm bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
        >
          Effacer la recherche
        </button>
      </div>
    {:else if dockerContainers.length === 0}
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-12 text-center">
        <Server class="w-12 h-12 text-gray-400 mx-auto mb-4" />
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
          Aucun container Docker trouvé
        </h3>
        <p class="text-gray-500 dark:text-gray-400">
          Les containers Docker apparaîtront ici une fois détectés
        </p>
      </div>
    {/if}
  </div>
</div>
