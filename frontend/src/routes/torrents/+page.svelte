<script lang="ts">
  import { onMount } from 'svelte';
  import Table from '$lib/components/ui/Table.svelte';
  import Loader from '$lib/components/ui/Loader.svelte';
  import Notification from '$lib/components/ui/Notification.svelte';
  import AddTorrentModal from './AddTorrentModal.svelte';
  import { t } from 'svelte-i18n';

  let torrents = [];
  let loading = true;
  let error = '';
  let showNotif = false;
  let showAdd = false;

  async function fetchTorrents() {
    loading = true;
    try {
      const res = await fetch('/api/torrents');
      const data = await res.json();
      if (data.success) {
        torrents = data.data;
      } else {
        error = data.error || 'Erreur inconnue';
        showNotif = true;
      }
    } catch (e) {
      error = e.message;
      showNotif = true;
    } finally {
      loading = false;
    }
  }

  onMount(fetchTorrents);

  const columns = ['id', 'filename', 'status', 'size'];
</script>

<h1 class="text-2xl font-bold mb-4 flex items-center justify-between">
  <span>{ $t('torrents') }</span>
  <button class="bg-blue-600 text-white px-4 py-2 rounded" on:click={() => showAdd = true}>{ $t('add') }</button>
</h1>

<AddTorrentModal open={showAdd} on:added={fetchTorrents} onClose={() => showAdd = false} />

{#if loading}
  <Loader />
{:else if error}
  <Notification message={error} type="error" />
{:else if torrents.length === 0}
  <p class="text-gray-500">{ $t('no_data') }</p>
{:else}
  <Table {columns} rows={torrents} />
{/if}
