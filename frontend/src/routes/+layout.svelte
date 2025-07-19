<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { theme, sidebarOpen, toggleTheme, toggleSidebar } from '$lib/stores';
	import { api } from '$lib/api';

	let { children } = $props();

	// Icônes SVG
	const menuIcon = `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>`;
	const sunIcon = `<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>`;
	const moonIcon = `<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path></svg>`;
	const closeIcon = `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>`;

	// Navigation items
	const navItems = [
		{ href: '/', label: 'Dashboard', icon: '📊' },
		{ href: '/torrents', label: 'Torrents', icon: '📁' },
		{ href: '/queue', label: 'Queue', icon: '⏳' },
		{ href: '/settings', label: 'Paramètres', icon: '⚙️' }
	];

	onMount(() => {
		// Initialiser le thème depuis localStorage
		const savedTheme = localStorage.getItem('theme');
		if (savedTheme === 'dark' || (!savedTheme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
			theme.set('dark');
			document.documentElement.classList.add('dark');
		}

		// Test de connectivité API
		api.ping().then(response => {
			if (!response.success) {
				console.warn('API non accessible:', response.error);
			}
		});
	});

	// Réactivité pour le thème avec $effect (mode runes)
	$effect(() => {
		if (typeof window !== 'undefined') {
			if ($theme === 'dark') {
				document.documentElement.classList.add('dark');
				localStorage.setItem('theme', 'dark');
			} else {
				document.documentElement.classList.remove('dark');
				localStorage.setItem('theme', 'light');
			}
		}
	});

	function handleThemeToggle() {
		toggleTheme();
	}
</script>

<div class="h-screen flex bg-gray-50 dark:bg-gray-900 transition-colors duration-200">
	<!-- Sidebar -->
	<div class="
		{$sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
		fixed inset-y-0 left-0 z-50 w-64 bg-white dark:bg-gray-800 shadow-lg transform transition-transform duration-300 ease-in-out
		lg:translate-x-0 lg:static lg:inset-0
	">
		<!-- Header du sidebar -->
		<div class="flex items-center justify-between h-16 px-6 border-b border-gray-200 dark:border-gray-700">
			<h1 class="text-xl font-bold text-gray-900 dark:text-white">Redriva</h1>
			<button
				class="lg:hidden p-1 rounded-md text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
				onclick={toggleSidebar}
			>
				{@html closeIcon}
			</button>
		</div>

		<!-- Navigation -->
		<nav class="mt-6 px-3">
			{#each navItems as item}
				<a
					href={item.href}
					class="flex items-center px-3 py-2 mt-2 text-gray-700 rounded-md hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700 transition-colors duration-150"
				>
					<span class="mr-3">{item.icon}</span>
					{item.label}
				</a>
			{/each}
		</nav>
	</div>

	<!-- Overlay pour mobile -->
	{#if $sidebarOpen}
		<div
			class="fixed inset-0 z-40 bg-black bg-opacity-50 lg:hidden"
			onclick={toggleSidebar}
			role="button"
			tabindex="0"
			onkeydown={(e) => e.key === 'Escape' && toggleSidebar()}
		></div>
	{/if}

	<!-- Contenu principal -->
	<div class="flex-1 flex flex-col overflow-hidden">
		<!-- Header -->
		<header class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700">
			<div class="flex items-center justify-between h-16 px-6">
				<button
					class="lg:hidden p-1 rounded-md text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
					onclick={toggleSidebar}
				>
					{@html menuIcon}
				</button>

				<div class="flex items-center space-x-4">
					<!-- Toggle thème -->
					<button
						class="p-2 rounded-md text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors duration-150"
						onclick={handleThemeToggle}
						title="Changer le thème"
					>
						{@html $theme === 'dark' ? sunIcon : moonIcon}
					</button>

					<!-- Status indicateur -->
					<div class="flex items-center space-x-2">
						<div class="w-2 h-2 bg-green-500 rounded-full"></div>
						<span class="text-sm text-gray-600 dark:text-gray-400">Connecté</span>
					</div>
				</div>
			</div>
		</header>

		<!-- Contenu de la page -->
		<main class="flex-1 overflow-auto">
			{@render children()}
		</main>
	</div>
</div>
