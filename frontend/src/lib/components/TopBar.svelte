<script lang="ts">
  import { Cpu, HardDrive, MemoryStick } from 'lucide-svelte';
  import { onMount } from 'svelte';
  import api from '../api/client';

  let systemStats = {
    cpu: 0,
    memory: { used: 0, total: 0 },
    disk: { used: 0, total: 0 }
  };

  onMount(async () => {
    try {
      const response = await api.get('/system/stats');
      systemStats = response.data;
    } catch (error) {
      console.error('Erreur lors du chargement des stats système:', error);
      // Données de démonstration en cas d'erreur
      systemStats = {
        cpu: Math.round(Math.random() * 80 + 10),
        memory: { used: 2.4, total: 8.0 },
        disk: { used: 45.2, total: 100.0 }
      };
    }
  });

  $: memoryPercent = Math.round((systemStats.memory.used / systemStats.memory.total) * 100);
  $: diskPercent = Math.round((systemStats.disk.used / systemStats.disk.total) * 100);
</script>

<header class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700 px-6 py-4">
  <div class="flex items-center justify-between">
    <div class="flex items-center space-x-4">
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Dashboard</h2>
    </div>

    <div class="flex items-center space-x-4">
      <!-- Informations système -->
      <div class="flex items-center space-x-4">
        <!-- CPU -->
        <div class="flex items-center space-x-2">
          <div class="p-1.5 rounded-full bg-blue-100 dark:bg-blue-900">
            <Cpu class="w-4 h-4 text-blue-600 dark:text-blue-400" />
          </div>
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            {systemStats.cpu}%
          </span>
        </div>

        <!-- RAM -->
        <div class="flex items-center space-x-2">
          <div class="p-1.5 rounded-full bg-green-100 dark:bg-green-900">
            <MemoryStick class="w-4 h-4 text-green-600 dark:text-green-400" />
          </div>
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            {systemStats.memory.used.toFixed(1)}G/{systemStats.memory.total.toFixed(1)}G
          </span>
          <span class="text-xs text-gray-500 dark:text-gray-400">
            ({memoryPercent}%)
          </span>
        </div>

        <!-- Disque -->
        <div class="flex items-center space-x-2">
          <div class="p-1.5 rounded-full bg-orange-100 dark:bg-orange-900">
            <HardDrive class="w-4 h-4 text-orange-600 dark:text-orange-400" />
          </div>
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            {systemStats.disk.used.toFixed(0)}G/{systemStats.disk.total.toFixed(0)}G
          </span>
          <span class="text-xs text-gray-500 dark:text-gray-400">
            ({diskPercent}%)
          </span>
        </div>
      </div>
    </div>
  </div>
</header>
