<script lang="ts">
	// Fichier de layout principal et unifié
	import '../app.css';
	import { page } from '$app/stores';
	import { onMount, type Snippet } from 'svelte';
	
	// Imports corrigés depuis le bon paquet Skeleton
	import { AppShell, AppBar, LightSwitch } from '@skeletonlabs/skeleton';

	// Import du store pour la sidebar
	import { sidebarOpen, theme } from '$lib/stores/preferences';

	// Typage pour les enfants du layout (contenu de la page)
	let { children }: { children: Snippet } = $props();

	// Navigation
	const navItems = [
		{ path: '/', label: 'Dashboard', icon: '📊' },
		{ path: '/torrents', label: 'Torrents', icon: '📁' },
		{ path: '/settings', label: 'Paramètres', icon: '⚙️' }
		// Note: la route /queue n'a pas encore de page, je l'ai retirée pour éviter les liens morts
	];

	// Gestion du thème au chargement
	onMount(() => {
		const savedTheme = localStorage.getItem('theme');
		if (savedTheme === 'dark' || (!savedTheme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
			theme.set('dark');
		}
	});

	// Effet réactif pour mettre à jour la classe `dark` et le localStorage
	$effect(() => {
		if (typeof document !== 'undefined') {
			if ($theme === 'dark') {
				document.documentElement.classList.add('dark');
				localStorage.setItem('theme', 'dark');
			} else {
				document.documentElement.classList.remove('dark');
				localStorage.setItem('theme', 'light');
			}
		}
	});
</script>

<!-- Utilisation de la méthode AppShell standard de Skeleton UI -->
<AppShell slotSidebarLeft="w-64 bg-surface-100-800-token" {sidebarOpen}>
	
    {#snippet header()}
		<!-- AppBar utilisant les snippets -->
		<AppBar>
			{#snippet lead()}
				<button class="lg:hidden btn btn-sm mr-4" onclick={() => ($sidebarOpen = !$sidebarOpen)}>
					<span>☰</span>
				</button>
				<strong class="text-xl uppercase tracking-wide">Redriva</strong>
			{/snippet}
			
            {#snippet trail()}
				<div class="flex items-center space-x-4">
					<!-- Utilisation du composant LightSwitch standard -->
					<LightSwitch />
					<div class="hidden sm:flex items-center space-x-2">
						<div class="w-2 h-2 bg-success-500 rounded-full animate-pulse"></div>
						<span class="text-sm">Connecté</span>
					</div>
				</div>
			{/snippet}
		</AppBar>
	{/snippet}

	<!-- Contenu de la Sidebar (Navigation) -->
	{#snippet sidebarLeft()}
		<nav class="list-nav p-4">
			<ul>
				{#each navItems as item}
					<li>
						<a
							href={item.path}
							class="flex items-center space-x-3 px-3 py-2 text-sm font-medium rounded-lg transition-colors duration-150 hover:bg-surface-200-700-token"
							class:bg-primary-500={$page.url.pathname === item.path}
							class:text-on-primary-token={$page.url.pathname === item.path}
							data-sveltekit-preload-data="hover"
							onclick={() => { if (window.innerWidth < 1024) $sidebarOpen = false; }}
						>
							<span class="text-lg">{item.icon}</span>
							<span>{item.label}</span>
						</a>
					</li>
				{/each}
			</ul>
		</nav>
	{/snippet}

	<!-- Contenu principal de la page -->
	<div class="container mx-auto p-4 md:p-8">
		{@render children()}
	</div>
	
</AppShell>
