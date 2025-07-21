<script context="module" lang="ts">
	export interface TorrentCardProps {
		id: string;
		name: string;
		status: 'downloading' | 'completed' | 'paused' | 'error' | 'waiting';
		progress: number;
		size: string;
		downloadSpeed?: string;
		uploadSpeed?: string;
		eta?: string;
		seeders?: number;
		leechers?: number;
		priority?: 'low' | 'normal' | 'high';
	}
</script>

<script lang="ts">
	// TorrentCard.svelte - Composant Skeleton UI v2 pour afficher un torrent
	import { ProgressBar } from '@skeletonlabs/skeleton';

	export let id: TorrentCardProps['id'];
	export let name: TorrentCardProps['name'];
	export let status: TorrentCardProps['status'];
	export let progress: TorrentCardProps['progress'];
	export let size: TorrentCardProps['size'];
	export let downloadSpeed: TorrentCardProps['downloadSpeed'] = undefined;
	export let uploadSpeed: TorrentCardProps['uploadSpeed'] = undefined;
	export let eta: TorrentCardProps['eta'] = undefined;
	export let seeders: TorrentCardProps['seeders'] = undefined;
	export let leechers: TorrentCardProps['leechers'] = undefined;
	export let priority: TorrentCardProps['priority'] = 'normal';

	// Utilitaires pour le statut
	function getStatusColor(status: TorrentCardProps['status']): string {
		switch (status) {
			case 'downloading': return 'text-primary-500';
			case 'completed': return 'text-success-500';
			case 'paused': return 'text-warning-500';
			case 'error': return 'text-error-500';
			case 'waiting': return 'text-surface-500';
			default: return 'text-surface-500';
		}
	}

	function getStatusIcon(status: TorrentCardProps['status']): string {
		switch (status) {
			case 'downloading': return '⬇️';
			case 'completed': return '✅';
			case 'paused': return '⏸️';
			case 'error': return '❌';
			case 'waiting': return '⏳';
			default: return '❓';
		}
	}

	function getStatusLabel(status: TorrentCardProps['status']): string {
		switch (status) {
			case 'downloading': return 'Téléchargement';
			case 'completed': return 'Terminé';
			case 'paused': return 'En pause';
			case 'error': return 'Erreur';
			case 'waiting': return 'En attente';
			default: return 'Inconnu';
		}
	}

	function getPriorityColor(priority: TorrentCardProps['priority']): string {
		switch (priority) {
			case 'high': return 'bg-error-500';
			case 'normal': return 'bg-primary-500';
			case 'low': return 'bg-surface-500';
			default: return 'bg-surface-500';
		}
	}
</script>

<!-- Card Torrent Skeleton UI v2 -->
<div class="card variant-glass-surface">
	<!-- En-tête avec statut et priorité -->
	<header class="card-header">
		<div class="flex items-start justify-between gap-4">
			<div class="flex-1 min-w-0">
				<h3 class="h4 truncate" title={name}>{name}</h3>
				<div class="flex items-center gap-2 mt-1">
					<span class="text-sm {getStatusColor(status)}">
						{getStatusIcon(status)} {getStatusLabel(status)}
					</span>
					{#if priority && priority !== 'normal'}
						<span class="badge variant-filled {getPriorityColor(priority)} text-xs">
							{priority.toUpperCase()}
						</span>
					{/if}
				</div>
			</div>
			<div class="text-right text-sm text-surface-500">
				<div>{size}</div>
				{#if progress < 100}
					<div>{progress}%</div>
				{/if}
			</div>
		</div>
	</header>

	<!-- Corps avec barre de progression -->
	<section class="p-4 space-y-3">
		<!-- Barre de progression -->
		<ProgressBar 
			value={progress} 
			max={100}
			height="h-2"
			meter={status === 'completed' ? 'bg-success-500' : 
				   status === 'error' ? 'bg-error-500' :
				   status === 'paused' ? 'bg-warning-500' : 'bg-primary-500'}
		/>

		<!-- Informations détaillées -->
		<div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
			{#if downloadSpeed}
				<div class="space-y-1">
					<div class="text-surface-500">Téléchargement</div>
					<div class="font-medium text-primary-500">⬇️ {downloadSpeed}</div>
				</div>
			{/if}

			{#if uploadSpeed}
				<div class="space-y-1">
					<div class="text-surface-500">Upload</div>
					<div class="font-medium text-secondary-500">⬆️ {uploadSpeed}</div>
				</div>
			{/if}

			{#if eta && status === 'downloading'}
				<div class="space-y-1">
					<div class="text-surface-500">Temps restant</div>
					<div class="font-medium">⏱️ {eta}</div>
				</div>
			{/if}

			{#if seeders !== undefined || leechers !== undefined}
				<div class="space-y-1">
					<div class="text-surface-500">Sources</div>
					<div class="font-medium">
						{#if seeders !== undefined}🌱 {seeders}{/if}
						{#if leechers !== undefined}📥 {leechers}{/if}
					</div>
				</div>
			{/if}
		</div>
	</section>

	<!-- Footer avec actions -->
	<footer class="card-footer">
		<div class="flex justify-end gap-2">
			{#if status === 'downloading'}
				<button class="btn btn-sm variant-ghost-warning">⏸️ Pause</button>
			{:else if status === 'paused'}
				<button class="btn btn-sm variant-ghost-primary">▶️ Reprendre</button>
			{/if}
			
			{#if status === 'completed'}
				<button class="btn btn-sm variant-ghost-success">📁 Ouvrir</button>
			{/if}
			
			<button class="btn btn-sm variant-ghost-error">🗑️ Supprimer</button>
		</div>
	</footer>
</div>
