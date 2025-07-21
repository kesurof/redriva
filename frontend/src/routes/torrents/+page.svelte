<script lang="ts">
	import type { PageData } from './$types';
	import { Progress } from '@skeletonlabs/skeleton';
	import TorrentAddModal from '$lib/components/TorrentAddModal.svelte';

	export let data: PageData;

	let showModal = false;

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

	// Fonction de suppression d'un torrent
	async function deleteTorrent(id: string) {
		try {
			const response = await fetch(`/api/torrents/${id}`, {
				method: 'DELETE'
			});

			if (response.ok) {
				// Mise à jour réactive : filtrer le torrent supprimé
				data.torrents = data.torrents.filter((torrent: any) => torrent.id !== id);
			} else {
				console.error('Erreur lors de la suppression:', response.status);
			}
		} catch (error) {
			console.error('Erreur réseau lors de la suppression:', error);
		}
	}

	// Fonction pour ouvrir la modale d'ajout
	function openAddModal() {
		showModal = true;
	}

	// Fonction appelée quand un torrent est ajouté
	function handleTorrentAdded(event: CustomEvent) {
		const newTorrent = event.detail;
		// Ajouter le nouveau torrent à la liste
		data.torrents = [...data.torrents, newTorrent];
		// Fermer la modale
		showModal = false;
	}

	// Fonction appelée quand la modale est annulée
	function handleCancel() {
		showModal = false;
	}
</script>

<div class="p-8 space-y-6">
	<div class="flex justify-between items-center">
		<h1 class="h1">Gestion des Torrents</h1>
		<button 
			class="btn preset-filled-primary"
			on:click={openAddModal}
		>
			Ajouter un Torrent
		</button>
	</div>

	{#if data.error}
		<!-- Cas d'erreur -->
		<div class="alert preset-filled-error">
			<div class="alert-message">
				<h3>Erreur de chargement</h3>
				<p>{data.error}</p>
			</div>
		</div>
	{:else if data.torrents && data.torrents.length > 0}
		<!-- Cas de succès - Affichage du tableau des torrents -->
		<div class="card">
			<div class="table-container">
				<table class="table table-hover">
					<thead>
						<tr>
							<th>Nom</th>
							<th>Taille</th>
							<th>Progression</th>
							<th>Statut</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						{#each data.torrents as torrent}
							<tr 
								class="cursor-pointer hover:bg-surface-hover-token"
								on:click={() => window.location.href = `/torrents/${torrent.id}`}
							>
								<td class="font-medium">
									{torrent.name || 'Nom non disponible'}
								</td>
								<td>
									{torrent.size ? formatSize(torrent.size) : 'N/A'}
								</td>
								<td class="min-w-32">
									<div class="space-y-1">
										<div class="text-sm">
											{torrent.progress || 0}%
										</div>
										<Progress 
											value={torrent.progress || 0} 
											max={100}
										/>
									</div>
								</td>
								<td>
									<span class="badge preset-tonal-primary">
										{torrent.status || 'Inconnu'}
									</span>
								</td>
								<td>
									<button 
										class="btn preset-filled-error btn-sm"
										on:click|stopPropagation={() => deleteTorrent(torrent.id)}
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
	{:else if data.torrents && data.torrents.length === 0}
		<!-- Cas de liste vide -->
		<div class="card p-8">
			<div class="text-center space-y-4">
				<div class="text-lg">Aucun torrent trouvé</div>
				<div class="text-sm text-surface-500">
					La liste des torrents est vide.
				</div>
			</div>
		</div>
	{:else}
		<!-- Cas de chargement -->
		<div class="flex items-center justify-center p-12">
			<div class="text-center space-y-4">
				<div class="text-lg">Chargement des torrents...</div>
				<Progress value={undefined} />
			</div>
		</div>
	{/if}
</div>

<!-- Modale d'ajout de torrent -->
{#if showModal}
	<div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
		<div class="bg-surface-100-800-token rounded-lg p-6 max-w-md w-full mx-4">
			<TorrentAddModal 
				on:torrentAdded={handleTorrentAdded}
				on:cancel={handleCancel}
			/>
		</div>
	</div>
{/if}
