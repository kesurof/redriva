<script context="module" lang="ts">
	export interface QueueCardProps {
		id: string;
		title: string;
		url: string;
		status: 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';
		priority: 'low' | 'normal' | 'high' | 'urgent';
		createdAt: string;
		processedAt?: string;
		errorMessage?: string;
		progress?: number;
		fileSize?: string;
		fileName?: string;
	}
</script>

<script lang="ts">
	// QueueCard.svelte - Composant Skeleton UI v2 pour afficher un élément de queue
	import { ProgressBar } from '@skeletonlabs/skeleton';

	export let id: QueueCardProps['id'];
	export let title: QueueCardProps['title'];
	export let url: QueueCardProps['url'];
	export let status: QueueCardProps['status'];
	export let priority: QueueCardProps['priority'];
	export let createdAt: QueueCardProps['createdAt'];
	export let processedAt: QueueCardProps['processedAt'] = undefined;
	export let errorMessage: QueueCardProps['errorMessage'] = undefined;
	export let progress: QueueCardProps['progress'] = undefined;
	export let fileSize: QueueCardProps['fileSize'] = undefined;
	export let fileName: QueueCardProps['fileName'] = undefined;

	// Utilitaires pour le statut
	function getStatusColor(status: QueueCardProps['status']): string {
		switch (status) {
			case 'processing': return 'text-primary-500';
			case 'completed': return 'text-success-500';
			case 'failed': return 'text-error-500';
			case 'cancelled': return 'text-warning-500';
			case 'pending': return 'text-surface-500';
			default: return 'text-surface-500';
		}
	}

	function getStatusIcon(status: QueueCardProps['status']): string {
		switch (status) {
			case 'processing': return '⚡';
			case 'completed': return '✅';
			case 'failed': return '❌';
			case 'cancelled': return '⏹️';
			case 'pending': return '⏳';
			default: return '❓';
		}
	}

	function getStatusLabel(status: QueueCardProps['status']): string {
		switch (status) {
			case 'processing': return 'En cours';
			case 'completed': return 'Terminé';
			case 'failed': return 'Échec';
			case 'cancelled': return 'Annulé';
			case 'pending': return 'En attente';
			default: return 'Inconnu';
		}
	}

	function getPriorityColor(priority: QueueCardProps['priority']): string {
		switch (priority) {
			case 'urgent': return 'bg-error-500';
			case 'high': return 'bg-warning-500';
			case 'normal': return 'bg-primary-500';
			case 'low': return 'bg-surface-500';
			default: return 'bg-surface-500';
		}
	}

	function formatDate(dateString: string): string {
		return new Date(dateString).toLocaleString('fr-FR');
	}

	function truncateUrl(url: string, maxLength: number = 50): string {
		if (url.length <= maxLength) return url;
		return url.substring(0, maxLength) + '...';
	}
</script>

<!-- Card Queue Skeleton UI v2 -->
<div class="card variant-glass-surface">
	<!-- En-tête avec titre et priorité -->
	<header class="card-header">
		<div class="flex items-start justify-between gap-4">
			<div class="flex-1 min-w-0">
				<h3 class="h4 truncate" title={title}>{title}</h3>
				<div class="flex items-center gap-2 mt-1">
					<span class="text-sm {getStatusColor(status)}">
						{getStatusIcon(status)} {getStatusLabel(status)}
					</span>
					{#if priority !== 'normal'}
						<span class="badge variant-filled {getPriorityColor(priority)} text-xs">
							{priority.toUpperCase()}
						</span>
					{/if}
				</div>
			</div>
			<div class="text-right text-sm text-surface-500">
				{#if fileSize}
					<div>{fileSize}</div>
				{/if}
				<div>{formatDate(createdAt)}</div>
			</div>
		</div>
	</header>

	<!-- Corps avec URL et progression -->
	<section class="p-4 space-y-3">
		<!-- URL -->
		<div class="space-y-1">
			<div class="text-xs text-surface-500">URL</div>
			<div class="text-sm font-mono bg-surface-100-800-token p-2 rounded">
				<a href={url} target="_blank" rel="noopener noreferrer" 
				   class="text-primary-500 hover:underline" title={url}>
					{truncateUrl(url)}
				</a>
			</div>
		</div>

		<!-- Nom de fichier si disponible -->
		{#if fileName}
			<div class="space-y-1">
				<div class="text-xs text-surface-500">Fichier</div>
				<div class="text-sm truncate" title={fileName}>{fileName}</div>
			</div>
		{/if}

		<!-- Barre de progression si en cours -->
		{#if status === 'processing' && progress !== undefined}
			<div class="space-y-1">
				<div class="flex justify-between text-xs text-surface-500">
					<span>Progression</span>
					<span>{progress}%</span>
				</div>
				<ProgressBar 
					value={progress} 
					max={100}
					height="h-2"
					meter="bg-primary-500"
				/>
			</div>
		{/if}

		<!-- Message d'erreur si échec -->
		{#if status === 'failed' && errorMessage}
			<div class="alert variant-ghost-error">
				<div class="alert-message">
					<p class="text-sm">{errorMessage}</p>
				</div>
			</div>
		{/if}

		<!-- Informations de traitement -->
		{#if processedAt}
			<div class="text-xs text-surface-500">
				Traité le {formatDate(processedAt)}
			</div>
		{/if}
	</section>

	<!-- Footer avec actions -->
	<footer class="card-footer">
		<div class="flex justify-end gap-2">
			{#if status === 'pending'}
				<button class="btn btn-sm variant-ghost-primary">🚀 Démarrer</button>
				<button class="btn btn-sm variant-ghost-warning">⏸️ Suspendre</button>
			{:else if status === 'processing'}
				<button class="btn btn-sm variant-ghost-warning">⏸️ Pause</button>
			{:else if status === 'failed'}
				<button class="btn btn-sm variant-ghost-primary">🔄 Réessayer</button>
			{:else if status === 'completed'}
				<button class="btn btn-sm variant-ghost-success">📁 Ouvrir</button>
			{/if}
			
			<button class="btn btn-sm variant-ghost-error">🗑️ Supprimer</button>
		</div>
	</footer>
</div>
