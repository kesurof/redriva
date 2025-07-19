<script lang="ts">
	import { onMount } from 'svelte';
	import { torrents, filteredTorrents, searchQuery, statusFilter, categoryFilter, isLoading } from '$lib/stores';
	import { api } from '$lib/api';
	import type { Torrent } from '$lib/api';

	let showAddModal = false;
	let newTorrentName = '';
	let newTorrentMagnet = '';

	onMount(async () => {
		await loadTorrents();
	});

	async function loadTorrents() {
		isLoading.set(true);
		const response = await api.getTorrents();
		if (response.success && response.data) {
			torrents.set(response.data);
		}
		isLoading.set(false);
	}

	async function addTorrent() {
		if (!newTorrentName.trim()) return;

		const response = await api.addTorrent({
			name: newTorrentName,
			magnet_url: newTorrentMagnet || undefined
		});

		if (response.success) {
			await loadTorrents();
			showAddModal = false;
			newTorrentName = '';
			newTorrentMagnet = '';
		}
	}

	async function deleteTorrent(torrentId: string) {
		if (confirm('Êtes-vous sûr de vouloir supprimer ce torrent ?')) {
			const response = await api.deleteTorrent(torrentId);
			if (response.success) {
				await loadTorrents();
			}
		}
	}

	async function reinsertTorrent(torrentId: string) {
		const response = await api.reinsertTorrent(torrentId);
		if (response.success) {
			await loadTorrents();
		}
	}

	function getStatusColor(status: string): string {
		switch (status) {
			case 'downloading': return 'text-blue-600 bg-blue-100 dark:text-blue-400 dark:bg-blue-900';
			case 'completed': return 'text-green-600 bg-green-100 dark:text-green-400 dark:bg-green-900';
			case 'seeding': return 'text-purple-600 bg-purple-100 dark:text-purple-400 dark:bg-purple-900';
			case 'error': return 'text-red-600 bg-red-100 dark:text-red-400 dark:bg-red-900';
			case 'queued': return 'text-yellow-600 bg-yellow-100 dark:text-yellow-400 dark:bg-yellow-900';
			default: return 'text-gray-600 bg-gray-100 dark:text-gray-400 dark:bg-gray-900';
		}
	}

	function getStatusLabel(status: string): string {
		switch (status) {
			case 'downloading': return 'Téléchargement';
			case 'completed': return 'Terminé';
			case 'seeding': return 'Partage';
			case 'error': return 'Erreur';
			case 'queued': return 'En attente';
			default: return status;
		}
	}
</script>

<svelte:head>
	<title>Torrents - Redriva</title>
</svelte:head>

<div class="p-6">
	<!-- Header -->
	<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6">
		<div>
			<h1 class="text-3xl font-bold text-gray-900 dark:text-white">Torrents</h1>
			<p class="text-gray-600 dark:text-gray-400 mt-2">Gérez vos téléchargements de torrents</p>
		</div>
		<button
			onclick={() => showAddModal = true}
			class="mt-4 sm:mt-0 inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
		>
			<span class="mr-2">➕</span>
			Ajouter un Torrent
		</button>
	</div>

	<!-- Filtres et recherche -->
	<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
		<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
			<!-- Recherche -->
			<div>
				<label for="search" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
					Rechercher
				</label>
				<input
					id="search"
					type="text"
					bind:value={$searchQuery}
					placeholder="Nom du torrent..."
					class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
				/>
			</div>

			<!-- Filtre par statut -->
			<div>
				<label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
					Statut
				</label>
				<select
					id="status"
					bind:value={$statusFilter}
					class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
				>
					<option value="all">Tous les statuts</option>
					<option value="downloading">Téléchargement</option>
					<option value="completed">Terminé</option>
					<option value="seeding">Partage</option>
					<option value="queued">En attente</option>
					<option value="error">Erreur</option>
				</select>
			</div>

			<!-- Filtre par catégorie -->
			<div>
				<label for="category" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
					Catégorie
				</label>
				<select
					id="category"
					bind:value={$categoryFilter}
					class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
				>
					<option value="all">Toutes les catégories</option>
					<option value="OS">OS</option>
					<option value="Software">Software</option>
					<option value="Media">Media</option>
					<option value="Games">Games</option>
					<option value="Books">Books</option>
				</select>
			</div>
		</div>
	</div>

	<!-- Liste des torrents -->
	{#if $isLoading}
		<div class="flex items-center justify-center h-64">
			<div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
		</div>
	{:else if $filteredTorrents.length === 0}
		<div class="text-center py-12">
			<p class="text-gray-500 dark:text-gray-400 text-lg">Aucun torrent trouvé</p>
			<p class="text-gray-400 dark:text-gray-500 text-sm mt-2">
				{$searchQuery || $statusFilter !== 'all' || $categoryFilter !== 'all' 
					? 'Essayez de modifier vos filtres'
					: 'Ajoutez votre premier torrent pour commencer'
				}
			</p>
		</div>
	{:else}
		<div class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
			<div class="overflow-x-auto">
				<table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
					<thead class="bg-gray-50 dark:bg-gray-700">
						<tr>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Nom
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Taille
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Statut
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Progrès
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Vitesse
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
								Actions
							</th>
						</tr>
					</thead>
					<tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
						{#each $filteredTorrents as torrent}
							<tr class="hover:bg-gray-50 dark:hover:bg-gray-700">
								<td class="px-6 py-4 whitespace-nowrap">
									<div class="text-sm font-medium text-gray-900 dark:text-white truncate max-w-xs">
										{torrent.name}
									</div>
									<div class="text-sm text-gray-500 dark:text-gray-400">
										{torrent.category} • {torrent.added_date}
									</div>
								</td>
								<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
									{torrent.size}
								</td>
								<td class="px-6 py-4 whitespace-nowrap">
									<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {getStatusColor(torrent.status)}">
										{getStatusLabel(torrent.status)}
									</span>
								</td>
								<td class="px-6 py-4 whitespace-nowrap">
									<div class="flex items-center">
										<div class="flex-1">
											<div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
												<div 
													class="bg-blue-600 h-2 rounded-full" 
													style="width: {torrent.progress}%"
												></div>
											</div>
										</div>
										<div class="ml-2 text-sm text-gray-500 dark:text-gray-400">
											{torrent.progress}%
										</div>
									</div>
								</td>
								<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
									{torrent.speed}
								</td>
								<td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
									<div class="flex space-x-2">
										{#if torrent.status === 'error'}
											<button
												onclick={() => reinsertTorrent(torrent.id)}
												class="text-blue-600 dark:text-blue-400 hover:underline"
											>
												Réinsérer
											</button>
										{/if}
										<button
											onclick={() => deleteTorrent(torrent.id)}
											class="text-red-600 dark:text-red-400 hover:underline"
										>
											Supprimer
										</button>
									</div>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>

		<!-- Pagination info -->
		<div class="mt-4 text-center text-sm text-gray-500 dark:text-gray-400">
			Affichage de {$filteredTorrents.length} torrent{$filteredTorrents.length > 1 ? 's' : ''}
		</div>
	{/if}
</div>

<!-- Modal d'ajout de torrent -->
{#if showAddModal}
	<div class="fixed inset-0 z-50 overflow-y-auto" role="dialog" aria-modal="true">
		<div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
			<div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onclick={() => showAddModal = false}></div>
			
			<div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
				<div class="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
					<h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white mb-4">
						Ajouter un nouveau torrent
					</h3>
					
					<div class="space-y-4">
						<div>
							<label for="torrent-name" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
								Nom du torrent *
							</label>
							<input
								id="torrent-name"
								type="text"
								bind:value={newTorrentName}
								placeholder="Nom du fichier torrent"
								class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
							/>
						</div>
						
						<div>
							<label for="torrent-magnet" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
								Lien magnet (optionnel)
							</label>
							<textarea
								id="torrent-magnet"
								bind:value={newTorrentMagnet}
								placeholder="magnet:?xt=urn:btih:..."
								rows="3"
								class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
							></textarea>
						</div>
					</div>
				</div>
				
				<div class="bg-gray-50 dark:bg-gray-700 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
					<button
						onclick={addTorrent}
						disabled={!newTorrentName.trim()}
						class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed"
					>
						Ajouter
					</button>
					<button
						onclick={() => showAddModal = false}
						class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-700 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
					>
						Annuler
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}
