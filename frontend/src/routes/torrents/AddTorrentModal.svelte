<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Modal from '$lib/components/ui/Modal.svelte';
  import { t } from 'svelte-i18n';
  import { apiUrl } from '$lib/api.js';
  let magnet = '';
  let loading = false;
  let error = '';
  const dispatch = createEventDispatcher();
  export let open = false;
  export let onClose = () => {};

  async function submit() {
    loading = true;
    error = '';
    try {
      const res = await fetch(apiUrl('/api/torrents'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ magnet })
      });
      const data = await res.json();
      if (data.success) {
        dispatch('added');
        onClose();
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
  <h2 class="text-lg font-bold mb-2">{ $t('add') } Torrent</h2>
  <label for="magnet-input" class="block text-xs mb-1">{ $t('magnet_link') || 'Lien magnet' }</label>
  <input id="magnet-input" class="w-full border rounded px-2 py-1 mb-2" bind:value={magnet} placeholder="Magnet link..." />
  {#if error}
    <div class="text-red-500 text-sm mb-2">{error}</div>
  {/if}
  <button class="bg-blue-600 text-white px-4 py-2 rounded" on:click={submit} disabled={loading}>
    {#if loading}
      <span>{ $t('loading') }</span>
    {:else}
      <span>{ $t('add') }</span>
    {/if}
  </button>
</Modal>
