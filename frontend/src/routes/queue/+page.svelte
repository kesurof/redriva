<script lang="ts">
	// Page Queue - Skeleton UI v2 + SvelteKit + TypeScript
	import { onMount } from 'svelte';
	import { queue, isLoading } from '$lib/stores';
	import { api } from '$lib/api';
	import type { QueueItem } from '$lib/api';
	import QueueCard from '$lib/components/QueueCard.svelte';
	import StatCard from '$lib/components/StatCard.svelte';

	onMount(async () => {
		await loadQueue();
	});

	async function loadQueue() {
		isLoading.set(true);
		const response = await api.getQueue();
		if (response.success && response.data) {
			queue.set(response.data);
		}
		isLoading.set(false);
	}

	async function deleteFromQueue(queueId: number) {
		if (confirm('Êtes-vous sûr de vouloir supprimer cet élément de la queue ?')) {
			const response = await api.deleteFromQueue(queueId);
			if (response.success) {
				await loadQueue();
			}
		}
	}

	function getStatusVariant(status: string): string {
		switch (status) {
			case 'completed':
				return 'variant-filled-success';
			case 'processing':
				return 'variant-filled-warning';
			case 'failed':
				return 'variant-filled-error';
			case 'pending':
				return 'variant-filled-secondary';
			default:
				return 'variant-filled-surface';
		}
	}

	function getStatusLabel(status: string): string {
		switch (status) {
			case 'completed':
				return 'Terminé';
			case 'processing':
				return 'En cours';
			case 'failed':
				return 'Échec';
			case 'pending':
				return 'En attente';
			default:
				return status;
		}
	}

	// Utilitaires pour les statistiques
	function getPendingCount(): number {
		return $queue.filter(item => item.status === 'pending').length;
	}

	function getProcessingCount(): number {
		return $queue.filter(item => item.status === 'processing').length;
	}

	function getCompletedCount(): number {
		return $queue.filter(item => item.status === 'completed').length;
	}

	function getFailedCount(): number {
		return $queue.filter(item => item.status === 'failed').length;
	}

	function formatDateTime(dateTimeStr: string): string {
		try {
			const date = new Date(dateTimeStr);
			return date.toLocaleString('fr-FR');
		} catch {
			return dateTimeStr;
		}
	}
</script>

<!-- Page Queue Skeleton UI v2 -->
<svelte:head>
	<title>Queue - Redriva</title>
</svelte:head>

<div class="space-y-6">
	<!-- Header -->
	<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
		<div class="space-y-2">
			<h1 class="h1">Queue des Tâches</h1>
			<p class="text-surface-500">Suivez l'état des tâches en cours de traitement</p>
		</div>
		<button
			on:click={loadQueue}
			class="btn variant-filled-primary mt-4 sm:mt-0"
		>
			<svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
				<path d="M17.65,6.35C16.2,4.9 14.21,4 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20C15.73,20 18.84,17.45 19.73,14H17.65C16.83,16.33 14.61,18 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6C13.66,6 15.14,6.69 16.22,7.78L13,11H20V4L17.65,6.35Z"/>
			</svg>
			<span>Actualiser</span>
		</button>
	</div>

	<!-- Grille de statistiques -->
	<div class="grid grid-cols-1 md:grid-cols-4 gap-6">
		<div class="card">
			<section class="p-6">
				<div class="flex items-center">
					<StatCard
						title="Total"
						value="{$queue.length}"
						subtitle="tâches"
						icon="queue"
						variant="primary"
						size="sm"
					/>
				</div>
			</section>
		</div>

		<div class="card">
			<section class="p-6">
				<div class="flex items-center">
					<div class="p-3 rounded-full bg-warning-500/10">
						<svg class="w-6 h-6 text-warning-500" fill="currentColor" viewBox="0 0 24 24">
							<path d="M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M11,7H13V13H11V7M11,15H13V17H11V15Z"/>
						</svg>
					</div>
					<div class="ml-4">
						<p class="text-sm font-medium text-surface-500">En attente</p>
						<p class="text-2xl font-bold">{$queue.filter(item => item.status === 'pending').length}</p>
					</div>
				</div>
			</section>
		</div>

		<div class="card">
			<section class="p-6">
				<div class="flex items-center">
					<div class="p-3 rounded-full bg-primary-500/10">
						<svg class="w-6 h-6 text-primary-500" fill="currentColor" viewBox="0 0 24 24">
							<path d="M12,4V2A10,10 0 0,0 2,12H4A8,8 0 0,1 12,4Z"/>
						</svg>
					</div>
					<div class="ml-4">
						<p class="text-sm font-medium text-surface-500">En cours</p>
						<p class="text-2xl font-bold">{$queue.filter(item => item.status === 'processing').length}</p>
					</div>
				</div>
			</section>
		</div>

		<div class="card">
			<section class="p-6">
				<div class="flex items-center">
					<div class="p-3 rounded-full bg-success-500/10">
						<svg class="w-6 h-6 text-success-500" fill="currentColor" viewBox="0 0 24 24">
							<path d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/>
						</svg>
					</div>
					<div class="ml-4">
						<p class="text-sm font-medium text-surface-500">Terminées</p>
						<p class="text-2xl font-bold">{$queue.filter(item => item.status === 'completed').length}</p>
					</div>
				</div>
		</div>
	</div>

	<!-- Liste de la queue -->
	{#if $isLoading}
		<div class="card">
			<section class="p-12">
				<div class="flex items-center justify-center">
					<div class="animate-spin w-8 h-8">
						<svg fill="currentColor" viewBox="0 0 24 24">
							<path d="M12,4V2A10,10 0 0,0 2,12H4A8,8 0 0,1 12,4Z"/>
						</svg>
					</div>
					<span class="ml-3 text-surface-500">Chargement des tâches...</span>
				</div>
			</section>
		</div>
	{:else if $queue.length === 0}
		<div class="card">
			<section class="p-12 text-center">
				<svg class="w-16 h-16 mx-auto text-surface-400 mb-4" fill="currentColor" viewBox="0 0 24 24">
					<path d="M19,3H5C3.9,3 3,3.9 3,5V19C3,20.1 3.9,21 5,21H19C20.1,21 21,20.1 21,19V5C21,3.9 20.1,3 19,3M19,19H5V5H19V19Z"/>
				</svg>
				<h3 class="h3 mb-2">Aucune tâche dans la queue</h3>
				<p class="text-surface-500">
					Les tâches apparaîtront ici lorsqu'elles seront ajoutées
				</p>
			</section>
		</div>
	{:else}
		<div class="card">
			<section class="p-0">
				<div class="table-container">
					<table class="table table-hover">
						<thead>
							<tr>
								<th>ID</th>
								<th>Statut</th>
								<th>Créé le</th>
								<th>Mis à jour le</th>
								<th>Données</th>
								<th class="table-cell-fit">Actions</th>
							</tr>
						</thead>
						<tbody>
							{#each $queue as item}
							<tr>
								<td>#{item.id}</td>
								<td>
									<span class="badge {getStatusVariant(item.status)}">
										{getStatusLabel(item.status)}
									</span>
								</td>
								<td class="text-sm">{formatDateTime(item.created_at)}</td>
								<td class="text-sm">{formatDateTime(item.updated_at)}</td>
								<td>
									{#if item.data && Object.keys(item.data).length > 0}
										<details class="cursor-pointer">
											<summary class="text-sm text-primary-500 hover:text-primary-700 font-medium">
												Voir les données
											</summary>
											<div class="card variant-soft mt-2 p-3 max-w-xs">
												<pre class="text-xs overflow-auto max-h-32 whitespace-pre-wrap">
{JSON.stringify(item.data, null, 2)}
												</pre>
											</div>
										</details>
									{:else}
										<span class="text-sm text-surface-500 italic">Aucune donnée</span>
									{/if}
								</td>
								<td>
									<button
										on:click={() => deleteFromQueue(item.id)}
										class="btn btn-sm variant-filled-error"
									>
										<svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
											<path d="M19,4H15.5L14.5,3H9.5L8.5,4H5V6H19M6,19A2,2 0 0,0 8,21H16A2,2 0 0,0 18,19V7H6V19Z"/>
										</svg>
										<span>Supprimer</span>
									</button>
								</td>
							</tr>
						{/each}
						</tbody>
					</table>
				</div>
			</section>
		</div>

		<!-- Info de pagination -->
		<div class="text-center mt-6">
			<p class="text-sm text-surface-500">
				{$queue.length} tâche{$queue.length > 1 ? 's' : ''} dans la queue
			</p>
		</div>
	{/if}
</div>
