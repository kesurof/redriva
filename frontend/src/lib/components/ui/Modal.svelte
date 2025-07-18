<script lang="ts">
  export let open = false;
  export let onClose = () => {};
</script>
{#if open}
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white dark:bg-gray-800 p-6 rounded shadow-lg min-w-[300px] relative">
      <button class="absolute top-2 right-2" on:click={onClose}>✕</button>
      <slot />
    </div>
  </div>
{/if}
