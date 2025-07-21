<script lang="ts">
	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	let magnetUrl = '';
	let isSubmitting = false;

	async function handleSubmit() {
		if (!magnetUrl.trim()) return;

		isSubmitting = true;
		
		try {
			const response = await fetch('/api/torrents', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					magnet_url: magnetUrl.trim()
				})
			});

			if (response.ok) {
				const newTorrent = await response.json();
				// Dispatcher le nouveau torrent et fermer la modale
				dispatch('torrentAdded', newTorrent);
			} else {
				console.error('Erreur lors de l\'ajout du torrent:', response.status);
			}
		} catch (error) {
			console.error('Erreur réseau lors de l\'ajout:', error);
		} finally {
			isSubmitting = false;
		}
	}

	function handleCancel() {
		dispatch('cancel');
	}
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
	<div class="space-y-3">
		<label class="label">
			<span class="font-medium">Lien Magnet *</span>
			<input
				type="text"
				bind:value={magnetUrl}
				placeholder="magnet:?xt=urn:btih:..."
				class="input"
				required
				disabled={isSubmitting}
			/>
		</label>
		<p class="text-sm text-surface-500">
			Collez votre lien magnet pour ajouter le torrent à Real-Debrid
		</p>
	</div>

	<div class="flex justify-end space-x-3">
		<button
			type="button"
			class="btn variant-ghost-surface"
			on:click={handleCancel}
			disabled={isSubmitting}
		>
			<span>Annuler</span>
		</button>
		<button
			type="submit"
			class="btn variant-filled-primary"
			disabled={!magnetUrl.trim() || isSubmitting}
		>
			{#if isSubmitting}
				<div class="animate-spin w-4 h-4 mr-2">
					<svg fill="currentColor" viewBox="0 0 24 24">
						<path d="M12,4V2A10,10 0 0,0 2,12H4A8,8 0 0,1 12,4Z"/>
					</svg>
				</div>
				<span>Ajout en cours...</span>
			{:else}
				<svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
					<path d="M19,13H13V19H11V13H5V11H11V5H13V11H19V13Z"/>
				</svg>
				<span>Ajouter</span>
			{/if}
		</button>
	</div>
</form>
