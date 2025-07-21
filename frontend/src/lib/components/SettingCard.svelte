<script lang="ts">
	export let title: string;
	export let description: string = '';
	export let category: string = '';
	export let type: 'toggle' | 'input' | 'select' | 'number' | 'password' | 'textarea' = 'input';
	export let value: any = '';
	export let options: Array<{ label: string; value: any }> = [];
	export let placeholder: string = '';
	export let disabled: boolean = false;
	export let required: boolean = false;
	export let min: number | undefined = undefined;
	export let max: number | undefined = undefined;
	export let icon: string = '';

	// Mappings pour les icônes prédéfinies
	const iconPaths: Record<string, string> = {
		api: 'M12,2A10,10 0 0,1 22,12A10,10 0 0,1 12,22A10,10 0 0,1 2,12A10,10 0 0,1 12,2M12,8A4,4 0 0,0 8,12A4,4 0 0,0 12,16A4,4 0 0,0 16,12A4,4 0 0,0 12,8Z',
		download: 'M5,20H19V18H5M19,9H15V3H9V9H5L12,16L19,9Z',
		folder: 'M10,4H4C2.89,4 2,4.89 2,6V18A2,2 0 0,0 4,20H20A2,2 0 0,0 22,18V8C22,6.89 21.1,6 20,6H12L10,4Z',
		security: 'M12,12H19C18.47,16.11 15.72,19.78 12,20.92V12H5V6.3L12,3.19M12,1L3,5V11C3,16.55 6.84,21.73 12,23C17.16,21.73 21,16.55 21,11V5L12,1Z',
		notification: 'M21,19V20H3V19L5,17V11C5,7.9 7.03,5.17 10,4.29C10,4.19 10,4.1 10,4A2,2 0 0,1 12,2A2,2 0 0,1 14,4C14,4.1 14,4.19 14,4.29C16.97,5.17 19,7.9 19,11V17L21,19Z',
		theme: 'M12,18V6A6,6 0 0,1 18,12A6,6 0 0,1 12,18Z',
		storage: 'M4,2H20A2,2 0 0,1 22,4V20A2,2 0 0,1 20,22H4A2,2 0 0,1 2,20V4A2,2 0 0,1 4,2M4,6V18H20V6H4Z',
		network: 'M15,9H9V5H15M12,19A3,3 0 0,1 9,16A3,3 0 0,1 12,13A3,3 0 0,1 15,16A3,3 0 0,1 12,19M12,2L13.09,8.26L22,9L13.09,9.74L12,16L10.91,9.74L2,9L10.91,8.26L12,2Z'
	};

	$: iconPath = iconPaths[icon] || '';

	// Event dispatcher pour les changements de valeur
	import { createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();

	function handleChange(event: Event) {
		const target = event.target as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement;
		let newValue = type === 'toggle' ? (target as HTMLInputElement).checked : target.value;
		
		if (type === 'number') {
			newValue = parseFloat(newValue as string) || 0;
		}
		
		value = newValue;
		dispatch('change', { value: newValue });
	}
</script>

<div class="card p-6">
	<div class="flex items-start gap-4">
		{#if icon && iconPath}
			<div class="flex-shrink-0 mt-1">
				<div class="w-10 h-10 rounded-lg variant-soft-primary flex items-center justify-center">
					<svg class="w-5 h-5 fill-current" viewBox="0 0 24 24">
						<path d="{iconPath}"/>
					</svg>
				</div>
			</div>
		{/if}
		
		<div class="flex-1 space-y-3">
			<div>
				<div class="flex items-center gap-2 mb-1">
					<h3 class="h4 font-semibold">{title}</h3>
					{#if category}
						<span class="badge variant-soft-secondary text-xs">{category}</span>
					{/if}
					{#if required}
						<span class="text-error-500 text-sm">*</span>
					{/if}
				</div>
				{#if description}
					<p class="text-sm text-surface-600 dark:text-surface-400">{description}</p>
				{/if}
			</div>
			
			<div class="space-y-2">
				{#if type === 'toggle'}
					<label class="flex items-center space-x-2 cursor-pointer">
						<input
							type="checkbox"
							class="checkbox"
							bind:checked={value}
							{disabled}
							on:change={handleChange}
						/>
						<span class="text-sm">Activé</span>
					</label>
				{:else if type === 'select'}
					<select
						class="select"
						bind:value
						{disabled}
						{required}
						on:change={handleChange}
					>
						<option value="" disabled>Sélectionner une option...</option>
						{#each options as option}
							<option value={option.value}>{option.label}</option>
						{/each}
					</select>
				{:else if type === 'textarea'}
					<textarea
						class="textarea"
						bind:value
						{placeholder}
						{disabled}
						{required}
						rows="3"
						on:input={handleChange}
					></textarea>
				{:else if type === 'number'}
					<input
						type="number"
						class="input"
						bind:value
						{placeholder}
						{disabled}
						{required}
						{min}
						{max}
						on:input={handleChange}
					/>
				{:else if type === 'password'}
					<input
						type="password"
						class="input"
						bind:value
						{placeholder}
						{disabled}
						{required}
						on:input={handleChange}
					/>
				{:else}
					<input
						type="text"
						class="input"
						bind:value
						{placeholder}
						{disabled}
						{required}
						on:input={handleChange}
					/>
				{/if}
			</div>
		</div>
	</div>
</div>
