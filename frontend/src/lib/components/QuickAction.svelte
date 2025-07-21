<script lang="ts">
	export let title: string;
	export let description: string = '';
	export let icon: string = '';
	export let variant: string = 'variant-soft-primary';
	export let href: string = '';
	export let disabled: boolean = false;
	export let badge: string = '';
	export let badgeVariant: string = 'variant-filled-primary';

	// Mappings pour les icônes prédéfinies
	const iconPaths: Record<string, string> = {
		add: 'M19,13H13V19H11V13H5V11H11V5H13V11H19V13Z',
		settings: 'M12,15.5A3.5,3.5 0 0,1 8.5,12A3.5,3.5 0 0,1 12,8.5A3.5,3.5 0 0,1 15.5,12A3.5,3.5 0 0,1 12,15.5M19.43,12.97C19.47,12.65 19.5,12.33 19.5,12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.66 15.5,5.32 14.87,5.07L14.5,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.5,2.42L9.13,5.07C8.5,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,5.27L2.34,8.73C2.22,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.22,15.05 2.34,15.27L4.34,18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.5,18.68 9.13,18.93L9.5,21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.5,21.58L14.87,18.93C15.5,18.68 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z',
		download: 'M5,20H19V18H5M19,9H15V3H9V9H5L12,16L19,9Z',
		play: 'M8,5.14V19.14L19,12.14L8,5.14Z',
		pause: 'M14,19H18V5H14M6,19H10V5H6V19Z',
		stop: 'M18,18H6V6H18V18Z',
		folder: 'M10,4H4C2.89,4 2,4.89 2,6V18A2,2 0 0,0 4,20H20A2,2 0 0,0 22,18V8C22,6.89 21.1,6 20,6H12L10,4Z',
		refresh: 'M17.65,6.35C16.2,4.9 14.21,4 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20C15.73,20 18.84,17.45 19.73,14H17.65C16.83,16.33 14.61,18 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6C13.66,6 15.14,6.69 16.22,7.78L13,11H20V4L17.65,6.35Z',
		monitor: 'M21,16V4H3V16H21M21,2A2,2 0 0,1 23,4V16A2,2 0 0,1 21,18H14V20H16V22H8V20H10V18H3C1.89,18 1,17.1 1,16V4C1,2.89 1.89,2 3,2H21Z',
		info: 'M13,9H11V7H13M13,17H11V11H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z'
	};

	$: iconPath = iconPaths[icon] || '';

	function handleClick() {
		if (disabled) return;
		// Si href est fourni, navigation sera gérée par l'élément <a>
	}
</script>

{#if href && !disabled}
	<a 
		{href}
		class="block card {variant} p-6 hover:scale-105 transition-all duration-200 cursor-pointer"
		on:click={handleClick}
	>
		<div class="flex items-center justify-between">
			<div class="flex-1">
				<div class="flex items-center gap-3">
					{#if icon && iconPath}
						<div class="p-2 rounded-lg bg-surface-100 dark:bg-surface-800">
							<svg class="w-5 h-5 fill-current" viewBox="0 0 24 24">
								<path d="{iconPath}"/>
							</svg>
						</div>
					{/if}
					
					<div>
						<h3 class="font-semibold text-surface-900 dark:text-surface-100">{title}</h3>
						{#if description}
							<p class="text-sm text-surface-600 dark:text-surface-400">{description}</p>
						{/if}
					</div>
				</div>
			</div>
			
			{#if badge}
				<span class="badge {badgeVariant}">{badge}</span>
			{/if}
		</div>
	</a>
{:else}
	<button 
		class="w-full card {variant} p-6 hover:scale-105 transition-all duration-200 cursor-pointer {disabled ? 'opacity-50 cursor-not-allowed' : ''}"
		{disabled}
		on:click={handleClick}
	>
		<div class="flex items-center justify-between">
			<div class="flex-1">
				<div class="flex items-center gap-3">
					{#if icon && iconPath}
						<div class="p-2 rounded-lg bg-surface-100 dark:bg-surface-800">
							<svg class="w-5 h-5 fill-current" viewBox="0 0 24 24">
								<path d="{iconPath}"/>
							</svg>
						</div>
					{/if}
					
					<div class="text-left">
						<h3 class="font-semibold text-surface-900 dark:text-surface-100">{title}</h3>
						{#if description}
							<p class="text-sm text-surface-600 dark:text-surface-400">{description}</p>
						{/if}
					</div>
				</div>
			</div>
			
			{#if badge}
				<span class="badge {badgeVariant}">{badge}</span>
			{/if}
		</div>
	</button>
{/if}
