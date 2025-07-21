<script lang="ts">
	export let title: string;
	export let value: string | number;
	export let subtitle: string = '';
	export let icon: string = '';
	export let variant: string = 'variant-soft-primary';
	export let trend: 'up' | 'down' | 'neutral' | undefined = undefined;
	export let trendValue: string = '';
	export let progress: number | undefined = undefined;
	export let size: 'sm' | 'md' | 'lg' = 'md';

	// Mappings pour les icônes prédéfinies
	const iconPaths: Record<string, string> = {
		cpu: 'M12,2A10,10 0 0,1 22,12A10,10 0 0,1 12,22A10,10 0 0,1 2,12A10,10 0 0,1 12,2M12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20A8,8 0 0,0 20,12A8,8 0 0,0 12,4M12,6A6,6 0 0,1 18,12A6,6 0 0,1 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6Z',
		memory: 'M8,17V15H16V17M16,10H13V7H11V10H8L12,14M19,3H5C3.89,3 3,3.89 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5C21,3.89 20.1,3 19,3Z',
		storage: 'M4,2H20A2,2 0 0,1 22,4V20A2,2 0 0,1 20,22H4A2,2 0 0,1 2,20V4A2,2 0 0,1 4,2M4,6V18H20V6H4Z',
		system: 'M12,15.5A3.5,3.5 0 0,1 8.5,12A3.5,3.5 0 0,1 12,8.5A3.5,3.5 0 0,1 15.5,12A3.5,3.5 0 0,1 12,15.5M19.43,12.97C19.47,12.65 19.5,12.33 19.5,12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.66 15.5,5.32 14.87,5.07L14.5,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.5,2.42L9.13,5.07C8.5,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,5.27L2.34,8.73C2.22,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.22,15.05 2.34,15.27L4.34,18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.5,18.68 9.13,18.93L9.5,21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.5,21.58L14.87,18.93C15.5,18.68 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z',
		download: 'M5,20H19V18H5M19,9H15V3H9V9H5L12,16L19,9Z',
		queue: 'M3,5H9V11H3V5M5,7V9H7V7H5M11,7H21V9H11V7M11,15H21V17H11V15M5,20L1.5,16.5L2.91,15.09L5,17.17L9.59,12.59L11,14L5,20Z',
		data: 'M8,17V15H16V17M16,10H13V7H11V10H8L12,14M19,3H5C3.89,3 3,3.89 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5C21,3.89 20.1,3 19,3Z'
	};

	// Variantes pour différents types
	function getVariantClass(variant: string): string {
		const variants: Record<string, string> = {
			primary: 'variant-soft-primary',
			secondary: 'variant-soft-secondary',
			tertiary: 'variant-soft-tertiary',
			success: 'variant-soft-success',
			warning: 'variant-soft-warning',
			error: 'variant-soft-error'
		};
		return variants[variant] || variant;
	}

	// Classes de taille
	function getSizeClasses() {
		switch (size) {
			case 'sm':
				return {
					card: 'card',
					padding: 'p-4',
					title: 'text-xs',
					value: 'text-lg',
					icon: 'w-4 h-4'
				};
			case 'lg':
				return {
					card: 'card',
					padding: 'p-8',
					title: 'text-base',
					value: 'text-3xl',
					icon: 'w-8 h-8'
				};
			default:
				return {
					card: 'card',
					padding: 'p-6',
					title: 'text-sm',
					value: 'text-2xl',
					icon: 'w-6 h-6'
				};
		}
	}

	$: sizeClasses = getSizeClasses();
	$: iconPath = iconPaths[icon] || '';
</script>

<div class="card {getVariantClass(variant)} {sizeClasses.padding}">
	<div class="flex items-center justify-between">
		<div class="flex-1">
			<h3 class="text-surface-500 uppercase tracking-wide {sizeClasses.title}">{title}</h3>
			<div class="flex items-baseline gap-2 mt-1">
				<span class="font-bold text-surface-900-50 {sizeClasses.value}">{value}</span>
				
				{#if subtitle}
					<span class="text-xs text-surface-500">{subtitle}</span>
				{/if}
				
				{#if trend && trendValue}
					<span class="text-xs flex items-center gap-1 {trend === 'up' ? 'text-success-500' : trend === 'down' ? 'text-error-500' : 'text-surface-500'}">
						{#if trend === 'up'}
							<svg class="w-3 h-3 fill-current" viewBox="0 0 24 24">
								<path d="M13,20H11V8L5.5,13.5L4.08,12.08L12,4.16L19.92,12.08L18.5,13.5L13,8V20Z"/>
							</svg>
						{:else if trend === 'down'}
							<svg class="w-3 h-3 fill-current" viewBox="0 0 24 24">
								<path d="M11,4H13V16L18.5,10.5L19.92,11.92L12,19.84L4.08,11.92L5.5,10.5L11,16V4Z"/>
							</svg>
						{/if}
						{trendValue}
					</span>
				{/if}
			</div>
			
			{#if progress !== undefined}
				<div class="mt-3">
					<div class="w-full bg-surface-300 rounded-full h-2">
						<div 
							class="h-2 rounded-full transition-all duration-300 bg-primary-500" 
							style="width: {Math.min(Math.max(progress, 0), 100)}%"
						></div>
					</div>
					<span class="text-xs text-surface-500 mt-1">{progress}%</span>
				</div>
			{/if}
		</div>
		
		{#if icon && iconPath}
			<div class="flex-shrink-0 ml-4">
				<div class="p-3 rounded-lg {getVariantClass(variant)}">
					<svg class="{sizeClasses.icon} fill-current" viewBox="0 0 24 24">
						<path d="{iconPath}"/>
					</svg>
				</div>
			</div>
		{/if}
	</div>
</div>
