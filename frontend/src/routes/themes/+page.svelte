<script lang="ts">
  import { Palette, Monitor, Sun, Moon } from 'lucide-svelte';
  import { themeStore, toggleDarkMode, setPrimaryColor, toggleCompact } from '$lib/stores/theme';
  import { addNotification } from '$lib/stores/notifications';

  $: theme = $themeStore;

  const colorPalette = [
    { name: 'Bleu', value: '#3B82F6' },
    { name: 'Indigo', value: '#6366F1' },
    { name: 'Violet', value: '#8B5CF6' },
    { name: 'Rose', value: '#EC4899' },
    { name: 'Rouge', value: '#EF4444' },
    { name: 'Orange', value: '#F97316' },
    { name: 'Ambre', value: '#F59E0B' },
    { name: 'Vert', value: '#10B981' },
    { name: 'Emeraude', value: '#059669' },
    { name: 'Teal', value: '#0D9488' },
    { name: 'Cyan', value: '#06B6D4' },
    { name: 'Slate', value: '#64748B' }
  ];

  function handleColorChange(color: string) {
    setPrimaryColor(color);
    addNotification({
      type: 'success',
      title: 'Couleur mise à jour',
      message: 'La couleur primaire a été changée avec succès'
    });
  }

  function handleModeToggle() {
    toggleDarkMode();
    addNotification({
      type: 'info',
      title: 'Thème changé',
      message: `Mode ${theme.mode === 'light' ? 'sombre' : 'clair'} activé`
    });
  }

  function handleCompactToggle() {
    toggleCompact();
    addNotification({
      type: 'info',
      title: 'Interface mise à jour',
      message: `Mode ${theme.compact ? 'normal' : 'compact'} activé`
    });
  }
</script>

<svelte:head>
  <title>Thèmes - Redriva</title>
</svelte:head>

<div class="space-y-6">
  <div class="flex items-center space-x-3">
    <Palette class="w-8 h-8 text-blue-600 dark:text-blue-400" />
    <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Configuration des Thèmes</h1>
  </div>

  <!-- Mode sombre/clair -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center">
      <Monitor class="w-5 h-5 mr-2" />
      Mode d'affichage
    </h2>
    
    <div class="grid grid-cols-2 gap-4">
      <button
        on:click={handleModeToggle}
        class="flex items-center justify-center space-x-3 p-4 rounded-lg border-2 transition-all
               {theme.mode === 'light' ? 
                 'border-blue-500 bg-blue-50 dark:bg-blue-900/20' : 
                 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'}"
      >
        <Sun class="w-6 h-6 text-yellow-500" />
        <span class="font-medium text-gray-900 dark:text-white">Mode Clair</span>
      </button>
      
      <button
        on:click={handleModeToggle}
        class="flex items-center justify-center space-x-3 p-4 rounded-lg border-2 transition-all
               {theme.mode === 'dark' ? 
                 'border-blue-500 bg-blue-50 dark:bg-blue-900/20' : 
                 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'}"
      >
        <Moon class="w-6 h-6 text-blue-500" />
        <span class="font-medium text-gray-900 dark:text-white">Mode Sombre</span>
      </button>
    </div>
  </div>

  <!-- Couleur primaire -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
      Couleur primaire
    </h2>
    
    <div class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-3">
      {#each colorPalette as color}
        <button
          on:click={() => handleColorChange(color.value)}
          class="relative group p-3 rounded-lg border-2 transition-all hover:scale-105
                 {theme.primaryColor === color.value ? 
                   'border-gray-400 dark:border-gray-500' : 
                   'border-gray-200 dark:border-gray-700'}"
          title={color.name}
        >
          <div 
            class="w-8 h-8 rounded-full mx-auto mb-2 shadow-md"
            style="background-color: {color.value}"
          ></div>
          <span class="text-xs text-gray-600 dark:text-gray-400 block text-center">
            {color.name}
          </span>
          
          {#if theme.primaryColor === color.value}
            <div class="absolute inset-0 flex items-center justify-center">
              <div class="w-4 h-4 bg-white dark:bg-gray-800 rounded-full flex items-center justify-center">
                <div class="w-2 h-2 bg-gray-900 dark:bg-white rounded-full"></div>
              </div>
            </div>
          {/if}
        </button>
      {/each}
    </div>
  </div>

  <!-- Options d'interface -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
      Options d'interface
    </h2>
    
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <div>
          <h3 class="font-medium text-gray-900 dark:text-white">Mode compact</h3>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Réduire l'espacement et la taille des éléments
          </p>
        </div>
        <button
          on:click={handleCompactToggle}
          class="relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent 
                 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2
                 {theme.compact ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-700'}"
        >
          <span
            class="pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 
                   transition duration-200 ease-in-out {theme.compact ? 'translate-x-5' : 'translate-x-0'}"
          ></span>
        </button>
      </div>
    </div>
  </div>

  <!-- Aperçu -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
      Aperçu du thème
    </h2>
    
    <div class="space-y-4">
      <div class="flex items-center space-x-4">
        <div 
          class="w-12 h-12 rounded-lg shadow-md"
          style="background-color: {theme.primaryColor}"
        ></div>
        <div>
          <h3 class="font-medium text-gray-900 dark:text-white">Couleur primaire</h3>
          <p class="text-sm text-gray-500 dark:text-gray-400">{theme.primaryColor}</p>
        </div>
      </div>
      
      <div class="grid grid-cols-2 gap-4">
        <div class="p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
          <h4 class="font-medium text-gray-900 dark:text-white mb-2">Carte exemple</h4>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Voici un exemple de carte avec le thème actuel appliqué.
          </p>
          <button 
            class="mt-3 px-4 py-2 text-sm text-white rounded-lg transition-colors"
            style="background-color: {theme.primaryColor}"
          >
            Bouton primaire
          </button>
        </div>
        
        <div class="p-4 border border-gray-200 dark:border-gray-700 rounded-lg">
          <h4 class="font-medium text-gray-900 dark:text-white mb-2">Statistiques</h4>
          <div class="flex items-center space-x-2">
            <div 
              class="w-3 h-3 rounded-full"
              style="background-color: {theme.primaryColor}"
            ></div>
            <span class="text-sm text-gray-600 dark:text-gray-400">85% complété</span>
          </div>
          <div class="mt-2 w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2">
            <div 
              class="h-2 rounded-full transition-all duration-300" 
              style="width: 85%; background-color: {theme.primaryColor}"
            ></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
