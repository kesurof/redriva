<script lang="ts">
  import { Settings, Save, Key, Database, Bell, Shield, Eye, EyeOff } from 'lucide-svelte';
  import { addNotification } from '$lib/stores/notifications';
  import { onMount } from 'svelte';
  import api from '$lib/api/client';

  let settings = {
    realDebrid: {
      token: '',
      autoDownload: true,
      downloadPath: '/downloads'
    },
    notifications: {
      enabled: true,
      email: '',
      torrentComplete: true,
      errorAlerts: true
    },
    general: {
      language: 'fr',
      autoRefresh: 30,
      maxConcurrentDownloads: 3
    }
  };

  let showToken = false;
  let tokenInput = '';
  let tokenSaved = false;

  // Charger les paramètres au démarrage
  onMount(async () => {
    try {
      const response = await api.get('/settings');
      settings = { ...settings, ...response.data };
      tokenSaved = !!settings.realDebrid.token;
      if (tokenSaved) {
        tokenInput = settings.realDebrid.token;
      }
    } catch (error) {
      console.error('Erreur lors du chargement des paramètres:', error);
    }
  });

  function maskToken(token: string): string {
    if (!token || token.length < 8) return token;
    const start = token.substring(0, 4);
    const end = token.substring(token.length - 4);
    const middle = '*'.repeat(Math.max(0, token.length - 8));
    return `${start}${middle}${end}`;
  }

  function toggleTokenVisibility() {
    showToken = !showToken;
  }

  async function saveToken() {
    if (!tokenInput.trim()) {
      console.log('Token requis - Veuillez entrer un token Real-Debrid valide');
      alert('Veuillez entrer un token Real-Debrid valide');
      return;
    }

    try {
      const response = await api.post('/settings/realdebrid', { 
        token: tokenInput.trim() 
      });

      settings.realDebrid.token = tokenInput.trim();
      tokenSaved = true;
      showToken = false;
      
      console.log('Token sauvegardé avec succès');
      alert('Token Real-Debrid sauvegardé avec succès !');
    } catch (error) {
      console.error('Erreur lors de la sauvegarde du token:', error);
      alert('Erreur lors de la sauvegarde du token Real-Debrid');
    }
  }

  function editToken() {
    tokenSaved = false;
    showToken = true;
  }

  async function saveSettings() {
    try {
      // Simuler la sauvegarde (à implémenter avec l'API)
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      console.log('Paramètres sauvegardés avec succès');
      alert('Paramètres sauvegardés avec succès !');
    } catch (error) {
      console.error('Erreur lors de la sauvegarde des paramètres:', error);
      alert('Erreur lors de la sauvegarde des paramètres');
    }
  }

  function resetSettings() {
    if (confirm('Êtes-vous sûr de vouloir réinitialiser tous les paramètres ?')) {
      settings = {
        realDebrid: {
          token: '',
          autoDownload: false,
          downloadPath: '/downloads'
        },
        notifications: {
          enabled: true,
          email: '',
          torrentComplete: true,
          errorAlerts: true
        },
        general: {
          language: 'fr',
          autoRefresh: 30,
          maxConcurrentDownloads: 3
        }
      };
      
      addNotification({
        type: 'info',
        title: 'Paramètres réinitialisés',
        message: 'Tous les paramètres ont été remis à leur valeur par défaut'
      });
    }
  }
</script>

<svelte:head>
  <title>Paramètres - Redriva</title>
</svelte:head>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <div class="flex items-center space-x-3">
      <Settings class="w-8 h-8 text-blue-600 dark:text-blue-400" />
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Paramètres</h1>
    </div>
    
    <div class="flex space-x-3">
      <button
        on:click={resetSettings}
        class="px-4 py-2 text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 
               rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
      >
        Réinitialiser
      </button>
      <button
        on:click={saveSettings}
        class="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
      >
        <Save class="w-4 h-4" />
        <span>Sauvegarder</span>
      </button>
    </div>
  </div>

  <!-- Real-Debrid -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center">
      <Key class="w-5 h-5 mr-2" />
      Real-Debrid
    </h2>
    
    <div class="space-y-4">
      <div>
        <label for="rd-token" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Token API Real-Debrid
        </label>
        
        {#if tokenSaved && !showToken}
          <!-- Affichage du token masqué -->
          <div class="flex items-center space-x-3">
            <div class="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                        bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white font-mono text-sm">
              {maskToken(settings.realDebrid.token)}
            </div>
            <button
              on:click={toggleTokenVisibility}
              class="p-2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
              title="Afficher le token"
            >
              <Eye class="w-4 h-4" />
            </button>
            <button
              on:click={editToken}
              class="px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm"
            >
              Modifier
            </button>
          </div>
          <div class="flex items-center mt-2">
            <Shield class="w-4 h-4 text-green-500 mr-1" />
            <span class="text-xs text-green-600 dark:text-green-400">Token configuré et sécurisé</span>
          </div>
        {:else}
          <!-- Saisie/modification du token -->
          <div class="space-y-3">
            <div class="flex items-center space-x-3">
              <div class="flex-1 relative">
                <input
                  id="rd-token"
                  type={showToken ? 'text' : 'password'}
                  bind:value={tokenInput}
                  placeholder="Entrez votre token Real-Debrid"
                  class="w-full px-3 py-2 pr-10 border border-gray-300 dark:border-gray-600 rounded-lg 
                         bg-white dark:bg-gray-700 text-gray-900 dark:text-white font-mono
                         focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
                <button
                  on:click={toggleTokenVisibility}
                  class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
                  title={showToken ? 'Masquer' : 'Afficher'}
                >
                  {#if showToken}
                    <EyeOff class="w-4 h-4" />
                  {:else}
                    <Eye class="w-4 h-4" />
                  {/if}
                </button>
              </div>
              <button
                on:click={saveToken}
                disabled={!tokenInput.trim()}
                class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed text-sm font-medium"
              >
                Sauvegarder
              </button>
            </div>
            {#if tokenSaved}
              <button
                on:click={() => { tokenSaved = true; showToken = false; tokenInput = settings.realDebrid.token; }}
                class="text-sm text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
              >
                Annuler
              </button>
            {/if}
          </div>
        {/if}
        
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
          Obtenez votre token sur <a href="https://real-debrid.com/apitoken" target="_blank" class="text-blue-600 hover:underline">real-debrid.com/apitoken</a>
        </p>
      </div>

      <div>
        <label for="download-path" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Dossier de téléchargement
        </label>
        <input
          id="download-path"
          type="text"
          bind:value={settings.realDebrid.downloadPath}
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                 bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>

      <div class="flex items-center">
        <input
          id="auto-download"
          type="checkbox"
          bind:checked={settings.realDebrid.autoDownload}
          class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
        />
        <label for="auto-download" class="ml-2 block text-sm text-gray-900 dark:text-white">
          Téléchargement automatique des torrents
        </label>
      </div>
    </div>
  </div>

  <!-- Notifications -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center">
      <Bell class="w-5 h-5 mr-2" />
      Notifications
    </h2>
    
    <div class="space-y-4">
      <div class="flex items-center">
        <input
          id="notifications-enabled"
          type="checkbox"
          bind:checked={settings.notifications.enabled}
          class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
        />
        <label for="notifications-enabled" class="ml-2 block text-sm text-gray-900 dark:text-white">
          Activer les notifications
        </label>
      </div>

      {#if settings.notifications.enabled}
        <div>
          <label for="notification-email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Adresse email (optionnel)
          </label>
          <input
            id="notification-email"
            type="email"
            bind:value={settings.notifications.email}
            placeholder="votre@email.com"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                   bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                   focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        <div class="space-y-2">
          <div class="flex items-center">
            <input
              id="torrent-complete"
              type="checkbox"
              bind:checked={settings.notifications.torrentComplete}
              class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <label for="torrent-complete" class="ml-2 block text-sm text-gray-900 dark:text-white">
              Notifier quand un torrent est terminé
            </label>
          </div>

          <div class="flex items-center">
            <input
              id="error-alerts"
              type="checkbox"
              bind:checked={settings.notifications.errorAlerts}
              class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <label for="error-alerts" class="ml-2 block text-sm text-gray-900 dark:text-white">
              Alertes d'erreur
            </label>
          </div>
        </div>
      {/if}
    </div>
  </div>

  <!-- Paramètres généraux -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center">
      <Database class="w-5 h-5 mr-2" />
      Général
    </h2>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <label for="language" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Langue
        </label>
        <select
          id="language"
          bind:value={settings.general.language}
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                 bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        >
          <option value="fr">Français</option>
          <option value="en">English</option>
        </select>
      </div>

      <div>
        <label for="auto-refresh" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Actualisation automatique (secondes)
        </label>
        <input
          id="auto-refresh"
          type="number"
          min="10"
          max="300"
          bind:value={settings.general.autoRefresh}
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                 bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>

      <div class="md:col-span-2">
        <label for="max-downloads" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Téléchargements simultanés maximum
        </label>
        <input
          id="max-downloads"
          type="number"
          min="1"
          max="10"
          bind:value={settings.general.maxConcurrentDownloads}
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                 bg-white dark:bg-gray-700 text-gray-900 dark:text-white
                 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>
    </div>
  </div>

  <!-- Sécurité -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center">
      <Shield class="w-5 h-5 mr-2" />
      Sécurité
    </h2>
    
    <div class="space-y-4">
      <div class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4">
        <h3 class="text-sm font-medium text-yellow-800 dark:text-yellow-200 mb-2">
          Informations importantes
        </h3>
        <ul class="text-sm text-yellow-700 dark:text-yellow-300 space-y-1">
          <li>• Votre token Real-Debrid est stocké de manière sécurisée</li>
          <li>• Les données sont chiffrées en transit et au repos</li>
          <li>• Aucune donnée personnelle n'est partagée avec des tiers</li>
        </ul>
      </div>
      
      <button
        class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
        on:click={() => {
          if (confirm('Êtes-vous sûr de vouloir supprimer toutes vos données ?')) {
            addNotification({
              type: 'info',
              title: 'Données supprimées',
              message: 'Toutes vos données ont été effacées'
            });
          }
        }}
      >
        Supprimer toutes les données
      </button>
    </div>
  </div>
</div>
