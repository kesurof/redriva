<script lang="ts">
	// Layout principal basé sur Skeleton UI v2 + SvelteKit + TypeScript
	import '../app.css';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	
	// Imports Skeleton UI v2 - composants officiels uniquement
	import { AppShell, AppBar, LightSwitch } from '@skeletonlabs/skeleton';

	// Stores TypeScript
	import { sidebarOpen, theme } from '$lib/stores';

	// Navigation avec icônes SVG simplifiées
	const navItems = [
		{ 
			path: '/', 
			label: 'Dashboard', 
			icon: 'M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z' 
		},
		{ 
			path: '/torrents', 
			label: 'Torrents', 
			icon: 'M14,2H6A2,2 0 0,0 4,4V20A2,2 0 0,0 6,22H18A2,2 0 0,0 20,20V8L14,2M18,20H6V4H13V9H18V20Z' 
		},
		{ 
			path: '/services', 
			label: 'Services', 
			icon: 'M21,16V4H3V16H21M21,2A2,2 0 0,1 23,4V16A2,2 0 0,1 21,18H14V20H16V22H8V20H10V18H3C1.89,18 1,17.1 1,16V4C1,2.89 1.89,2 3,2H21Z' 
		},
		{ 
			path: '/settings', 
			label: 'Paramètres', 
			icon: 'M12,15.5A3.5,3.5 0 0,1 8.5,12A3.5,3.5 0 0,1 12,8.5A3.5,3.5 0 0,1 15.5,12A3.5,3.5 0 0,1 12,15.5M19.43,12.97C19.47,12.65 19.5,12.33 19.5,12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.65 15.48,5.32 14.87,5.07L14.49,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.51,2.42L9.13,5.07C8.52,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,5.27L2.34,8.73C2.21,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.21,15.05 2.34,15.27L4.34,18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.52,18.68 9.13,18.93L9.51,21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.49,21.58L14.87,18.93C15.48,18.68 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z' 
		}
	];

	onMount(() => {
		const savedTheme = localStorage.getItem('theme');
		if (savedTheme === 'dark' || (!savedTheme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
			theme.set('dark');
		}
	});

	// Reactive statement Svelte v4
	$: if (typeof document !== 'undefined') {
		if ($theme === 'dark') {
			document.documentElement.classList.add('dark');
			localStorage.setItem('theme', 'dark');
		} else {
			document.documentElement.classList.remove('dark');
			localStorage.setItem('theme', 'light');
		}
	}
</script>

<!-- Layout basé sur AppShell Skeleton UI v2 -->
<AppShell slotSidebarLeft="w-64 bg-surface-50-900-token">
	<svelte:fragment slot="header">
		<AppBar>
			<svelte:fragment slot="lead">
				<button 
					class="lg:hidden btn btn-sm mr-4" 
					on:click={() => ($sidebarOpen = !$sidebarOpen)}
				>
					<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
						<path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/>
					</svg>
				</button>
				<strong class="text-xl uppercase tracking-wide">Redriva</strong>
			</svelte:fragment>
			<svelte:fragment slot="trail">
				<div class="flex items-center space-x-4">
					<LightSwitch />
					<div class="hidden sm:flex items-center space-x-2">
						<div class="w-2 h-2 bg-success-500 rounded-full animate-pulse"></div>
						<span class="text-sm">Connecté</span>
					</div>
				</div>
			</svelte:fragment>
		</AppBar>
	</svelte:fragment>

	<svelte:fragment slot="sidebarLeft">
		<nav class="list-nav p-4">
			<ul>
				{#each navItems as item}
					<li>
						<a
							href={item.path}
							class="flex items-center space-x-3 p-3 rounded-token hover:variant-soft-primary"
							class:variant-filled-primary={$page.url.pathname === item.path}
							data-sveltekit-preload-data="hover"
							on:click={() => { if (window.innerWidth < 1024) $sidebarOpen = false; }}
						>
							<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
								<path d={item.icon}/>
							</svg>
							<span>{item.label}</span>
						</a>
					</li>
				{/each}
			</ul>
		</nav>
	</svelte:fragment>

	<!-- Contenu principal -->
	<div class="container mx-auto p-4 md:p-8">
		<slot />
	</div>
</AppShell>
