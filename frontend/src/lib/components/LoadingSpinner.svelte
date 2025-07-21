<script lang="ts">
	export let size: 'sm' | 'md' | 'lg' = 'md';
	export let color: string = 'text-primary-500';
	export let message: string = '';
	export let overlay: boolean = false;

	// Classes de taille
	const sizeClasses = {
		sm: 'w-4 h-4',
		md: 'w-8 h-8',
		lg: 'w-12 h-12'
	};

	$: spinnerClass = `${sizeClasses[size]} ${color}`;
</script>

{#if overlay}
	<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
		<div class="card p-8 text-center space-y-4">
			<svg class="{spinnerClass} animate-spin mx-auto" viewBox="0 0 24 24" fill="none">
				<circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" class="opacity-25"/>
				<path fill="currentColor" class="opacity-75" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
			</svg>
			{#if message}
				<p class="text-surface-600 dark:text-surface-400">{message}</p>
			{/if}
		</div>
	</div>
{:else}
	<div class="flex items-center justify-center gap-3">
		<svg class="{spinnerClass} animate-spin" viewBox="0 0 24 24" fill="none">
			<circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" class="opacity-25"/>
			<path fill="currentColor" class="opacity-75" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
		</svg>
		{#if message}
			<span class="text-surface-600 dark:text-surface-400">{message}</span>
		{/if}
	</div>
{/if}
