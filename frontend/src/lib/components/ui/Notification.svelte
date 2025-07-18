<script lang="ts">
  export let message = '';
  export let type = 'info'; // 'success', 'error', 'warning'
</script>
<div class="fixed top-4 right-4 z-50">
  <div class={`px-4 py-2 rounded shadow text-white bg-${type === 'success' ? 'green' : type === 'error' ? 'red' : 'blue'}-500`}>
    {message}
  </div>
</div>
