<script lang="ts">
	export let activities: Array<{
		id: string;
		type: 'download' | 'queue' | 'error' | 'success' | 'info';
		title: string;
		description: string;
		timestamp: string;
		status?: string;
	}> = [];

	// Mappings pour les icônes par type d'activité
	const typeIcons: Record<string, string> = {
		download: 'M5,20H19V18H5M19,9H15V3H9V9H5L12,16L19,9Z',
		queue: 'M3,5H9V11H3V5M5,7V9H7V7H5M11,7H21V9H11V7M11,15H21V17H11V15M5,20L1.5,16.5L2.91,15.09L5,17.17L9.59,12.59L11,14L5,20Z',
		error: 'M13,14H11V10H13M13,18H11V16H13M1,21H23L12,2L1,21Z',
		success: 'M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z',
		info: 'M13,9H11V7H13M13,17H11V11H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z'
	};

	// Mappings pour les variantes par type
	const typeVariants: Record<string, string> = {
		download: 'variant-soft-primary',
		queue: 'variant-soft-secondary',
		error: 'variant-soft-error',
		success: 'variant-soft-success',
		info: 'variant-soft-tertiary'
	};

	function formatTimestamp(timestamp: string): string {
		try {
			const date = new Date(timestamp);
			const now = new Date();
			const diffMs = now.getTime() - date.getTime();
			const diffMins = Math.floor(diffMs / 60000);
			
			if (diffMins < 1) return 'À l\'instant';
			if (diffMins < 60) return `Il y a ${diffMins} min`;
			
			const diffHours = Math.floor(diffMins / 60);
			if (diffHours < 24) return `Il y a ${diffHours}h`;
			
			const diffDays = Math.floor(diffHours / 24);
			if (diffDays < 7) return `Il y a ${diffDays}j`;
			
			return date.toLocaleDateString();
		} catch {
			return timestamp;
		}
	}
</script>

<div class="card p-6">
	<header class="flex items-center justify-between mb-4">
		<h2 class="h3">Activité Récente</h2>
		<button class="btn btn-sm variant-ghost-surface">
			<svg class="w-4 h-4 fill-current" viewBox="0 0 24 24">
				<path d="M17.65,6.35C16.2,4.9 14.21,4 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20C15.73,20 18.84,17.45 19.73,14H17.65C16.83,16.33 14.61,18 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6C13.66,6 15.14,6.69 16.22,7.78L13,11H20V4L17.65,6.35Z"/>
			</svg>
			<span>Actualiser</span>
		</button>
	</header>

	{#if activities.length === 0}
		<div class="text-center py-8">
			<svg class="w-12 h-12 mx-auto text-surface-400 mb-4" fill="currentColor" viewBox="0 0 24 24">
				<path d="M13,9H11V7H13M13,17H11V11H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z"/>
			</svg>
			<p class="text-surface-500">Aucune activité récente</p>
		</div>
	{:else}
		<div class="space-y-3 max-h-96 overflow-y-auto">
			{#each activities as activity (activity.id)}
				<div class="flex items-start gap-3 p-3 rounded-lg hover:bg-surface-100 dark:hover:bg-surface-800 transition-colors">
					<div class="flex-shrink-0 mt-1">
						<div class="w-8 h-8 rounded-full {typeVariants[activity.type]} flex items-center justify-center">
							<svg class="w-4 h-4 fill-current" viewBox="0 0 24 24">
								<path d="{typeIcons[activity.type]}"/>
							</svg>
						</div>
					</div>
					
					<div class="flex-1 min-w-0">
						<div class="flex items-start justify-between">
							<div class="flex-1 min-w-0">
								<p class="text-sm font-medium text-surface-900 dark:text-surface-100 truncate">
									{activity.title}
								</p>
								<p class="text-xs text-surface-600 dark:text-surface-400 mt-1">
									{activity.description}
								</p>
								{#if activity.status}
									<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium mt-2 {typeVariants[activity.type]}">
										{activity.status}
									</span>
								{/if}
							</div>
							<span class="text-xs text-surface-500 flex-shrink-0 ml-2">
								{formatTimestamp(activity.timestamp)}
							</span>
						</div>
					</div>
				</div>
			{/each}
		</div>

		{#if activities.length > 5}
			<div class="mt-4 text-center">
				<a href="/activity" class="btn btn-sm variant-ghost-primary">
					Voir toutes les activités
				</a>
			</div>
		{/if}
	{/if}
</div>
