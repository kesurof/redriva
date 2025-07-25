<script lang="ts">
  import { onMount } from 'svelte';
  import { themeStore } from '../stores/theme';
  import Sidebar from './Sidebar.svelte';
  import TopBar from './TopBar.svelte';
  import NotificationContainer from './NotificationContainer.svelte';

  let darkMode = false;

  onMount(() => {
    themeStore.subscribe(theme => {
      darkMode = theme.mode === 'dark';
      
      // Appliquer le thème sombre au document
      if (darkMode) {
        document.documentElement.classList.add('dark');
      } else {
        document.documentElement.classList.remove('dark');
      }
      
      // Appliquer la couleur primaire
      document.documentElement.style.setProperty('--primary-color', theme.primaryColor);
    });
  });
</script>

<div class="app-layout min-h-screen bg-gray-50 dark:bg-gray-900 transition-colors">
  <Sidebar />
  
  <div class="app-content ml-64 transition-all duration-300">
    <TopBar />
    
    <main class="p-6">
      <slot />
    </main>
  </div>
  
  <NotificationContainer />
</div>

<style>
  :global(.app-layout) {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  }
</style>
