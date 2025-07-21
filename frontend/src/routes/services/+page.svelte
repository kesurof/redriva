<script lang="ts">
	import type { PageData } from './$types';
	import { ServiceCard, StatCard } from '$lib';
	import { onMount, onDestroy } from 'svelte';
	import { invalidate } from '$app/navigation';

	export let data: PageData;

	let intervalId: NodeJS.Timeout;

	// Cycle de vie pour l'actualisation automatique
	onMount(() => {
		intervalId = setInterval(() => {
			invalidate('app:services');
		}, 30000); // Actualiser toutes les 30 secondes
	});

	onDestroy(() => {
		if (intervalId) {
			clearInterval(intervalId);
		}
	});

	// Calculer les statistiques des services
	$: serviceStats = data.services ? {
		total: data.services.length,
		online: data.services.filter(s => s.status === 'online').length,
		offline: data.services.filter(s => s.status === 'offline').length,
		warning: data.services.filter(s => s.status === 'warning').length,
		maintenance: data.services.filter(s => s.status === 'maintenance').length
	} : { total: 0, online: 0, offline: 0, warning: 0, maintenance: 0 };

	$: healthPercentage = serviceStats.total > 0 
		? Math.round((serviceStats.online / serviceStats.total) * 100) 
		: 0;
</script>

<svelte:head>
	<title>Services - Redriva</title>
</svelte:head>

<div class="space-y-6">
	<!-- En-tête de la page -->
	<div class="flex items-center justify-between">
		<div>
			<h1 class="h1">Services</h1>
			<p class="text-surface-600 dark:text-surface-400">
				Surveillance et gestion de l'écosystème média
			</p>
		</div>
		<button 
			class="btn variant-filled-primary"
			on:click={() => invalidate('app:services')}
		>
			<svg class="w-4 h-4 fill-current" viewBox="0 0 24 24">
				<path d="M17.65,6.35C16.2,4.9 14.21,4 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20C15.73,20 18.84,17.45 19.73,14H17.65C16.83,16.33 14.61,18 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6C13.66,6 15.14,6.69 16.22,7.78L13,11H20V4L17.65,6.35Z"/>
			</svg>
			<span>Actualiser</span>
		</button>
	</div>

	{#if data.error}
		<!-- Alerte d'erreur -->
		<aside class="alert variant-filled-error">
			<div class="alert-message">
				<h3 class="h3">Erreur de chargement</h3>
				<p>{data.error}</p>
			</div>
		</aside>
	{:else}
		<!-- Statistiques globales -->
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
			<StatCard
				title="Santé Globale"
				value="{healthPercentage}%"
				icon="system"
				variant={healthPercentage > 80 ? 'success' : healthPercentage > 60 ? 'warning' : 'error'}
				progress={healthPercentage}
				size="sm"
			/>
			<StatCard
				title="Services Actifs"
				value="{serviceStats.online}"
				subtitle="/ {serviceStats.total}"
				icon="cpu"
				variant="success"
				size="sm"
			/>
			<StatCard
				title="Hors Ligne"
				value="{serviceStats.offline}"
				icon="queue"
				variant="error"
				size="sm"
			/>
			<StatCard
				title="Avertissements"
				value="{serviceStats.warning}"
				icon="info"
				variant="warning"
				size="sm"
			/>
			<StatCard
				title="Maintenance"
				value="{serviceStats.maintenance}"
				icon="settings"
				variant="secondary"
				size="sm"
			/>
		</div>

		<!-- Liste des services -->
		<div class="space-y-4">
			<div class="flex items-center justify-between">
				<h2 class="h2">État des Services</h2>
				{#if data.lastUpdate}
					<span class="text-sm text-surface-500">
						Dernière mise à jour: {new Date(data.lastUpdate).toLocaleTimeString('fr-FR')}
					</span>
				{/if}
			</div>

			{#if data.services && data.services.length > 0}
				<div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
					{#each data.services as service (service.name)}
						<ServiceCard
							name={service.name}
							description={service.description}
							status={service.status}
							url={service.url}
							version={service.version}
							lastCheck={service.lastCheck}
							responseTime={service.responseTime}
						/>
					{/each}
				</div>
			{:else}
				<div class="text-center py-12">
					<svg class="w-16 h-16 mx-auto text-surface-400 mb-4" fill="currentColor" viewBox="0 0 24 24">
						<path d="M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M12,6A6,6 0 0,1 18,12C18,13.75 17.39,15.36 16.4,16.65L7.35,7.6C8.64,6.61 10.25,6 12,6M6,12A6,6 0 0,1 12,6L6,12M6,12A6,6 0 0,0 12,18C13.75,18 15.36,17.39 16.65,16.4L7.6,7.35C6.61,8.64 6,10.25 6,12Z"/>
					</svg>
					<h3 class="h3 mb-2">Aucun service configuré</h3>
					<p class="text-surface-500">Commencez par configurer vos services dans les paramètres.</p>
				</div>
			{/if}
		</div>
	{/if}
</div>
