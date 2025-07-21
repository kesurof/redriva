<script lang="ts">
	import type { PageData } from './$types';
	import TorrentAddModal from '$lib/components/TorrentAddModal.svelte';
	import TorrentCard from '$lib/components/TorrentCard.svelte';
	import StatCard from '$lib/components/StatCard.svelte';
	import { onMount } from 'svelte';

	export let data: PageData;

	let showModal = false;
	let isMounted = false;

	onMount(() => {
		isMounted = true;
	});

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

	// Utilitaires pour les statistiques
	function getTotalDownloaded(): string {
		if (!data.torrents || data.torrents.length === 0) return '0 GB';
		const total = data.torrents.reduce((sum, torrent) => {
			return sum + (torrent.size * torrent.progress / 100);
		}, 0);
		return formatSize(total);
	}

	function getActiveTorrents(): number {
		if (!data.torrents) return 0;
		return data.torrents.filter(t => t.status === 'downloading' || t.status === 'téléchargement').length;
	}

	function getCompletedTorrents(): number {
		if (!data.torrents) return 0;
		return data.torrents.filter(t => t.status === 'completed' || t.status === 'terminé').length;
	}

	function getAverageProgress(): number {
		if (!data.torrents || data.torrents.length === 0) return 0;
		const total = data.torrents.reduce((sum, torrent) => sum + torrent.progress, 0);
		return Math.round(total / data.torrents.length);
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

<svelte:head>
	<title>Torrents - Redriva</title>
</svelte:head>

<div class="space-y-6">
	<!-- Header -->
	<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
		<div class="space-y-2">
			<h1 class="h1">Gestion des Torrents</h1>
			<p class="text-surface-500">Gérez vos téléchargements et votre collection</p>
		</div>
		<button 
			class="btn variant-filled-primary mt-4 sm:mt-0"
			on:click={openAddModal}
		>
			<svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
				<path d="M19,13H13V19H11V13H5V11H11V5H13V11H19V13Z"/>
			</svg>
			<span>Ajouter un Torrent</span>
		</button>
	</div>

	{#if data.error}
		<!-- Cas d'erreur -->
		<div class="alert variant-filled-error">
			<svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
				<path d="M13,13H11V7H13M13,17H11V15H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z"/>
			</svg>
			<div class="alert-message">
				<h3 class="h3">Erreur de chargement</h3>
				<p>{data.error}</p>
			</div>
		</div>
	{:else if data.torrents && data.torrents.length > 0}
		<!-- Statistiques des torrents -->
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
			<StatCard
				title="Total"
				value="{data.torrents.length}"
				subtitle="torrents"
				icon="download"
				variant="primary"
				size="sm"
			/>
			<StatCard
				title="Actifs"
				value="{getActiveTorrents()}"
				subtitle="en téléchargement"
				icon="arrow-down"
				variant="secondary"
				size="sm"
				trend={getActiveTorrents() > 0 ? 'up' : 'stable'}
			/>
			<StatCard
				title="Terminés"
				value="{getCompletedTorrents()}"
				subtitle="prêts"
				icon="check"
				variant="success"
				size="sm"
			/>
			<StatCard
				title="Progression"
				value="{getAverageProgress()}%"
				subtitle="moyenne"
				icon="progress"
				variant="tertiary"
				size="sm"
				progress={getAverageProgress()}
			/>
		</div>

		<!-- Liste des torrents avec TorrentCard -->
		<div class="space-y-4">
			{#each data.torrents as torrent}
				<TorrentCard
					id={torrent.id}
					name={torrent.name || 'Nom non disponible'}
					status={torrent.status === 'téléchargement' ? 'downloading' : 
							torrent.status === 'terminé' ? 'completed' : 
							torrent.status === 'en pause' ? 'paused' : 
							torrent.status === 'erreur' ? 'error' : 'waiting'}
					progress={torrent.progress || 0}
					size={torrent.size ? formatSize(torrent.size) : 'N/A'}
					downloadSpeed={torrent.downloadSpeed}
					uploadSpeed={torrent.uploadSpeed}
					eta={torrent.eta}
					seeders={torrent.seeders}
					leechers={torrent.leechers}
					priority={torrent.priority || 'normal'}
				/>
			{/each}
		</div>
	{:else if data.torrents && data.torrents.length === 0}
		<!-- Cas de liste vide -->
		<div class="card">
			<section class="p-12 text-center">
				<svg class="w-16 h-16 mx-auto text-surface-400 mb-4" fill="currentColor" viewBox="0 0 24 24">
					<path d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z"/>
				</svg>
				<h3 class="h3 mb-2">Aucun torrent trouvé</h3>
				<p class="text-surface-500 mb-4">
					La liste des torrents est vide. Commencez par ajouter votre premier torrent.
				</p>
				<button 
					class="btn variant-filled-primary"
					on:click={openAddModal}
				>
					<svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
						<path d="M19,13H13V19H11V13H5V11H11V5H13V11H19V13Z"/>
					</svg>
					<span>Ajouter un Torrent</span>
				</button>
			</section>
		</div>
	{:else}
		<!-- Cas de chargement -->
		<div class="card">
			<section class="p-12">
				<div class="flex items-center justify-center">
					<div class="animate-spin w-8 h-8 mr-3">
						<svg fill="currentColor" viewBox="0 0 24 24">
							<path d="M12,4V2A10,10 0 0,0 2,12H4A8,8 0 0,1 12,4Z"/>
						</svg>
					</div>
					<span class="text-surface-500">Chargement des torrents...</span>
				</div>
			</section>
		</div>
	{/if}
</div>

<!-- Modale d'ajout de torrent -->
{#if showModal}
	<div class="fixed inset-0 z-[999] flex items-center justify-center bg-surface-backdrop-token backdrop-blur-sm">
		<div class="card w-full max-w-md mx-4">
			<section class="card-header">
				<h3 class="h3">Ajouter un nouveau torrent</h3>
			</section>
			<section class="p-6">
				<TorrentAddModal 
					on:torrentAdded={handleTorrentAdded}
					on:cancel={handleCancel}
				/>
			</section>
		</div>
	</div>
{/if}
