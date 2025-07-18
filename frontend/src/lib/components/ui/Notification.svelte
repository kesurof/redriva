<script lang="ts">
  export let message = '';
  export let type = 'info'; // 'success', 'error', 'warning'
  export let onClose = () => {};
</script>
<div class="fixed top-4 right-4 z-50">
  <div class={`relative px-4 py-2 rounded shadow text-white bg-${type === 'success' ? 'green' : type === 'error' ? 'red' : 'blue'}-500 flex items-center`} role="alert" aria-live="assertive">
    <span class="flex-1">{message}</span>
    <button class="ml-2 text-white/80 hover:text-white text-lg" aria-label="Fermer" on:click={onClose}>×</button>
  </div>
</div>
