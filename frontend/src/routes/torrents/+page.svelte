<script lang="ts">
import { onMount } from 'svelte';
import { apiUrl } from '$lib/api.js';
  import Table from '$lib/components/ui/Table.svelte';
  import Loader from '$lib/components/ui/Loader.svelte';
  import Notification from '$lib/components/ui/Notification.svelte';
  import AddTorrentModal from './AddTorrentModal.svelte';
  import TorrentDetailModal from './TorrentDetailModal.svelte';
  import Toast from '$lib/components/ui/Toast.svelte';
  import { t } from 'svelte-i18n';

  let torrents = [];
  let loading = true;
  let error = '';
  let showNotif = false;
  let showAdd = false;
  let showDetail = false;
  let selectedId = '';
  let notifType = 'info';
  let toastMsg = '';
  let toastType = 'info';
  let showToast = false;

  async function fetchTorrents() {
    loading = true;
    try {
      const res = await fetch(apiUrl('/api/torrents'));
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

  function showToastMsg(msg: string, type: string = 'info') {
    toastMsg = msg;
    toastType = type;
    showToast = true;
  }

  async function deleteTorrent(id: string) {
    if (!confirm($t('delete') + ' ?')) return;
    loading = true;
    error = '';
    try {
      const res = await fetch(apiUrl(`/api/torrents/${id}`), { method: 'DELETE' });
      const data = await res.json();
      if (data.success) {
        notifType = 'success';
        error = $t('delete') + ' OK';
        showToastMsg($t('success_delete'), 'success');
        await fetchTorrents();
      } else {
        notifType = 'error';
        error = data.error || 'Erreur inconnue';
        showToastMsg(error, 'error');
      }
    } catch (e) {
      notifType = 'error';
      error = e.message;
      showToastMsg(error, 'error');
    } finally {
      showNotif = !!error;
      loading = false;
    }
  }

  function openDetail(id: string) {
    selectedId = id;
    showDetail = true;
  }
</script>

<h1 class="text-2xl font-bold mb-4 flex items-center justify-between">
  <span>{ $t('torrents') }</span>
  <button class="bg-blue-600 text-white px-4 py-2 rounded" on:click={() => showAdd = true}>{ $t('add') }</button>
</h1>

<AddTorrentModal open={showAdd} on:added={fetchTorrents} onClose={() => showAdd = false} />
<TorrentDetailModal open={showDetail} torrentId={selectedId} onClose={() => showDetail = false} />

{#if loading}
  <Loader />
{:else if showNotif}
  <Notification message={error} type={notifType} onClose={() => showNotif = false} />
{:else if torrents.length === 0}
  <p class="text-gray-500">{ $t('no_data') }</p>
{:else}
  <Table {columns} rows={torrents} onDelete={deleteTorrent} on:rowClick={e => openDetail(e.detail)} />
{/if}

<Toast message={toastMsg} type={toastType} onClose={() => showToast = false} duration={2500} />
