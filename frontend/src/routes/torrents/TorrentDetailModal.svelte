<script lang="ts">
  import Modal from '$lib/components/ui/Modal.svelte';
  import { t } from 'svelte-i18n';
  import { apiUrl } from '$lib/api.js';
  export let open = false;
  export let onClose = () => {};
  export let torrentId: string = '';
  let loading = false;
  let error = '';
  let detail: any = null;

  $: if (open && torrentId) fetchDetail();

  async function fetchDetail() {
    if (!torrentId) return;
    loading = true;
    error = '';
    detail = null;
    try {
      const res = await fetch(apiUrl(`/api/torrents/${torrentId}`));
      const data = await res.json();
      if (data.success) {
        detail = data.data;
      } else {
        error = data.error || 'Erreur inconnue';
      }
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }
</script>
<Modal {open} {onClose}>
  <h2 class="text-lg font-bold mb-2">{ $t('details') } Torrent</h2>
  {#if loading}
    <div>{ $t('loading') }</div>
  {:else if error}
    <div class="text-red-500 text-sm mb-2">{error}</div>
  {:else if detail}
    <div class="space-y-2">
      <div><b>ID:</b> {detail.id}</div>
      <div><b>{ $t('filename') || 'Nom' }:</b> {detail.filename}</div>
      <div><b>{ $t('status') || 'Statut' }:</b> {detail.status}</div>
      <div><b>{ $t('size') || 'Taille' }:</b> {detail.size}</div>
      <div><b>Ajouté:</b> {detail.added}</div>
      <div><b>Liens:</b> <ul class="list-disc ml-4">{#each detail.links as l}<li>{l}</li>{/each}</ul></div>
    </div>
  {/if}
</Modal>
