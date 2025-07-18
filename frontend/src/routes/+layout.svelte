<script>
  import { t } from 'svelte-i18n';
  let dark = false;
  let navOpen = false;

  function toggleDark() {
    dark = !dark;
    if (dark) {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    }
  }

  // Initialisation au chargement
  if (typeof window !== 'undefined') {
    const saved = localStorage.getItem('theme');
    dark = saved === 'dark' || (!saved && window.matchMedia('(prefers-color-scheme: dark)').matches);
    if (dark) document.documentElement.classList.add('dark');
  }
</script>

<div class="min-h-screen flex flex-col bg-gray-50 dark:bg-gray-900">
  <header class="bg-white dark:bg-gray-800 shadow">
    <div class="container mx-auto px-4 py-3 flex justify-between items-center">
      <h1 class="text-xl font-bold">Redriva</h1>
      <button class="md:hidden p-2" on:click={() => navOpen = !navOpen} aria-label="Menu">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
      </button>
      <nav class="space-x-4 hidden md:flex items-center">
        <a href="/torrents" class="hover:underline">{ $t('torrents') }</a>
        <a href="/downloads" class="hover:underline">{ $t('downloads') }</a>
        <a href="/scraper" class="hover:underline">{ $t('scraper') }</a>
        <a href="/settings" class="hover:underline">{ $t('settings') }</a>
        <button class="ml-4 px-2 py-1 rounded bg-gray-200 dark:bg-gray-700" on:click={toggleDark} aria-label="Toggle dark mode">
          {dark ? '🌙' : '☀️'}
        </button>
      </nav>
    </div>
    {#if navOpen}
      <nav class="md:hidden bg-white dark:bg-gray-800 px-4 pb-4 flex flex-col space-y-2">
        <a href="/torrents" class="hover:underline" on:click={() => navOpen = false}>{ $t('torrents') }</a>
        <a href="/downloads" class="hover:underline" on:click={() => navOpen = false}>{ $t('downloads') }</a>
        <a href="/scraper" class="hover:underline" on:click={() => navOpen = false}>{ $t('scraper') }</a>
        <a href="/settings" class="hover:underline" on:click={() => navOpen = false}>{ $t('settings') }</a>
        <button class="mt-2 px-2 py-1 rounded bg-gray-200 dark:bg-gray-700 w-max" on:click={() => { toggleDark(); navOpen = false; }} aria-label="Toggle dark mode">
          {dark ? '🌙' : '☀️'}
        </button>
      </nav>
    {/if}
  </header>
  <main class="flex-1 p-4 sm:p-6 container mx-auto w-full">
    <slot />
  </main>
  <footer class="bg-gray-200 dark:bg-gray-700 text-center py-2 text-xs">
    © 2025 Redriva – Tous droits réservés
  </footer>
</div>
