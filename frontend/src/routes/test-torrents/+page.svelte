<script lang="ts">
  import { onMount } from 'svelte';

  let torrents: any[] = [];
  let loading = true;
  let error: string | null = null;

  async function loadTorrents() {
    try {
      console.log('Début du chargement des torrents');
      loading = true;
      
      const response = await fetch('/api/torrents');
      console.log('Response:', response);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const data = await response.json();
      console.log('Data received:', data);
      
      torrents = data || [];
      console.log('Torrents assignés:', torrents.length);
      
    } catch (err: any) {
      console.error('Erreur:', err);
      error = err.message;
    } finally {
      loading = false;
      console.log('Loading fini, torrents:', torrents.length);
    }
  }

  onMount(() => {
    console.log('Component mounted');
    loadTorrents();
  });
</script>

<div class="p-8">
  <h1 class="text-2xl font-bold mb-4">Test Torrents</h1>
  
  {#if loading}
    <p>Chargement...</p>
  {:else if error}
    <p class="text-red-500">Erreur: {error}</p>
  {:else if torrents.length === 0}
    <p>Aucun torrent trouvé</p>
  {:else}
    <div>
      <p>Nombre de torrents: {torrents.length}</p>
      <ul>
        {#each torrents as torrent}
          <li class="mb-2 p-2 border">
            <strong>{torrent.original_filename}</strong><br>
            Status: {torrent.status}<br>
            Taille: {torrent.bytes} bytes
          </li>
        {/each}
      </ul>
    </div>
  {/if}
</div>
