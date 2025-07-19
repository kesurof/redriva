<script lang="ts">
	import { Avatar, Progress } from '@skeletonlabs/skeleton-svelte';
</script>

<div class="p-8 space-y-6">
	<h1 class="text-3xl font-bold">Test Skeleton UI v3</h1>
	
	<div class="card p-6 space-y-4">
		<h2 class="text-xl font-semibold">Composants et Utilitaires Skeleton UI v3</h2>
		
		<!-- Boutons avec les utilitaires CSS Skeleton -->
		<div class="flex gap-4">
			<button class="btn preset-filled-primary">Bouton Primaire</button>
			<button class="btn preset-outlined-secondary">Bouton Secondaire</button>
			<button class="btn preset-tonal-tertiary">Bouton Tertiaire</button>
		</div>
		
		<!-- Avatar Component -->
		<div class="flex items-center gap-4">
			<Avatar initials="SK" width="w-12" background="bg-primary-500" />
			<Avatar initials="UI" width="w-16" background="bg-secondary-500" />
		</div>
		
		<!-- Progress Component -->
		<div class="space-y-2">
			<p class="text-sm font-medium">Chargement</p>
			<Progress value={75} max={100} />
		</div>
		
		<!-- Alert avec utilitaires CSS -->
		<div class="alert preset-filled-warning">
			<div class="alert-message">
				<h3>Test d'alerte</h3>
				<p>Ceci est un test de Skeleton UI v3 avec Tailwind v4</p>
			</div>
		</div>
		
		<!-- Badges avec utilitaires CSS -->
		<div class="flex gap-2">
			<span class="badge preset-filled-success">Succès</span>
			<span class="badge preset-outlined-error">Erreur</span>
			<span class="badge preset-tonal-warning">Avertissement</span>
		</div>
		
		<!-- Cards avec utilitaires CSS -->
		<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
			<div class="card p-4">
				<h3 class="text-lg font-semibold mb-2">Carte 1</h3>
				<p class="text-sm">Utilise les utilitaires CSS de Skeleton UI v3</p>
			</div>
			<div class="card preset-tonal p-4">
				<h3 class="text-lg font-semibold mb-2">Carte 2</h3>
				<p class="text-sm">Avec le preset tonal</p>
			</div>
		</div>
	</div>
</div>