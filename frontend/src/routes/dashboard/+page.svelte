<script lang="ts">
  import { t } from 'svelte-i18n';
  let stats = { total: 0, actifs: 0, termines: 0, erreurs: 0, volume: 0 };
  let torrents = [];
  // Filtres
  let search = '';
  let status = '';
  let date = '';
  let size = '';
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
      <li>Quota RD restant : 12 Go</li>
      <li>Slots utilisés : 3/5</li>
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
