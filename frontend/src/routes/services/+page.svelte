<script lang="ts">
  import { onMount } from 'svelte';
  import { RefreshCw, CheckCircle, XCircle, AlertCircle } from 'lucide-svelte';
  import { servicesService, type ServiceStatus } from '$lib/api/services';
  import { addNotification } from '$lib/stores/notifications';

  let services: ServiceStatus[] = [];
  let loading = true;
  let refreshing = false;

  onMount(async () => {
    await loadServices();
  });

  async function loadServices() {
    try {
      loading = true;
      services = await servicesService.getStatus();
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

  async function refreshServices() {
    refreshing = true;
    await loadServices();
    refreshing = false;
    
    addNotification({
      type: 'info',
      title: 'Services actualisés',
      message: 'Le statut des services a été mis à jour'
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

  function formatResponseTime(responseTime?: number): string {
    if (!responseTime) return 'N/A';
    return `${responseTime}ms`;
  }
</script>

<svelte:head>
  <title>Services - Redriva</title>
</svelte:head>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Statut des Services</h1>
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

  {#if loading}
    <div class="flex items-center justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>
  {:else}
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

    {#if services.length === 0}
      <div class="text-center py-12">
        <AlertCircle class="w-12 h-12 text-gray-400 mx-auto mb-4" />
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">Aucun service configuré</h3>
        <p class="text-gray-500 dark:text-gray-400">
          Les services connectés apparaîtront ici une fois configurés
        </p>
      </div>
    {/if}
  {/if}
</div>
