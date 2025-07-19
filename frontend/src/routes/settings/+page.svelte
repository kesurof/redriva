<script lang="ts">
	import { onMount } from 'svelte';
	import { api } from '$lib/api';

	let loading = false;
	let message = '';
	let messageType: 'success' | 'error' | '' = '';

	async function updateTorrents() {
		loading = true;
		const response = await api.updateTorrents();
		
		if (response.success) {
			message = 'Mise à jour des torrents démarrée';
			messageType = 'success';
		} else {
			message = response.error || 'Erreur lors de la mise à jour';
			messageType = 'error';
		}
		
		loading = false;
		setTimeout(() => {
			message = '';
			messageType = '';
		}, 3000);
	}

	async function syncWithRealDebrid() {
		loading = true;
		const response = await api.syncWithRealDebrid();
		
		if (response.success) {
			message = 'Synchronisation Real-Debrid démarrée';
			messageType = 'success';
		} else {
			message = response.error || 'Erreur lors de la synchronisation';
			messageType = 'error';
		}
		
		loading = false;
		setTimeout(() => {
			message = '';
			messageType = '';
		}, 3000);
	}
</script>

<svelte:head>
	<title>Paramètres - Redriva</title>
</svelte:head>

<div class="p-6">
	<!-- Header -->
	<div class="mb-8">
		<h1 class="text-3xl font-bold text-gray-900 dark:text-white">Paramètres</h1>
		<p class="text-gray-600 dark:text-gray-400 mt-2">Configurez votre installation Redriva</p>
	</div>

	<!-- Messages -->
	{#if message}
		<div class="mb-6 p-4 rounded-lg {messageType === 'success' ? 'bg-green-100 dark:bg-green-900 text-green-700 dark:text-green-300' : 'bg-red-100 dark:bg-red-900 text-red-700 dark:text-red-300'}">
			{message}
		</div>
	{/if}

	<!-- Section Real-Debrid -->
	<div class="bg-white dark:bg-gray-800 rounded-lg shadow mb-6">
		<div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
			<h2 class="text-lg font-semibold text-gray-900 dark:text-white">Real-Debrid</h2>
		</div>
		<div class="p-6">
			<div class="mb-4">
				<p class="text-gray-600 dark:text-gray-400 mb-4">
					Gérez votre intégration Real-Debrid pour le téléchargement premium.
				</p>
				
				<div class="space-y-4">
					<div>
						<label for="rd-token" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
							Token d'API Real-Debrid
						</label>
						<div class="flex space-x-2">
							<input
								id="rd-token"
								type="password"
								placeholder="Votre token API..."
								class="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
							/>
							<button class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
								Sauvegarder
							</button>
						</div>
						<p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
							Vous pouvez obtenir votre token sur 
							<a href="https://real-debrid.com/apitoken" target="_blank" class="text-blue-600 dark:text-blue-400 hover:underline">
								real-debrid.com/apitoken
							</a>
						</p>
					</div>

					<div class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
						<div>
							<p class="font-medium text-gray-900 dark:text-white">Statut du compte</p>
							<p class="text-sm text-gray-500 dark:text-gray-400">Non configuré</p>
						</div>
						<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300">
							Non connecté
						</span>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Section Actions d'administration -->
	<div class="bg-white dark:bg-gray-800 rounded-lg shadow mb-6">
		<div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
			<h2 class="text-lg font-semibold text-gray-900 dark:text-white">Actions d'Administration</h2>
		</div>
		<div class="p-6">
			<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
				<div class="p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
					<h3 class="font-medium text-gray-900 dark:text-white mb-2">Mise à jour des Torrents</h3>
					<p class="text-sm text-gray-500 dark:text-gray-400 mb-4">
						Force la mise à jour de tous les torrents depuis les sources.
					</p>
					<button
						onclick={updateTorrents}
						disabled={loading}
						class="w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
					>
						{loading ? 'Mise à jour...' : 'Mettre à jour les Torrents'}
					</button>
				</div>

				<div class="p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
					<h3 class="font-medium text-gray-900 dark:text-white mb-2">Synchronisation Real-Debrid</h3>
					<p class="text-sm text-gray-500 dark:text-gray-400 mb-4">
						Synchronise les torrents avec votre compte Real-Debrid.
					</p>
					<button
						onclick={syncWithRealDebrid}
						disabled={loading}
						class="w-full px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
					>
						{loading ? 'Synchronisation...' : 'Synchroniser avec RD'}
					</button>
				</div>
			</div>
		</div>
	</div>

	<!-- Section Préférences -->
	<div class="bg-white dark:bg-gray-800 rounded-lg shadow">
		<div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
			<h2 class="text-lg font-semibold text-gray-900 dark:text-white">Préférences</h2>
		</div>
		<div class="p-6">
			<div class="space-y-6">
				<!-- Thème -->
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Thème de l'interface
					</label>
					<select class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
						<option value="light">Clair</option>
						<option value="dark">Sombre</option>
						<option value="auto">Automatique</option>
					</select>
				</div>

				<!-- Langue -->
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Langue
					</label>
					<select class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
						<option value="fr">Français</option>
						<option value="en">English</option>
					</select>
				</div>

				<!-- Notifications -->
				<div>
					<label class="flex items-center">
						<input
							type="checkbox"
							checked
							class="rounded border-gray-300 dark:border-gray-600 text-blue-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50"
						/>
						<span class="ml-2 text-sm text-gray-700 dark:text-gray-300">
							Activer les notifications de téléchargement
						</span>
					</label>
				</div>

				<!-- Actualisation automatique -->
				<div>
					<label class="flex items-center">
						<input
							type="checkbox"
							checked
							class="rounded border-gray-300 dark:border-gray-600 text-blue-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50"
						/>
						<span class="ml-2 text-sm text-gray-700 dark:text-gray-300">
							Actualisation automatique des données
						</span>
					</label>
				</div>
			</div>

			<div class="mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
				<button class="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
					Sauvegarder les Préférences
				</button>
			</div>
		</div>
	</div>

	<!-- Section À propos -->
	<div class="mt-8 bg-white dark:bg-gray-800 rounded-lg shadow">
		<div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
			<h2 class="text-lg font-semibold text-gray-900 dark:text-white">À propos</h2>
		</div>
		<div class="p-6">
			<div class="text-center">
				<h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">Redriva</h3>
				<p class="text-gray-600 dark:text-gray-400 mb-4">Gestionnaire de Torrents Premium</p>
				<div class="inline-flex items-center px-3 py-1 rounded-full text-sm bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200">
					Version 1.0.0
				</div>
				<div class="mt-6 text-sm text-gray-500 dark:text-gray-400">
					<p>Interface moderne développée avec SvelteKit</p>
					<p>API backend propulsée par FastAPI</p>
				</div>
			</div>
		</div>
	</div>
</div>
