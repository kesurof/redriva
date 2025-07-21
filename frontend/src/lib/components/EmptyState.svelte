<script lang="ts">
	export let title: string = 'Aucune donnée';
	export let description: string = 'Il n\'y a rien à afficher pour le moment.';
	export let icon: string = 'empty';
	export let actionText: string = '';
	export let actionHref: string = '';
	export let variant: 'default' | 'error' | 'info' | 'warning' = 'default';

	// Mappings pour les icônes prédéfinies
	const iconPaths: Record<string, string> = {
		empty: 'M19,3H5C3.89,3 3,3.89 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5C21,3.89 20.1,3 19,3M19,5V19H5V5H19Z',
		search: 'M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z',
		error: 'M13,14H11V10H13M13,18H11V16H13M1,21H23L12,2L1,21Z',
		info: 'M13,9H11V7H13M13,17H11V11H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z',
		folder: 'M10,4H4C2.89,4 2,4.89 2,6V18A2,2 0 0,0 4,20H20A2,2 0 0,0 22,18V8C22,6.89 21.1,6 20,6H12L10,4Z',
		download: 'M5,20H19V18H5M19,9H15V3H9V9H5L12,16L19,9Z'
	};

	// Couleurs selon la variante
	const variantClasses: Record<string, string> = {
		default: 'text-surface-400',
		error: 'text-error-400',
		info: 'text-primary-400',
		warning: 'text-warning-400'
	};

	$: iconPath = iconPaths[icon] || iconPaths.empty;
	$: iconColorClass = variantClasses[variant];

	import { createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();

	function handleAction() {
		dispatch('action');
	}
</script>

<div class="text-center py-12 px-6">
	<div class="max-w-md mx-auto space-y-6">
		<!-- Icône -->
		<div class="flex justify-center">
			<div class="w-16 h-16 rounded-full bg-surface-100 dark:bg-surface-800 flex items-center justify-center">
				<svg class="w-8 h-8 {iconColorClass}" fill="currentColor" viewBox="0 0 24 24">
					<path d="{iconPath}"/>
				</svg>
			</div>
		</div>

		<!-- Contenu -->
		<div class="space-y-2">
			<h3 class="h3 font-semibold text-surface-900 dark:text-surface-100">
				{title}
			</h3>
			<p class="text-surface-600 dark:text-surface-400">
				{description}
			</p>
		</div>

		<!-- Action -->
		{#if actionText}
			{#if actionHref}
				<a 
					href={actionHref}
					class="btn variant-filled-primary inline-flex"
				>
					{actionText}
				</a>
			{:else}
				<button 
					class="btn variant-filled-primary"
					on:click={handleAction}
				>
					{actionText}
				</button>
			{/if}
		{/if}
	</div>
</div>
