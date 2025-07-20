<script lang="ts">
	// Pour Skeleton UI v3, nous utiliserons une approche plus simple
	// avec un système d'événements personnalisé
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

<div class="space-y-6">
	<h3 class="h3">Ajouter un Torrent</h3>
	
	<form on:submit|preventDefault={handleSubmit} class="space-y-4">
		<div>
			<label for="magnet-url" class="block text-sm font-medium mb-2">
				Lien Magnet *
			</label>
			<input
				id="magnet-url"
				type="text"
				bind:value={magnetUrl}
				placeholder="magnet:?xt=urn:btih:..."
				class="input"
				required
				disabled={isSubmitting}
			/>
			<p class="text-sm text-surface-500 mt-1">
				Collez votre lien magnet pour ajouter le torrent
			</p>
		</div>

		<div class="flex justify-end space-x-3">
			<button
				type="button"
				class="btn preset-outlined-surface"
				on:click={handleCancel}
				disabled={isSubmitting}
			>
				Annuler
			</button>
			<button
				type="submit"
				class="btn preset-filled-primary"
				disabled={!magnetUrl.trim() || isSubmitting}
			>
				{isSubmitting ? 'Ajout en cours...' : 'Ajouter'}
			</button>
		</div>
	</form>
</div>
