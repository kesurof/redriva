<script lang="ts">
  $: queueLabel = $t('queue') || "File d'attente";
  $: addLabel = $t('add') || 'Ajouter';
  $: torrentIdLabel = $t('torrent_id') || 'Torrent';
  $: priorityLabel = $t('priority') || 'Priorité';
  $: statusLabel = $t('status') || 'Statut';
  $: addedLabel = $t('added') || 'Ajouté';
  $: actionsLabel = $t('actions') || 'Actions';
  $: deleteLabel = $t('delete') || 'Supprimer';
import { onMount } from 'svelte';
import { apiUrl } from '$lib/api.js';
  import { t } from 'svelte-i18n';
  let queue = [];
  let loading = false;
  let error = '';

  async function fetchQueue() {
    loading = true;
    error = '';
    try {
      const res = await fetch(apiUrl('/api/queue'));
      if (res.ok) {
        queue = await res.json();
      } else {
        error = 'Erreur API';
      }
    } catch (e) {
      error = e.message;
    }
    loading = false;
  }

  async function changePriority(id: number, delta: number) {
    const item = queue.find(q => q.id === id);
    if (!item) return;
    const newPriority = item.priority + delta;
    await fetch(apiUrl(`/api/queue/${id}`), {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ priority: newPriority })
    });
    fetchQueue();
  }

  async function removeFromQueue(id: number) {
    await fetch(apiUrl(`/api/queue/${id}`), { method: 'DELETE' });
    fetchQueue();
  }

  let poller;
  let newTorrentId = '';

  function startPolling() {
    poller = setInterval(fetchQueue, 5000);
  }
  function stopPolling() {
    if (poller) clearInterval(poller);
  }

  async function addToQueue() {
    if (!newTorrentId) return;
    await fetch(apiUrl('/api/queue'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ torrent_id: newTorrentId })
    });
    newTorrentId = '';
    fetchQueue();
  }

  onMount(() => {
    fetchQueue();
    startPolling();
    return stopPolling;
  });
</script>


<h1 class="text-2xl font-bold mb-6">{queueLabel}</h1>

<form class="mb-4 flex gap-2" on:submit|preventDefault={addToQueue}>
  <label for="queue-torrent-id" class="block text-xs mb-1">ID du torrent à ajouter</label>
  <input id="queue-torrent-id" class="border rounded px-2 py-1" placeholder="ID du torrent à ajouter" bind:value={newTorrentId} />
  <button class="bg-green-600 text-white px-4 py-2 rounded" type="submit">{addLabel}</button>
</form>

{#if loading}
  <div class="text-gray-500">Chargement…</div>
{:else if error}
  <div class="text-red-600">{error}</div>
{:else}
  <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
    <thead>
      <tr>
        <th>ID</th>
        <th>{torrentIdLabel}</th>
        <th>{priorityLabel}</th>
        <th>{statusLabel}</th>
        <th>{addedLabel}</th>
        <th>{actionsLabel}</th>
      </tr>
    </thead>
    <tbody>
      {#each queue as q}
        <tr>
          <td>{q.id}</td>
          <td>{q.torrent_id}</td>
          <td>
            <button class="px-2" on:click={() => changePriority(q.id, -1)}>▲</button>
            {q.priority}
            <button class="px-2" on:click={() => changePriority(q.id, 1)}>▼</button>
          </td>
          <td>{q.status}</td>
          <td>{q.added_at}</td>
          <td>
            <button class="bg-red-600 text-white px-2 py-1 rounded text-xs" on:click={() => removeFromQueue(q.id)}>{deleteLabel}</button>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
{/if}
