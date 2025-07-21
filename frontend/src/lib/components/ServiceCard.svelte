<script lang="ts">
	export let name: string;
	export let description: string = '';
	export let status: 'online' | 'offline' | 'warning' | 'maintenance' = 'offline';
	export let url: string = '';
	export let version: string = '';
	export let lastCheck: string = '';
	export let responseTime: number | undefined = undefined;

	// Mappings pour les statuts
	const statusConfig: Record<string, { variant: string; icon: string; label: string }> = {
		online: {
			variant: 'variant-filled-success',
			icon: 'M12,2A10,10 0 0,1 22,12A10,10 0 0,1 12,22A10,10 0 0,1 2,12A10,10 0 0,1 12,2M11,16.5L18,9.5L16.59,8.09L11,13.67L7.91,10.59L6.5,12L11,16.5Z',
			label: 'En ligne'
		},
		offline: {
			variant: 'variant-filled-error',
			icon: 'M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M12,6A6,6 0 0,1 18,12C18,13.75 17.39,15.36 16.4,16.65L7.35,7.6C8.64,6.61 10.25,6 12,6M6,12A6,6 0 0,1 12,6L6,12M6,12A6,6 0 0,0 12,18C13.75,18 15.36,17.39 16.65,16.4L7.6,7.35C6.61,8.64 6,10.25 6,12Z',
			label: 'Hors ligne'
		},
		warning: {
			variant: 'variant-filled-warning',
			icon: 'M13,14H11V10H13M13,18H11V16H13M1,21H23L12,2L1,21Z',
			label: 'Avertissement'
		},
		maintenance: {
			variant: 'variant-filled-secondary',
			icon: 'M12,15.5A3.5,3.5 0 0,1 8.5,12A3.5,3.5 0 0,1 12,8.5A3.5,3.5 0 0,1 15.5,12A3.5,3.5 0 0,1 12,15.5M19.43,12.97C19.47,12.65 19.5,12.33 19.5,12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.66 15.5,5.32 14.87,5.07L14.5,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.5,2.42L9.13,5.07C8.5,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,5.27L2.34,8.73C2.22,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.22,15.05 2.34,15.27L4.34,18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.5,18.68 9.13,18.93L9.5,21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.5,21.58L14.87,18.93C15.5,18.68 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z',
			label: 'Maintenance'
		}
	};

	$: config = statusConfig[status];

	function formatLastCheck(timestamp: string): string {
		if (!timestamp) return 'Jamais';
		try {
			const date = new Date(timestamp);
			const now = new Date();
			const diffMs = now.getTime() - date.getTime();
			const diffMins = Math.floor(diffMs / 60000);
			
			if (diffMins < 1) return 'À l\'instant';
			if (diffMins < 60) return `Il y a ${diffMins} min`;
			
			const diffHours = Math.floor(diffMins / 60);
			if (diffHours < 24) return `Il y a ${diffHours}h`;
			
			return date.toLocaleDateString();
		} catch {
			return timestamp;
		}
	}
</script>

<div class="card p-6 hover:scale-105 transition-all duration-200">
	<div class="flex items-start justify-between">
		<div class="flex-1">
			<div class="flex items-center gap-3 mb-3">
				<h3 class="h4 font-semibold">{name}</h3>
				<span class="badge {config.variant}">
					<svg class="w-3 h-3 fill-current mr-1" viewBox="0 0 24 24">
						<path d="{config.icon}"/>
					</svg>
					{config.label}
				</span>
			</div>
			
			{#if description}
				<p class="text-sm text-surface-600 dark:text-surface-400 mb-3">{description}</p>
			{/if}
			
			<div class="space-y-2 text-xs text-surface-500">
				{#if version}
					<div class="flex items-center gap-2">
						<svg class="w-3 h-3 fill-current" viewBox="0 0 24 24">
							<path d="M13,9H11V7H13M13,17H11V11H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z"/>
						</svg>
						<span>Version: {version}</span>
					</div>
				{/if}
				
				{#if responseTime !== undefined}
					<div class="flex items-center gap-2">
						<svg class="w-3 h-3 fill-current" viewBox="0 0 24 24">
							<path d="M12,20A8,8 0 0,0 20,12A8,8 0 0,0 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20M12,2A10,10 0 0,1 22,12A10,10 0 0,1 12,22A10,10 0 0,1 2,12A10,10 0 0,1 12,2Z"/>
						</svg>
						<span>Temps de réponse: {responseTime}ms</span>
					</div>
				{/if}
				
				{#if lastCheck}
					<div class="flex items-center gap-2">
						<svg class="w-3 h-3 fill-current" viewBox="0 0 24 24">
							<path d="M12,2A10,10 0 0,1 22,12A10,10 0 0,1 12,22A10,10 0 0,1 2,12A10,10 0 0,1 12,2M12,6A6,6 0 0,1 18,12A6,6 0 0,1 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6Z"/>
						</svg>
						<span>Dernière vérification: {formatLastCheck(lastCheck)}</span>
					</div>
				{/if}
			</div>
		</div>
		
		<div class="flex flex-col gap-2">
			{#if url}
				<a href={url} target="_blank" class="btn btn-sm variant-ghost-surface">
					<svg class="w-4 h-4 fill-current" viewBox="0 0 24 24">
						<path d="M14,3V5H17.59L7.76,14.83L9.17,16.24L19,6.41V10H21V3M19,19H5V5H12V3H5C3.89,3 3,3.9 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V12H19V19Z"/>
					</svg>
					Ouvrir
				</a>
			{/if}
			
			<button class="btn btn-sm variant-ghost-surface">
				<svg class="w-4 h-4 fill-current" viewBox="0 0 24 24">
					<path d="M17.65,6.35C16.2,4.9 14.21,4 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20C15.73,20 18.84,17.45 19.73,14H17.65C16.83,16.33 14.61,18 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6C13.66,6 15.14,6.69 16.22,7.78L13,11H20V4L17.65,6.35Z"/>
				</svg>
				Tester
			</button>
		</div>
	</div>
</div>
