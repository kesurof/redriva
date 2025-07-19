<script lang="ts">
	import { onMount } from 'svelte';
	import { torrents, systemInfo, activeDownloads, completedTorrents, totalSize } from '$lib/stores';
	
	// Récupération des données depuis le serveur
	export let data;

	let loading = false;
	let stats = {
		totalTorrents: 0,
		activeDownloads: 0,
		completedTorrents: 0,
		totalSize: '0 GB'
	};

	onMount(() => {
		// Initialiser les stores avec les données du serveur
		if (data.torrents) {
			torrents.set(data.torrents);
		}
		if (data.systemInfo) {
			systemInfo.set(data.systemInfo);
		}
	});

	// Calculer les stats en temps réel
	$: if (data.torrents) {
		const activeTorrents = data.torrents.filter(t => 
			t.status === 'downloading' || t.status === 'seeding'
		);
		const completedTorrentsList = data.torrents.filter(t => 
			t.status === 'completed' || t.status === 'seeding'
		);
		
		// Calculer la taille totale
		let totalBytes = 0;
		data.torrents.forEach(torrent => {
			const sizeStr = torrent.size;
			const sizeMatch = sizeStr.match(/^(\d+\.?\d*)\s*(GB|MB|TB|KB|B)/i);
			if (sizeMatch) {
				const value = parseFloat(sizeMatch[1]);
				const unit = sizeMatch[2].toUpperCase();
				switch (unit) {
					case 'TB': totalBytes += value * 1024 * 1024 * 1024 * 1024; break;
					case 'GB': totalBytes += value * 1024 * 1024 * 1024; break;
					case 'MB': totalBytes += value * 1024 * 1024; break;
					case 'KB': totalBytes += value * 1024; break;
					default: totalBytes += value; break;
				}
			}
		});
		
		const totalSizeFormatted = totalBytes > 1024 * 1024 * 1024 
			? `${(totalBytes / (1024 * 1024 * 1024)).toFixed(1)} GB`
			: `${(totalBytes / (1024 * 1024)).toFixed(1)} MB`;
		
		stats = {
			totalTorrents: data.torrents.length,
			activeDownloads: activeTorrents.length,
			completedTorrents: completedTorrentsList.length,
			totalSize: totalSizeFormatted
		};
	}
</script>

<svelte:head>
	<title>Dashboard - Redriva</title>
</svelte:head>

<div class="p-6">
	<div class="mb-8">
		<h1 class="text-3xl font-bold text-gray-900 dark:text-white">Dashboard</h1>
		<p class="text-gray-600 dark:text-gray-400 mt-2">Vue d'ensemble de votre activité de téléchargement</p>
	</div>

	{#if loading}
		<div class="flex items-center justify-center h-64">
			<div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
		</div>
	{:else}
		<!-- Cartes de statistiques -->
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
			<!-- Total Torrents -->
			<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
				<div class="flex items-center">
					<div class="p-3 rounded-full bg-blue-100 dark:bg-blue-900">
						<span class="text-2xl">📁</span>
					</div>
					<div class="ml-4">
						<p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Torrents</p>
						<p class="text-2xl font-bold text-gray-900 dark:text-white">{stats.totalTorrents}</p>
					</div>
				</div>
			</div>

			<!-- Téléchargements actifs -->
			<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
				<div class="flex items-center">
					<div class="p-3 rounded-full bg-green-100 dark:bg-green-900">
						<span class="text-2xl">⬇️</span>
					</div>
					<div class="ml-4">
						<p class="text-sm font-medium text-gray-500 dark:text-gray-400">Actifs</p>
						<p class="text-2xl font-bold text-gray-900 dark:text-white">{stats.activeDownloads}</p>
					</div>
				</div>
			</div>

			<!-- Téléchargements terminés -->
			<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
				<div class="flex items-center">
					<div class="p-3 rounded-full bg-purple-100 dark:bg-purple-900">
						<span class="text-2xl">✅</span>
					</div>
					<div class="ml-4">
						<p class="text-sm font-medium text-gray-500 dark:text-gray-400">Terminés</p>
						<p class="text-2xl font-bold text-gray-900 dark:text-white">{stats.completedTorrents}</p>
					</div>
				</div>
			</div>

			<!-- Taille totale -->
			<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
				<div class="flex items-center">
					<div class="p-3 rounded-full bg-orange-100 dark:bg-orange-900">
						<span class="text-2xl">💾</span>
					</div>
					<div class="ml-4">
						<p class="text-sm font-medium text-gray-500 dark:text-gray-400">Taille totale</p>
						<p class="text-2xl font-bold text-gray-900 dark:text-white">{stats.totalSize}</p>
					</div>
				</div>
			</div>
		</div>

		<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
			<!-- Informations système -->
			{#if data.systemInfo}
				<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
					<h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Informations Système</h2>
					<div class="space-y-4">
						<div>
							<div class="flex justify-between text-sm text-gray-600 dark:text-gray-400 mb-1">
								<span>CPU</span>
								<span>{data.systemInfo.cpu_usage.toFixed(1)}%</span>
							</div>
							<div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
								<div class="bg-blue-600 h-2 rounded-full" style="width: {data.systemInfo.cpu_usage}%"></div>
							</div>
						</div>
						<div>
							<div class="flex justify-between text-sm text-gray-600 dark:text-gray-400 mb-1">
								<span>Mémoire</span>
								<span>{data.systemInfo.memory_usage.toFixed(1)}%</span>
							</div>
							<div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
								<div class="bg-green-600 h-2 rounded-full" style="width: {data.systemInfo.memory_usage}%"></div>
							</div>
						</div>
						<div>
							<div class="flex justify-between text-sm text-gray-600 dark:text-gray-400 mb-1">
								<span>Disque</span>
								<span>{data.systemInfo.disk_usage.toFixed(1)}%</span>
							</div>
							<div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
								<div class="bg-orange-600 h-2 rounded-full" style="width: {data.systemInfo.disk_usage}%"></div>
							</div>
						</div>
						<div class="pt-2 border-t border-gray-200 dark:border-gray-700">
							<p class="text-sm text-gray-600 dark:text-gray-400">
								Uptime: <span class="font-medium">{data.systemInfo.uptime}</span>
							</p>
						</div>
					</div>
				</div>
			{/if}

			<!-- Activité récente -->
			<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
				<h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Téléchargements Récents</h2>
				<div class="space-y-3">
					{#if data.torrents && data.torrents.filter(t => t.status === 'downloading' || t.status === 'seeding').length > 0}
						{#each data.torrents.filter(t => t.status === 'downloading' || t.status === 'seeding').slice(0, 5) as torrent}
							<div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
								<div class="flex-1 min-w-0">
									<p class="text-sm font-medium text-gray-900 dark:text-white truncate">
										{torrent.name}
									</p>
									<p class="text-xs text-gray-500 dark:text-gray-400">
										{torrent.progress}% • {torrent.speed}
									</p>
								</div>
								<div class="ml-4">
									<div class="w-16 bg-gray-200 dark:bg-gray-600 rounded-full h-2">
										<div class="bg-blue-600 h-2 rounded-full" style="width: {torrent.progress}%"></div>
									</div>
								</div>
							</div>
						{/each}
					{:else}
						<p class="text-gray-500 dark:text-gray-400 text-center py-4">
							Aucun téléchargement actif
						</p>
					{/if}
				</div>
				<div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
					<a href="/torrents" class="text-blue-600 dark:text-blue-400 text-sm font-medium hover:underline">
						Voir tous les torrents →
					</a>
				</div>
			</div>
		</div>

		<!-- Actions rapides -->
		<div class="mt-8">
			<div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
				<h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Actions Rapides</h2>
				<div class="flex flex-wrap gap-4">
					<a href="/torrents" class="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
						<span class="mr-2">📁</span>
						Gérer les Torrents
					</a>
					<a href="/queue" class="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
						<span class="mr-2">⏳</span>
						Voir la Queue
					</a>
					<a href="/settings" class="inline-flex items-center px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors">
						<span class="mr-2">⚙️</span>
						Paramètres
					</a>
				</div>
			</div>
		</div>

		<!-- Tableau des torrents récents -->
		<div class="mt-8">
			<div class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
				<div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
					<h2 class="text-lg font-semibold text-gray-900 dark:text-white">Torrents Récents</h2>
					<p class="text-sm text-gray-600 dark:text-gray-400 mt-1">Aperçu des derniers téléchargements</p>
				</div>
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
									Progression
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Vitesse
								</th>
							</tr>
						</thead>
						<tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
							{#if data.torrents && data.torrents.length > 0}
								{#each data.torrents.slice(0, 10) as torrent}
									<tr class="hover:bg-gray-50 dark:hover:bg-gray-700">
										<td class="px-6 py-4 whitespace-nowrap">
											<div class="text-sm font-medium text-gray-900 dark:text-white truncate max-w-xs">
												{torrent.name}
											</div>
											<div class="text-sm text-gray-500 dark:text-gray-400">
												{torrent.category}
											</div>
										</td>
										<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
											{torrent.size}
										</td>
										<td class="px-6 py-4 whitespace-nowrap">
											<span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full
												{torrent.status === 'completed' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' :
												torrent.status === 'downloading' ? 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200' :
												torrent.status === 'seeding' ? 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200' :
												torrent.status === 'error' ? 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200' :
												'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200'}">
												{torrent.status}
											</span>
										</td>
										<td class="px-6 py-4 whitespace-nowrap">
											<div class="flex items-center">
												<div class="w-16 bg-gray-200 dark:bg-gray-600 rounded-full h-2 mr-2">
													<div class="h-2 rounded-full
														{torrent.status === 'completed' ? 'bg-green-600' :
														torrent.status === 'downloading' ? 'bg-blue-600' :
														torrent.status === 'seeding' ? 'bg-purple-600' :
														torrent.status === 'error' ? 'bg-red-600' : 'bg-gray-400'}"
														style="width: {torrent.progress}%">
													</div>
												</div>
												<span class="text-sm text-gray-900 dark:text-white">{torrent.progress}%</span>
											</div>
										</td>
										<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
											{torrent.speed}
										</td>
									</tr>
								{/each}
							{:else}
								<tr>
									<td colspan="5" class="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
										Aucun torrent trouvé
									</td>
								</tr>
							{/if}
						</tbody>
					</table>
				</div>
				<div class="px-6 py-4 border-t border-gray-200 dark:border-gray-700">
					<a href="/torrents" class="text-blue-600 dark:text-blue-400 text-sm font-medium hover:underline">
						Voir tous les torrents ({data.torrents ? data.torrents.length : 0}) →
					</a>
				</div>
			</div>
		</div>
	{/if}
</div>
