<script lang="ts">
	import type { PageData } from './$types';
	import { Progress } from '@skeletonlabs/skeleton-svelte';
	import { onMount, onDestroy } from 'svelte';
	import { invalidate } from '$app/navigation';

	export let data: PageData;

	let intervalId: NodeJS.Timeout;

	// Fonction utilitaire pour convertir les octets en Go
	function bytesToGB(bytes: number): string {
		return (bytes / (1024 ** 3)).toFixed(2);
	}

	// Fonction utilitaire pour calculer le pourcentage
	function calculatePercentage(used: number, total: number): number {
		return Math.round((used / total) * 100);
	}

	// Démarrer le polling au montage du composant
	onMount(() => {
		// Rafraîchir les données toutes les 5 secondes
		intervalId = setInterval(() => {
			invalidate('app:system');
		}, 5000);
	});

	// Nettoyer l'intervalle au démontage du composant
	onDestroy(() => {
		if (intervalId) {
			clearInterval(intervalId);
		}
	});
</script>

<div class="p-8 space-y-6">
	<h1 class="h1">Dashboard</h1>

	{#if data.error}
		<!-- Cas d'erreur -->
		<div class="alert preset-filled-error">
			<div class="alert-message">
				<h3>Erreur de chargement</h3>
				<p>{data.error}</p>
			</div>
		</div>
	{:else if data.systemInfo}
		<!-- Cas de succès - Affichage du dashboard -->
		<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
			<!-- Widget CPU -->
			<div class="card">
				<header class="card-header">
					<h3 class="h3">CPU</h3>
				</header>
				<section class="p-4 space-y-4">
					<div class="text-2xl font-bold text-primary-500">
						{data.systemInfo.cpu_percent}%
					</div>
					<Progress 
						value={data.systemInfo.cpu_percent} 
						max={100}
					/>
				</section>
			</div>

			<!-- Widget RAM -->
			<div class="card">
				<header class="card-header">
					<h3 class="h3">RAM</h3>
				</header>
				<section class="p-4 space-y-4">
					<div class="space-y-1">
						<div class="text-2xl font-bold text-secondary-500">
							{calculatePercentage(data.systemInfo.memory.used, data.systemInfo.memory.total)}%
						</div>
						<div class="text-sm text-surface-500">
							{bytesToGB(data.systemInfo.memory.used)} Go / {bytesToGB(data.systemInfo.memory.total)} Go
						</div>
					</div>
					<Progress 
						value={calculatePercentage(data.systemInfo.memory.used, data.systemInfo.memory.total)} 
						max={100}
					/>
				</section>
			</div>

			<!-- Widget Disque -->
			<div class="card">
				<header class="card-header">
					<h3 class="h3">Disque</h3>
				</header>
				<section class="p-4 space-y-4">
					<div class="space-y-1">
						<div class="text-2xl font-bold text-tertiary-500">
							{calculatePercentage(data.systemInfo.disk.used, data.systemInfo.disk.total)}%
						</div>
						<div class="text-sm text-surface-500">
							{bytesToGB(data.systemInfo.disk.used)} Go / {bytesToGB(data.systemInfo.disk.total)} Go
						</div>
					</div>
					<Progress 
						value={calculatePercentage(data.systemInfo.disk.used, data.systemInfo.disk.total)} 
						max={100}
					/>
				</section>
			</div>
		</div>
	{:else}
		<!-- Cas de chargement/vide -->
		<div class="flex items-center justify-center p-12">
			<div class="text-center space-y-4">
				<div class="text-lg">Chargement des données système...</div>
				<Progress value={undefined} />
			</div>
		</div>
	{/if}
</div>