<script lang="ts">
	import type { PageData } from './$types';
	import { Progress } from '@skeletonlabs/skeleton-svelte';

	export let data: PageData;

	// Fonction utilitaire pour convertir les octets en Go
	function bytesToGB(bytes: number): string {
		return (bytes / (1024 ** 3)).toFixed(2);
	}

	// Fonction utilitaire pour formater la taille
	function formatSize(bytes: number): string {
		if (bytes < 1024) return `${bytes} B`;
		if (bytes < 1024 ** 2) return `${(bytes / 1024).toFixed(1)} KB`;
		if (bytes < 1024 ** 3) return `${(bytes / (1024 ** 2)).toFixed(1)} MB`;
		return `${bytesToGB(bytes)} GB`;
	}

	// Fonction pour revenir à la liste
	function goBack() {
		window.history.back();
	}
</script>

<div class="p-8 space-y-6">
	<div class="flex items-center space-x-4">
		<button 
			class="btn preset-outlined-surface btn-sm"
			on:click={goBack}
		>
			← Retour
		</button>
		<h1 class="h1">Détails du Torrent</h1>
	</div>

	{#if data.error}
		<!-- Cas d'erreur -->
		<div class="alert preset-filled-error">
			<div class="alert-message">
				<h3>Erreur de chargement</h3>
				<p>{data.error}</p>
			</div>
		</div>
	{:else if data.torrent}
		<!-- Cas de succès - Affichage des détails -->
		
		<!-- Partie 1: En-tête avec informations principales -->
		<div class="card p-6">
			<div class="space-y-4">
				<h2 class="h2">{data.torrent.name || 'Nom non disponible'}</h2>
				
				<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
					<!-- Taille totale -->
					<div class="space-y-2">
						<h3 class="h4">Taille totale</h3>
						<p class="text-xl font-semibold text-primary-500">
							{data.torrent.size ? formatSize(data.torrent.size) : 'N/A'}
						</p>
					</div>

					<!-- Statut -->
					<div class="space-y-2">
						<h3 class="h4">Statut</h3>
						<span class="badge preset-tonal-primary text-lg">
							{data.torrent.status || 'Inconnu'}
						</span>
					</div>

					<!-- Progression -->
					<div class="space-y-2">
						<h3 class="h4">Progression</h3>
						<div class="space-y-1">
							<div class="text-xl font-semibold">
								{data.torrent.progress || 0}%
							</div>
							<Progress 
								value={data.torrent.progress || 0} 
								max={100}
							/>
						</div>
					</div>
				</div>
			</div>
		</div>

		<!-- Partie 2: Liste des fichiers -->
		<div class="space-y-4">
			<h2 class="h2">Fichiers Disponibles</h2>
			
			{#if data.torrent.files && data.torrent.files.length > 0}
				<div class="card">
					<div class="table-container">
						<table class="table table-hover">
							<thead>
								<tr>
									<th>Nom du Fichier</th>
									<th>Taille</th>
									<th>Progression</th>
								</tr>
							</thead>
							<tbody>
								{#each data.torrent.files as file}
									<tr>
										<td class="font-medium">
											{file.name || 'Fichier sans nom'}
										</td>
										<td>
											{file.size ? formatSize(file.size) : 'N/A'}
										</td>
										<td class="min-w-32">
											<div class="space-y-1">
												<div class="text-sm">
													{file.progress || 0}%
												</div>
												<Progress 
													value={file.progress || 0} 
													max={100}
												/>
											</div>
										</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				</div>
			{:else}
				<div class="card p-8">
					<div class="text-center space-y-4">
						<div class="text-lg">Aucun fichier trouvé</div>
						<div class="text-sm text-surface-500">
							La liste des fichiers n'est pas disponible pour ce torrent.
						</div>
					</div>
				</div>
			{/if}
		</div>
	{:else}
		<!-- Cas de chargement -->
		<div class="flex items-center justify-center p-12">
			<div class="text-center space-y-4">
				<div class="text-lg">Chargement des détails...</div>
				<Progress value={undefined} />
			</div>
		</div>
	{/if}
</div>
