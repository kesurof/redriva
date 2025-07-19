<script lang="ts">
	import { onMount } from 'svelte';
	import { queue, isLoading } from '$lib/stores';
	import { api } from '$lib/api';
	import type { QueueItem } from '$lib/api';

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

	function getStatusColor(status: string): string {
		switch (status) {
			case 'pending': return 'text-yellow-600 bg-yellow-100 dark:text-yellow-400 dark:bg-yellow-900';
			case 'processing': return 'text-blue-600 bg-blue-100 dark:text-blue-400 dark:bg-blue-900';
			case 'completed': return 'text-green-600 bg-green-100 dark:text-green-400 dark:bg-green-900';
			case 'failed': return 'text-red-600 bg-red-100 dark:text-red-400 dark:bg-red-900';
			default: return 'text-gray-600 bg-gray-100 dark:text-gray-400 dark:bg-gray-900';
		}
	}

	function getStatusLabel(status: string): string {
		switch (status) {
			case 'pending': return 'En attente';
			case 'processing': return 'En cours';
			case 'completed': return 'Terminé';
			case 'failed': return 'Échec';
			default: return status;
		}
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

<svelte:head>
	<title>Queue - Redriva</title>
</svelte:head>

<div class="p-6">
	<!-- Header -->
	<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6">
		<div>
			<h1 class="text-3xl font-bold text-gray-900 dark:text-white">Queue des Tâches</h1>
			<p class="text-gray-600 dark:text-gray-400 mt-2">Suivez l'état des tâches en cours de traitement</p>
		</div>
		<button
			onclick={loadQueue}
			class="mt-4 sm:mt-0 inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
		>
			<span class="mr-2">🔄</span>
			Actualiser
		</button>
	</div>

	<!-- Statistiques de la queue -->
	<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
		<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
			<div class="flex items-center">
				<div class="p-3 rounded-full bg-gray-100 dark:bg-gray-700">
					<span class="text-2xl">📋</span>
				</div>
				<div class="ml-4">
					<p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total</p>
					<p class="text-2xl font-bold text-gray-900 dark:text-white">{$queue.length}</p>
				</div>
			</div>
		</div>

		<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
			<div class="flex items-center">
				<div class="p-3 rounded-full bg-yellow-100 dark:bg-yellow-900">
					<span class="text-2xl">⏳</span>
				</div>
				<div class="ml-4">
					<p class="text-sm font-medium text-gray-500 dark:text-gray-400">En attente</p>
					<p class="text-2xl font-bold text-gray-900 dark:text-white">
						{$queue.filter(item => item.status === 'pending').length}
					</p>
				</div>
			</div>
		</div>

		<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
			<div class="flex items-center">
				<div class="p-3 rounded-full bg-blue-100 dark:bg-blue-900">
					<span class="text-2xl">⚡</span>
				</div>
				<div class="ml-4">
					<p class="text-sm font-medium text-gray-500 dark:text-gray-400">En cours</p>
					<p class="text-2xl font-bold text-gray-900 dark:text-white">
						{$queue.filter(item => item.status === 'processing').length}
					</p>
				</div>
			</div>
		</div>

		<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
			<div class="flex items-center">
				<div class="p-3 rounded-full bg-green-100 dark:bg-green-900">
					<span class="text-2xl">✅</span>
				</div>
				<div class="ml-4">
					<p class="text-sm font-medium text-gray-500 dark:text-gray-400">Terminées</p>
					<p class="text-2xl font-bold text-gray-900 dark:text-white">
						{$queue.filter(item => item.status === 'completed').length}
					</p>
				</div>
			</div>
		</div>
	</div>

	<!-- Liste de la queue -->
	{#if $isLoading}
		<div class="flex items-center justify-center h-64">
			<div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
		</div>
	{:else if $queue.length === 0}
		<div class="text-center py-12">
			<p class="text-gray-500 dark:text-gray-400 text-lg">Aucune tâche dans la queue</p>
			<p class="text-gray-400 dark:text-gray-500 text-sm mt-2">
				Les tâches apparaîtront ici lorsqu'elles seront ajoutées
			</p>
		</div>
	{:else}
		<div class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
			<div class="overflow-x-auto">
				<table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
					<thead class="bg-gray-50 dark:bg-gray-700">
						<tr>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								ID
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Statut
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Créé le
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Mis à jour le
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Données
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Actions
							</th>
						</tr>
					</thead>
					<tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
						{#each $queue as item}
							<tr class="hover:bg-gray-50 dark:hover:bg-gray-700">
								<td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
									#{item.id}
								</td>
								<td class="px-6 py-4 whitespace-nowrap">
									<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {getStatusColor(item.status)}">
										{getStatusLabel(item.status)}
									</span>
								</td>
								<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
									{formatDateTime(item.created_at)}
								</td>
								<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
									{formatDateTime(item.updated_at)}
								</td>
								<td class="px-6 py-4">
									<div class="max-w-xs">
										{#if item.data && Object.keys(item.data).length > 0}
											<details class="cursor-pointer">
												<summary class="text-sm text-blue-600 dark:text-blue-400 hover:underline">
													Voir les données
												</summary>
												<pre class="mt-2 text-xs bg-gray-100 dark:bg-gray-700 p-2 rounded overflow-auto max-h-32">
{JSON.stringify(item.data, null, 2)}
												</pre>
											</details>
										{:else}
											<span class="text-sm text-gray-500 dark:text-gray-400 italic">Aucune donnée</span>
										{/if}
									</div>
								</td>
								<td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
									<button
										onclick={() => deleteFromQueue(item.id)}
										class="text-red-600 dark:text-red-400 hover:underline"
									>
										Supprimer
									</button>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>

		<!-- Info de pagination -->
		<div class="mt-4 text-center text-sm text-gray-500 dark:text-gray-400">
			{$queue.length} tâche{$queue.length > 1 ? 's' : ''} dans la queue
		</div>
	{/if}
</div>
