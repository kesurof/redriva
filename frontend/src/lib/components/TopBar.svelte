<script lang="ts">
  import { Moon, Sun, User } from 'lucide-svelte';
  import { themeStore, toggleDarkMode } from '../stores/theme';
  import { authStore } from '../stores/auth';

  $: theme = $themeStore;
  $: auth = $authStore;
</script>

<header class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700 px-6 py-4">
  <div class="flex items-center justify-between">
    <div class="flex items-center space-x-4">
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Dashboard</h2>
    </div>

    <div class="flex items-center space-x-4">
      <!-- Bouton de basculement du thème -->
      <button
        on:click={toggleDarkMode}
        class="p-2 rounded-lg bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
        title={theme.mode === 'dark' ? 'Passer au mode clair' : 'Passer au mode sombre'}
      >
        {#if theme.mode === 'dark'}
          <Sun class="w-5 h-5 text-yellow-500" />
        {:else}
          <Moon class="w-5 h-5 text-gray-600" />
        {/if}
      </button>

      <!-- Profil utilisateur -->
      <div class="flex items-center space-x-3">
        <div class="p-2 rounded-full bg-blue-100 dark:bg-blue-900">
          <User class="w-5 h-5 text-blue-600 dark:text-blue-400" />
        </div>
        <div class="text-sm">
          <p class="font-medium text-gray-900 dark:text-white">
            {auth.user?.name || 'Utilisateur'}
          </p>
          <p class="text-gray-500 dark:text-gray-400">
            {auth.isAuthenticated ? 'Connecté' : 'Non connecté'}
          </p>
        </div>
      </div>
    </div>
  </div>
</header>
