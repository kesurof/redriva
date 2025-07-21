<script lang="ts">
	// Dashboard principal - Skeleton UI v2 + SvelteKit + TypeScript
	import type { PageData } from './$types';
	import { ProgressBar } from '@skeletonlabs/skeleton';
	import { onMount, onDestroy } from 'svelte';
	import { invalidate } from '$app/navigation';
	import { StatCard, QuickAction, ActivityFeed, LoadingSpinner } from '$lib';

	export let data: PageData;

	let intervalId: NodeJS.Timeout;
	let isMounted = false;

	// Utilitaires TypeScript
	function bytesToGB(bytes: number): string {
		return (bytes / (1024 ** 3)).toFixed(2);
	}

	function calculatePercentage(used: number, total: number): number {
		return Math.round((used / total) * 100);
	}

	// Cycle de vie Svelte v4
	onMount(() => {
		isMounted = true;
		intervalId = setInterval(() => {
			invalidate('app:system');
		}, 5000);
	});

	onDestroy(() => {
		if (intervalId) {
			clearInterval(intervalId);
		}
	});

	// Données d'exemple pour l'activité récente
	const recentActivities = [
		{
			id: '1',
			type: 'download' as const,
			title: 'Film.mkv',
			description: 'Téléchargement terminé avec succès',
			timestamp: new Date(Date.now() - 300000).toISOString(), // Il y a 5 minutes
			status: 'Terminé'
		},
		{
			id: '2',
			type: 'queue' as const,
			title: 'Série S01E01.mkv',
			description: 'Ajouté à la file d\'attente',
			timestamp: new Date(Date.now() - 600000).toISOString(), // Il y a 10 minutes
			status: 'En attente'
		},
		{
			id: '3',
			type: 'success' as const,
			title: 'Serveur Plex',
			description: 'Connexion rétablie',
			timestamp: new Date(Date.now() - 900000).toISOString(), // Il y a 15 minutes
			status: 'Connecté'
		},
		{
			id: '4',
			type: 'info' as const,
			title: 'Nettoyage automatique',
			description: 'Suppression de 12 fichiers temporaires',
			timestamp: new Date(Date.now() - 1800000).toISOString(), // Il y a 30 minutes
		}
	];
</script>

<!-- Dashboard Skeleton UI v2 -->
<div class="space-y-6">
	<h1 class="h1">Dashboard</h1>

	{#if data.error}
		<!-- Alerte d'erreur Skeleton v2 -->
		<aside class="alert variant-filled-error">
			<div class="alert-message">
				<h3 class="h3">Erreur de chargement</h3>
				<p>{data.error}</p>
			</div>
		</aside>
	{:else if data.systemInfo}
		<!-- Grille de widgets système avec StatCard -->
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
			<!-- Widget CPU -->
			<StatCard
				title="CPU"
				value="{data.systemInfo.cpu_percent.toFixed(1)}%"
				icon="cpu"
				variant="primary"
				progress={data.systemInfo.cpu_percent}
				trend={data.systemInfo.cpu_percent > 80 ? 'up' : data.systemInfo.cpu_percent < 30 ? 'down' : 'neutral'}
			/>

			<!-- Widget RAM -->
			<StatCard
				title="RAM"
				value="{calculatePercentage(data.systemInfo?.memory?.used || 0, data.systemInfo?.memory?.total || 1)}%"
				subtitle="{bytesToGB(data.systemInfo?.memory?.used || 0)} Go / {bytesToGB(data.systemInfo?.memory?.total || 0)} Go"
				icon="memory"
				variant="secondary"
				progress={calculatePercentage(data.systemInfo?.memory?.used || 0, data.systemInfo?.memory?.total || 1)}
				trend={calculatePercentage(data.systemInfo?.memory?.used || 0, data.systemInfo?.memory?.total || 1) > 85 ? 'up' : 'neutral'}
			/>

			<!-- Widget Disque -->
			<StatCard
				title="Disque"
				value="{calculatePercentage(data.systemInfo?.disk?.used || 0, data.systemInfo?.disk?.total || 1)}%"
				subtitle="{bytesToGB(data.systemInfo?.disk?.used || 0)} Go / {bytesToGB(data.systemInfo?.disk?.total || 0)} Go"
				icon="storage"
				variant="tertiary"
				progress={calculatePercentage(data.systemInfo?.disk?.used || 0, data.systemInfo?.disk?.total || 1)}
				trend={calculatePercentage(data.systemInfo?.disk?.used || 0, data.systemInfo?.disk?.total || 1) > 90 ? 'up' : 'neutral'}
			/>

			<!-- Widget Système -->
			<StatCard
				title="Système"
				value="En ligne"
				subtitle="Uptime: {data.systemInfo.uptime}"
				icon="system"
				variant="success"
				trend="neutral"
			/>
		</div>

		<!-- Section Actions Rapides -->
		<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
			<div class="space-y-4">
				<h2 class="h2">Actions Rapides</h2>
				<div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
					<QuickAction
						title="Ajouter Torrent"
						description="Ajouter un nouveau torrent à télécharger"
						icon="add"
						href="/torrents"
						variant="variant-soft-primary"
					/>
					<QuickAction
						title="Gérer la File"
						description="Consulter et gérer la file d'attente"
						icon="queue"
						href="/queue"
						variant="variant-soft-secondary"
						badge="5"
						badgeVariant="variant-filled-warning"
					/>
					<QuickAction
						title="Paramètres"
						description="Configuration du système"
						icon="settings"
						href="/settings"
						variant="variant-soft-tertiary"
					/>
					<QuickAction
						title="Monitoring"
						description="Surveillance des services"
						icon="monitor"
						href="/services"
						variant="variant-soft-success"
					/>
				</div>
				<div class="mt-4">
					<QuickAction
						title="Aperçu des Composants"
						description="Démonstration de tous les composants UI"
						icon="info"
						href="/demo"
						variant="variant-soft-warning"
						badge="Démo"
						badgeVariant="variant-filled-tertiary"
					/>
				</div>
			</div>
			
			<div>
				<ActivityFeed activities={recentActivities} />
			</div>
		</div>

		<!-- Section supplémentaire : Informations système détaillées -->
		<div class="card">
			<header class="card-header">
				<h2 class="h2">Informations Système</h2>
			</header>
			<section class="p-4">
				<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
					<div class="text-center">
						<h3 class="h4 mb-2">Uptime</h3>
						<p class="text-2xl font-bold text-primary-500">{data.systemInfo.uptime}</p>
						<p class="text-sm text-surface-500">Temps de fonctionnement</p>
					</div>
					
					{#if data.systemInfo.load_average}
						<div class="text-center">
							<h3 class="h4 mb-2">Load Average</h3>
							<p class="text-2xl font-bold text-secondary-500">{data.systemInfo.load_average[0].toFixed(2)}</p>
							<p class="text-sm text-surface-500">1min: {data.systemInfo.load_average[0].toFixed(2)} | 5min: {data.systemInfo.load_average[1].toFixed(2)} | 15min: {data.systemInfo.load_average[2].toFixed(2)}</p>
						</div>
					{/if}
					
					<div class="text-center">
						<h3 class="h4 mb-2">Démarrage</h3>
						<p class="text-lg font-bold text-tertiary-500">{new Date(data.systemInfo.boot_time).toLocaleDateString('fr-FR')}</p>
						<p class="text-sm text-surface-500">{new Date(data.systemInfo.boot_time).toLocaleTimeString('fr-FR')}</p>
					</div>
					
					{#if data.systemInfo.network}
						<div class="text-center">
							<h3 class="h4 mb-2">Réseau</h3>
							<p class="text-lg font-bold text-success-500">↑ {bytesToGB(data.systemInfo.network.bytes_sent)} Go</p>
							<p class="text-sm text-surface-500">↓ {bytesToGB(data.systemInfo.network.bytes_recv)} Go</p>
						</div>
					{/if}
				</div>
			</section>
		</div>

		<!-- Section supplémentaire : Statistiques détaillées -->
		<div class="card">
			<header class="card-header">
				<h2 class="h2">Activité récente</h2>
			</header>
			<section class="p-4">
				<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
					<StatCard
						title="Torrents actifs"
						value="12"
						icon="download"
						variant="primary"
						size="sm"
						trend="up"
					/>
					<StatCard
						title="Files d'attente"
						value="5"
						icon="queue"
						variant="warning"
						size="sm"
						trend="stable"
					/>
					<StatCard
						title="Téléchargements"
						value="256 Go"
						subtitle="ce mois"
						icon="data"
						variant="success"
						size="sm"
						trend="up"
					/>
				</div>
			</section>
		</div>
	{:else}
		<!-- État de chargement avec LoadingSpinner -->
		<div class="flex items-center justify-center p-12">
			<LoadingSpinner size="lg" message="Chargement des données système..." />
		</div>
	{/if}
</div>