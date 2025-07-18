<script lang="ts">
  import { onMount } from 'svelte';
  export let message = '';
  export let type = 'info'; // 'success', 'error', 'warning'
  export let duration = 2500;
  export let onClose = () => {};
  let visible = true;
  onMount(() => {
    const timer = setTimeout(() => {
      visible = false;
      onClose();
    }, duration);
    return () => clearTimeout(timer);
  });
</script>
{#if visible}
  <div class={`fixed bottom-4 right-4 z-50 px-4 py-2 rounded shadow text-white bg-${type === 'success' ? 'green' : type === 'error' ? 'red' : 'blue'}-500 flex items-center`} role="status" aria-live="polite">
    <span class="flex-1">{message}</span>
    <button class="ml-2 text-white/80 hover:text-white text-lg" aria-label="Fermer" on:click={() => { visible = false; onClose(); }}>×</button>
  </div>
{/if}
