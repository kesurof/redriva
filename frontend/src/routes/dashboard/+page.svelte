<script lang="ts">
  let syncStatus = '';
  let syncRunning = false;
  let showSyncToast = false;
  let syncStatusInterval: any = null;
  let syncProgress = { done: 0, total: 0 };
  let showSyncLogModal = false;
  let syncLog = [];
  let syncLogInterval: any = null;

  // Pour la mise à jour détails torrents
  let updateStatus = '';
  let updateRunning = false;
  let updateProgress = { done: 0, total: 0 };
  let showUpdateLogModal = false;
  let updateLog = [];
  let updateStatusInterval: any = null;
  let updateLogInterval: any = null;

  async function fetchUpdateStatus() {
    try {
      const res = await fetch(apiUrl('/api/admin/update-torrents-status'));
      if (res.ok) {
        const data = await res.json();
        updateRunning = data.running;
        updateStatus = data.status;
        updateProgress = data.progress || { done: 0, total: 0 };
      }
    } catch (e) {
      updateStatus = 'Erreur de statut';
      updateRunning = false;
      updateProgress = { done: 0, total: 0 };
    }
  }

  async function fetchUpdateLog() {
    try {
      const res = await fetch(apiUrl('/api/admin/update-torrents-log'));
      if (res.ok) {
        const data = await res.json();
        updateLog = data.log || [];
      }
    } catch (e) {
      updateLog = ['Erreur de lecture des logs'];
    }
  }

  let updateRateLimit = 60;
  // Persistance du rate limit dans localStorage
  const UPDATE_RATE_LIMIT_KEY = 'redriva_update_rate_limit';
  // Charger la valeur sauvegardée si présente
  if (typeof window !== 'undefined') {
    const saved = localStorage.getItem(UPDATE_RATE_LIMIT_KEY);
    if (saved && !isNaN(Number(saved))) {
      updateRateLimit = Number(saved);
    }
  }

  $: if (typeof window !== 'undefined') {
    // Sauvegarder la nouvelle valeur si elle change
    localStorage.setItem(UPDATE_RATE_LIMIT_KEY, String(updateRateLimit));
  }
  async function launchUpdate() {
    await fetchUpdateStatus();
    if (updateRunning) {
      updateStatus = 'Mise à jour déjà en cours';
      showUpdateLogModal = true;
      await fetchUpdateLog();
      return;
    }
    updateStatus = '';
    try {
      const res = await fetch(apiUrl('/api/admin/update-torrents'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rate_limit: updateRateLimit })
      });
      if (res.ok) {
        const data = await res.json();
        if (data.status === 'already_running') {
          updateStatus = 'Mise à jour déjà en cours';
        } else {
          updateStatus = 'Mise à jour lancée';
        }
      } else {
        updateStatus = 'Erreur lors du lancement';
      }
    } catch (e) {
      updateStatus = 'Erreur réseau';
    }
    showUpdateLogModal = true;
    await fetchUpdateStatus();
    await fetchUpdateLog();
  }

  async function fetchSyncStatus() {
    try {
      const res = await fetch(apiUrl('/api/admin/sync-status'));
      if (res.ok) {
        const data = await res.json();
        syncRunning = data.running;
        syncStatus = data.status;
        syncProgress = data.progress || { done: 0, total: 0 };
      }
    } catch (e) {
      syncStatus = 'Erreur de statut';
      syncRunning = false;
      syncProgress = { done: 0, total: 0 };
    }
  }

  async function fetchSyncLog() {
    try {
      const res = await fetch(apiUrl('/api/admin/sync-log'));
      if (res.ok) {
        const data = await res.json();
        syncLog = data.log || [];
      }
    } catch (e) {
      syncLog = ['Erreur de lecture des logs'];
    }
  }

  async function launchSync() {
    await fetchSyncStatus();
    if (syncRunning) {
      syncStatus = 'Synchronisation déjà en cours';
      showSyncToast = true;
      setTimeout(() => { showSyncToast = false; }, 4000);
      return;
    }
    syncStatus = '';
    showSyncToast = false;
    try {
      const res = await fetch(apiUrl('/api/admin/sync'), { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        if (data.status === 'already_running') {
          syncStatus = 'Synchronisation déjà en cours';
        } else {
          syncStatus = 'Synchronisation lancée';
        }
      } else {
        syncStatus = 'Erreur lors du lancement';
      }
    } catch (e) {
      syncStatus = 'Erreur réseau';
    }
    showSyncToast = true;
    setTimeout(() => { showSyncToast = false; }, 4000);
    await fetchSyncStatus();
    // Ouvre la popup log dès le lancement
    showSyncLogModal = true;
    await fetchSyncLog();
  }

  import { onMount, onDestroy } from 'svelte';
  import { t } from 'svelte-i18n';
  import { apiUrl } from '$lib/api.js';
  let stats = { total: 0, actifs: 0, termines: 0, erreurs: 0, volume: 0 };
  let torrents = [];
  // Filtres
  let search = '';
  let status = '';
  let date = '';
  let size = '';

  // Quotas dynamiques
  let quotaRest = null;
  let slotsUsed = null;
  let slotsTotal = null;

  // Logs dynamiques
  let logs = [];

  // Informations système dynamiques
  let system = { version: '', backend_status: '', last_backup: '' };

  // Support dynamique
  let support = { faq: [], links: [] };

  // Récupération des quotas, logs, sync status à l'initialisation
  onMount(async () => {
    await fetchSyncStatus();
    await fetchUpdateStatus();
    syncStatusInterval = setInterval(fetchSyncStatus, 2000);
    syncLogInterval = setInterval(() => {
      if (showSyncLogModal || syncRunning) fetchSyncLog();
    }, 2000);
    updateStatusInterval = setInterval(fetchUpdateStatus, 2000);
    updateLogInterval = setInterval(() => {
      if (showUpdateLogModal || updateRunning) fetchUpdateLog();
    }, 2000);
    try {
      const res = await fetch(apiUrl('/api/quotas'));
      if (res.ok) {
        const data = await res.json();
        quotaRest = data.quota_rest;
        slotsUsed = data.slots_used;
        slotsTotal = data.slots_total;
      }
    } catch (e) {}
    try {
      const res = await fetch(apiUrl('/api/logs'));
      if (res.ok) {
        const data = await res.json();
        logs = data.logs || [];
      }
    } catch (e) {}
    try {
      const res = await fetch(apiUrl('/api/system'));
      if (res.ok) {
        const data = await res.json();
        system = data;
      }
    } catch (e) {}
    try {
      const res = await fetch(apiUrl('/api/support'));
      if (res.ok) {
        const data = await res.json();
        support = data;
      }
    } catch (e) {}
  });

  onDestroy(() => {
    if (syncStatusInterval) clearInterval(syncStatusInterval);
    if (syncLogInterval) clearInterval(syncLogInterval);
    if (updateStatusInterval) clearInterval(updateStatusInterval);
    if (updateLogInterval) clearInterval(updateLogInterval);
  });
// ...fin du <script>

</script>

<h2 class="text-xl font-semibold mb-2 mt-8">{ $t('support') || 'Aide & support' }</h2>
<div class="bg-white dark:bg-gray-800 rounded shadow p-4 mb-8">
  <div class="mb-2 font-bold">FAQ</div>
  <ul class="mb-4 list-disc ml-6 text-xs">
    {#if support.faq.length === 0}
      <li>{ $t('no_faq') || 'Aucune question fréquente.' }</li>
    {:else}
      {#each support.faq as item}
        <li class="mb-1"><span class="font-semibold">{item.q}</span><br /><span class="text-gray-500">{item.a}</span></li>
      {/each}
    {/if}
  </ul>
  <div class="mb-2 font-bold">{ $t('links') || 'Liens utiles' }</div>
  <ul class="list-disc ml-6 text-xs">
    {#if support.links.length === 0}
      <li>{ $t('no_links') || 'Aucun lien.' }</li>
    {:else}
      {#each support.links as link}
        <li><a class="text-blue-600 underline" href={link.url} target="_blank" rel="noopener">{link.label}</a></li>
      {/each}
    {/if}
  </ul>
</div>
<!-- Actions globales -->
<div class="flex flex-wrap gap-4 mb-8">
  <button class="bg-green-600 text-white px-4 py-2 rounded">{ $t('add') || 'Ajouter' }</button>
  <button class="bg-blue-600 text-white px-4 py-2 rounded">{ $t('refresh') || 'Rafraîchir' }</button>
  <button class="bg-gray-600 text-white px-4 py-2 rounded">{ $t('export') || 'Exporter' }</button>
  <button class="bg-orange-600 text-white px-4 py-2 rounded" on:click={launchSync} disabled={syncRunning}>
    {syncRunning ? ($t('sync_in_progress') || 'Synchronisation en cours...') : ($t('sync_rd') || 'Synchroniser RD → SQLite')}
  </button>
  <button class="bg-gray-700 text-white px-4 py-2 rounded" on:click={() => { showSyncLogModal = true; fetchSyncLog(); }}>
    Voir logs synchro
  </button>
  <input type="number" min="5" max="300" step="1" class="border rounded px-2 py-1 w-24 mr-2" bind:value={updateRateLimit} title="Requêtes/minute" />
  <button class="bg-orange-500 text-white px-4 py-2 rounded" on:click={launchUpdate} disabled={updateRunning}>
    {updateRunning ? 'Mise à jour détails en cours...' : 'Mettre à jour détails torrents'}
  </button>
  <button class="bg-gray-700 text-white px-4 py-2 rounded" on:click={() => { showUpdateLogModal = true; fetchUpdateLog(); }}>
    Voir logs mise à jour
  </button>
<!-- Modal logs mise à jour détails torrents -->
<Modal bind:open={showUpdateLogModal} on:close={() => showUpdateLogModal = false}>
  <div class="flex items-center justify-between mb-2">
    <div class="font-bold">Logs mise à jour détails torrents</div>
    <button class="text-gray-500 hover:text-black text-xl" on:click={() => showUpdateLogModal = false}>×</button>
  </div>
  <div class="mb-2">
    <div class="h-2 w-full bg-gray-200 rounded">
      <div class="h-2 bg-orange-500 rounded" style="width: {updateProgress.total > 0 ? Math.round(100 * updateProgress.done / updateProgress.total) : 0}%"></div>
    </div>
    <div class="text-xs text-gray-600 mt-1">Progression : {updateProgress.done}/{updateProgress.total}</div>
  </div>
  <div class="bg-gray-900 text-green-100 font-mono text-xs rounded p-2 h-64 overflow-y-auto border border-gray-700">
    {#each updateLog as line}
      <div>{line}</div>
    {/each}
  </div>
  <div class="flex justify-end mt-2">
    <button class="bg-gray-700 text-white px-3 py-1 rounded" on:click={() => showUpdateLogModal = false}>Fermer</button>
  </div>
</Modal>
</div>

{#if showSyncToast}
  <div class="fixed top-4 right-4 z-50 px-4 py-2 rounded shadow text-white bg-blue-600">
    {syncStatus}
  </div>
{/if}

<!-- Modal logs synchro -->
<Modal bind:open={showSyncLogModal} on:close={() => showSyncLogModal = false}>
  <div class="flex items-center justify-between mb-2">
    <div class="font-bold">Logs synchronisation RD</div>
    <button class="text-gray-500 hover:text-black text-xl" on:click={() => showSyncLogModal = false}>×</button>
  </div>
  <div class="mb-2">
    <div class="h-2 w-full bg-gray-200 rounded">
      <div class="h-2 bg-blue-600 rounded" style="width: {syncProgress.total > 0 ? Math.round(100 * syncProgress.done / syncProgress.total) : 0}%"></div>
    </div>
    <div class="text-xs text-gray-600 mt-1">Progression : {syncProgress.done}/{syncProgress.total}</div>
  </div>
  <div class="bg-gray-900 text-green-100 font-mono text-xs rounded p-2 h-64 overflow-y-auto border border-gray-700">
    {#each syncLog as line}
      <div>{line}</div>
    {/each}
  </div>
  <div class="flex justify-end mt-2">
    <button class="bg-gray-700 text-white px-3 py-1 rounded" on:click={() => showSyncLogModal = false}>Fermer</button>
  </div>
</Modal>

<div class="mb-4 text-xs text-gray-500">
  <b>État synchronisation :</b> {syncRunning ? 'En cours' : syncStatus || 'Aucune'}
  {#if syncProgress.total > 0}
    <span class="ml-2">({syncProgress.done}/{syncProgress.total})</span>
  {/if}
</div>
<div class="mb-4 text-xs text-gray-500">
  <b>État mise à jour détails :</b> {updateRunning ? 'En cours' : updateStatus || 'Aucune'}
  {#if updateProgress.total > 0}
    <span class="ml-2">({updateProgress.done}/{updateProgress.total})</span>
  {/if}
</div>

<h2 class="text-xl font-semibold mb-2 mt-8">{ $t('system_info') || 'Informations système' }</h2>
<div class="bg-white dark:bg-gray-800 rounded shadow p-4 mb-8">
  <ul class="text-xs">
    <li><span class="font-bold">{ $t('version') || 'Version' } :</span> {system.version}</li>
    <li><span class="font-bold">{ $t('backend_status') || 'État backend' } :</span> {system.backend_status}</li>
    <li><span class="font-bold">{ $t('last_backup') || 'Dernier backup' } :</span> {system.last_backup}</li>
  </ul>
</div>
<h2 class="text-xl font-semibold mb-2 mt-8">{ $t('recent_logs') || 'Logs récents' }</h2>
<div class="bg-white dark:bg-gray-800 rounded shadow p-4 mb-8">
  <ul class="text-xs font-mono space-y-1">
    {#if logs.length === 0}
      <li class="text-gray-400">{ $t('no_logs') || 'Aucun log récent.' }</li>
    {:else}
      {#each logs as log}
        <li>
          <span class="text-gray-500">[{log.timestamp}]</span>
          <span class="font-bold {log.level === 'ERROR' ? 'text-red-600' : log.level === 'WARNING' ? 'text-yellow-600' : 'text-green-600'}">{log.level}</span>
          <span> {log.message}</span>
        </li>
      {/each}
    {/if}
  </ul>
</div>
import Modal from '$lib/components/ui/Modal.svelte';
</script>

<h1 class="text-2xl font-bold mb-6">{ $t('dashboard') || 'Dashboard' }</h1>

<!-- Filtres -->
<div class="flex flex-wrap gap-4 mb-6 items-end">
  <div>
    <label class="block text-xs mb-1">{ $t('search') || 'Recherche' }</label>
    <input class="border rounded px-2 py-1" placeholder="Nom..." bind:value={search} />
  </div>
  <div>
    <label class="block text-xs mb-1">{ $t('status') || 'Statut' }</label>
    <select class="border rounded px-2 py-1" bind:value={status}>
      <option value="">{ $t('all') || 'Tous' }</option>
      <option value="active">{ $t('active') || 'Actif' }</option>
      <option value="completed">{ $t('completed') || 'Terminé' }</option>
      <option value="error">{ $t('error') || 'Erreur' }</option>
    </select>
  </div>
  <div>
    <label class="block text-xs mb-1">{ $t('date') || 'Date' }</label>
    <input type="date" class="border rounded px-2 py-1" bind:value={date} />
  </div>
  <div>
    <label class="block text-xs mb-1">{ $t('size') || 'Taille min (Mo)' }</label>
    <input type="number" class="border rounded px-2 py-1" min="0" bind:value={size} />
  </div>
  <button class="bg-blue-600 text-white px-4 py-2 rounded" on:click={() => { /* à brancher */ }}>{ $t('filter') || 'Filtrer' }</button>
</div>

<div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
  <div class="bg-white dark:bg-gray-800 rounded shadow p-4">
    <div class="text-sm text-gray-500">{ $t('total_torrents') || 'Torrents total' }</div>
    <div class="text-2xl font-bold">{stats.total}</div>
  </div>
  <div class="bg-white dark:bg-gray-800 rounded shadow p-4">
    <div class="text-sm text-gray-500">{ $t('active') || 'Actifs' }</div>
    <div class="text-2xl font-bold">{stats.actifs}</div>
  </div>
  <div class="bg-white dark:bg-gray-800 rounded shadow p-4">
    <div class="text-sm text-gray-500">{ $t('completed') || 'Terminés' }</div>
    <div class="text-2xl font-bold">{stats.termines}</div>
  </div>
  <div class="bg-white dark:bg-gray-800 rounded shadow p-4">
    <div class="text-sm text-gray-500">{ $t('volume') || 'Volume téléchargé (Go)' }</div>
    <div class="text-2xl font-bold">{stats.volume}</div>
  </div>
</div>

<h2 class="text-xl font-semibold mb-2">{ $t('recent_torrents') || 'Torrents récents' }</h2>
<div class="overflow-x-auto">
  <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
    <thead>
      <tr>
        <th class="px-4 py-2">ID</th>
        <th class="px-4 py-2">{ $t('filename') || 'Nom' }</th>
        <th class="px-4 py-2">{ $t('status') || 'Statut' }</th>
        <th class="px-4 py-2">{ $t('size') || 'Taille' }</th>
        <th class="px-4 py-2">{ $t('added') || 'Ajouté' }</th>
        <th class="px-4 py-2">{ $t('actions') || 'Actions' }</th>
      </tr>
    </thead>
    <tbody>
      {#each torrents as t}
        <tr>
          <td class="px-4 py-2">{t.id}</td>
          <td class="px-4 py-2">{t.filename}</td>
          <td class="px-4 py-2">{t.status}</td>
          <td class="px-4 py-2">{t.size}</td>
          <td class="px-4 py-2">{t.added}</td>
          <td class="px-4 py-2">
            <!-- Actions rapides à venir -->
            <button class="bg-blue-600 text-white px-2 py-1 rounded text-xs mr-2">{ $t('details') || 'Détails' }</button>
            <button class="bg-red-600 text-white px-2 py-1 rounded text-xs">{ $t('delete') || 'Supprimer' }</button>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
</div>

<h2 class="text-xl font-semibold mb-2 mt-8">{ $t('alerts') || 'Alertes & notifications' }</h2>
<div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
  <div class="bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded shadow p-4">
    <div class="font-bold mb-1">{ $t('recent_errors') || 'Erreurs récentes' }</div>
    <ul class="text-xs list-disc ml-4">
      <li>Erreur API Real-Debrid (17/07/2025 14:12)</li>
      <li>Quota presque atteint</li>
    </ul>
  </div>
  <div class="bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200 rounded shadow p-4">
    <div class="font-bold mb-1">{ $t('dead_links') || 'Liens morts' }</div>
    <ul class="text-xs list-disc ml-4">
      <li>torrent123.mkv (lien expiré)</li>
    </ul>
  </div>
  <div class="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded shadow p-4">
    <div class="font-bold mb-1">{ $t('quotas') || 'Quotas' }</div>
    <ul class="text-xs list-disc ml-4">
      <li>
        {#if quotaRest !== null}
          { $t('quota_remaining') || 'Quota RD restant' } : {quotaRest} Go
        {:else}
          { $t('quota_remaining') || 'Quota RD restant' } : ...
        {/if}
      </li>
      <li>
        {#if slotsUsed !== null && slotsTotal !== null}
          { $t('slots_used') || 'Slots utilisés' } : {slotsUsed}/{slotsTotal}
        {:else}
          { $t('slots_used') || 'Slots utilisés' } : ...
        {/if}
      </li>
    </ul>
  </div>
</div>

<h2 class="text-xl font-semibold mb-2 mt-8">{ $t('trends') || 'Graphiques & tendances' }</h2>
<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
  <div class="bg-white dark:bg-gray-800 rounded shadow p-4">
    <div class="font-bold mb-2">{ $t('evolution') || 'Évolution du nombre de torrents' }</div>
    <div class="h-32 flex items-center justify-center text-gray-400">[Graphique ligne - à venir]</div>
  </div>
  <div class="bg-white dark:bg-gray-800 rounded shadow p-4">
    <div class="font-bold mb-2">{ $t('status_distribution') || 'Répartition des statuts' }</div>
    <div class="h-32 flex items-center justify-center text-gray-400">[Camembert - à venir]</div>
  </div>
</div>
