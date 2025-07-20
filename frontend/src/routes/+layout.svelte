<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { AppBar } from '@skeletonlabs/skeleton-svelte';
	import { theme, sidebarOpen, toggleSidebar } from '$lib/stores';
	import { api } from '$lib/api';

	let { children } = $props();

	// Navigation items
	const navItems = [
		{ path: '/dashboard', label: 'Dashboard', icon: '📊' },
		{ path: '/torrents', label: 'Torrents', icon: '📁' },
		{ path: '/services', label: 'Services', icon: '⚙️' },
		{ path: '/arr-monitor', label: 'Arr-Monitor', icon: '📺' },
		{ path: '/symguard', label: 'SymGuard', icon: '🛡️' },
		{ path: '/configuration', label: 'Configuration', icon: '🔧' }
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

	function toggleTheme() {
		theme.update(current => current === 'light' ? 'dark' : 'light');
	}
</script>

<!-- AppShell Structure with Skeleton UI Components -->
<div class="h-screen flex flex-col bg-surface-50-900-token">
	<!-- Header avec AppBar -->
	<AppBar>
		{#snippet lead()}
			<button
				class="lg:hidden btn btn-sm mr-4"
				onclick={toggleSidebar}
				type="button"
			>
				<span>☰</span>
			</button>
			<strong class="text-xl uppercase tracking-wide">Redriva</strong>
		{/snippet}
		{#snippet trail()}
			<div class="flex items-center space-x-4">
				<!-- Light/Dark Switch personnalisé -->
				<button
					class="btn btn-sm variant-ghost-surface"
					onclick={toggleTheme}
					title="Changer le thème"
					type="button"
				>
					{#if $theme === 'dark'}
						<span class="text-lg">☀️</span>
					{:else}
						<span class="text-lg">🌙</span>
					{/if}
				</button>
				<!-- Status indicateur -->
				<div class="hidden sm:flex items-center space-x-2">
					<div class="w-2 h-2 bg-success-500 rounded-full"></div>
					<span class="text-sm">Connecté</span>
				</div>
			</div>
		{/snippet}
	</AppBar>

	<div class="flex flex-1 overflow-hidden">
		<!-- Sidebar -->
		<aside class="hidden lg:flex lg:flex-col lg:w-64 bg-surface-100-800-token border-r border-surface-300-600-token">
			<nav class="flex-1 p-4">
				<ul class="space-y-2">
					{#each navItems as item}
						<li>
							<a
								href={item.path}
								class="flex items-center space-x-3 px-3 py-2 text-sm font-medium rounded-lg transition-colors duration-150 hover:bg-surface-200-700-token"
								class:bg-primary-500={$page.url.pathname === item.path}
								class:text-primary-contrast-token={$page.url.pathname === item.path}
								data-sveltekit-preload-data="hover"
							>
								<span class="text-lg">{item.icon}</span>
								<span>{item.label}</span>
							</a>
						</li>
					{/each}
				</ul>
			</nav>
		</aside>

		<!-- Main Content -->
		<main class="flex-1 overflow-auto">
			<div class="container mx-auto p-8 space-y-8">
				{@render children()}
			</div>
		</main>
	</div>
</div>

<!-- Mobile Sidebar Overlay -->
{#if $sidebarOpen}
	<div 
		class="lg:hidden fixed inset-0 z-40 bg-surface-backdrop-token" 
		onclick={toggleSidebar}
		onkeydown={(e) => e.key === 'Escape' && toggleSidebar()}
		role="button"
		tabindex="0"
		aria-label="Fermer la sidebar"
	>
		<div class="fixed inset-y-0 left-0 z-50 w-64 bg-surface-50-900-token shadow-xl">
			<div class="flex items-center justify-between h-16 px-6 border-b border-surface-300-600-token">
				<h1 class="text-xl font-bold">Redriva</h1>
				<button class="btn btn-sm" onclick={toggleSidebar} type="button">
					<span>✕</span>
				</button>
			</div>
			<nav class="p-4">
				<ul class="space-y-2">
					{#each navItems as item}
						<li>
							<a
								href={item.path}
								class="flex items-center space-x-3 px-3 py-2 text-sm font-medium rounded-lg transition-colors duration-150 hover:bg-surface-200-700-token"
								class:bg-primary-500={$page.url.pathname === item.path}
								class:text-primary-contrast-token={$page.url.pathname === item.path}
								onclick={toggleSidebar}
								data-sveltekit-preload-data="hover"
							>
								<span class="text-lg">{item.icon}</span>
								<span>{item.label}</span>
							</a>
						</li>
					{/each}
				</ul>
			</nav>
		</div>
	</div>
{/if}
</script>

<AppShell>
	{#snippet header()}
		<AppBar>
			{#snippet lead()}
				<button
					class="lg:hidden btn btn-sm mr-4"
					onclick={toggleSidebar}
				>
					<span>☰</span>
				</button>
				<strong class="text-xl uppercase">Redriva</strong>
			{/snippet}
			{#snippet trail()}
				<div class="flex items-center space-x-4">
					<LightSwitch />
					<!-- Status indicateur -->
					<div class="hidden sm:flex items-center space-x-2">
						<div class="w-2 h-2 bg-success-500 rounded-full"></div>
						<span class="text-sm">Connecté</span>
					</div>
				</div>
			{/snippet}
		</AppBar>
	{/snippet}

	{#snippet sidebarLeft()}
		<nav class="list-nav p-4">
			<ul>
				{#each navItems as item}
					<li>
						<a
							href={item.path}
							class="option w-full"
							class:bg-primary-active-token={$page.url.pathname === item.path}
							data-sveltekit-preload-data="hover"
						>
							<span class="flex items-center space-x-4">
								<span class="text-lg">
									{#if item.icon === 'chart-pie'}📊
									{:else if item.icon === 'folder'}📁
									{:else if item.icon === 'cog-6-tooth'}⚙️
									{:else if item.icon === 'tv'}📺
									{:else if item.icon === 'shield-check'}🛡️
									{:else if item.icon === 'adjustments-horizontal'}🔧
									{:else}🔹
									{/if}
								</span>
								<span>{item.label}</span>
							</span>
						</a>
					</li>
				{/each}
			</ul>
		</nav>
	{/snippet}

	<!-- Page Content -->
	<div class="container mx-auto p-8 space-y-8">
		{@render children()}
	</div>
</AppShell>

<!-- Mobile Sidebar Overlay -->
{#if $sidebarOpen}
	<div 
		class="lg:hidden fixed inset-0 z-40 bg-surface-backdrop-token" 
		onclick={toggleSidebar}
		onkeydown={(e) => e.key === 'Escape' && toggleSidebar()}
		role="button"
		tabindex="0"
		aria-label="Fermer la sidebar"
	>
		<div class="fixed inset-y-0 left-0 z-50 w-64 bg-surface-50-900-token shadow-xl">
			<div class="flex items-center justify-between h-16 px-6 border-b border-surface-300-600-token">
				<h1 class="text-xl font-bold">Redriva</h1>
				<button class="btn btn-sm" onclick={toggleSidebar}>
					<span>✕</span>
				</button>
			</div>
			<nav class="list-nav p-4">
				<ul>
					{#each navItems as item}
						<li>
							<a
								href={item.path}
								class="option w-full"
								class:bg-primary-active-token={$page.url.pathname === item.path}
								onclick={toggleSidebar}
								data-sveltekit-preload-data="hover"
							>
								<span class="flex items-center space-x-4">
									<span class="text-lg">
										{#if item.icon === 'chart-pie'}📊
										{:else if item.icon === 'folder'}📁
										{:else if item.icon === 'cog-6-tooth'}⚙️
										{:else if item.icon === 'tv'}📺
										{:else if item.icon === 'shield-check'}🛡️
										{:else if item.icon === 'adjustments-horizontal'}🔧
										{:else}🔹
										{/if}
									</span>
									<span>{item.label}</span>
								</span>
							</a>
						</li>
					{/each}
				</ul>
			</nav>
		</div>
	</div>
{/if}
