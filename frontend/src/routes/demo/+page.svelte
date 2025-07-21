<script lang="ts">
	import type { PageData } from './$types';
	import { 
		StatCard, 
		QuickAction, 
		ActivityFeed, 
		ServiceCard, 
		SettingCard,
		LoadingSpinner 
	} from '$lib';

	export let data: PageData;

	// Données d'exemple pour tous les composants
	const exampleActivities = [
		{
			id: '1',
			type: 'download' as const,
			title: 'Exemple de téléchargement',
			description: 'Fichier téléchargé avec succès',
			timestamp: new Date(Date.now() - 300000).toISOString(),
			status: 'Terminé'
		},
		{
			id: '2',
			type: 'warning' as const,
			title: 'Avertissement système',
			description: 'Espace disque faible',
			timestamp: new Date(Date.now() - 600000).toISOString()
		}
	];

	let settingValue = 'example';
	let toggleValue = true;
	let numberValue = 100;
	let isLoading = false;

	function handleSettingChange(event: CustomEvent) {
		console.log('Setting changed:', event.detail.value);
	}

	function simulateLoading() {
		isLoading = true;
		setTimeout(() => {
			isLoading = false;
		}, 3000);
	}
</script>

<div class="space-y-8">
	<div class="text-center">
		<h1 class="h1">Aperçu des Composants</h1>
		<p class="text-surface-600 dark:text-surface-400">
			Démonstration de tous les composants disponibles dans Redriva
		</p>
	</div>

	<!-- Section StatCard -->
	<section>
		<h2 class="h2 mb-4">StatCard - Cartes de Statistiques</h2>
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
			<StatCard
				title="Téléchargements"
				value="1.2 To"
				icon="download"
				variant="variant-soft-primary"
				trend="up"
				trendValue="+15%"
				subtitle="ce mois"
			/>
			<StatCard
				title="CPU Usage"
				value="45%"
				icon="cpu"
				variant="variant-soft-success"
				progress={45}
				trend="stable"
			/>
			<StatCard
				title="Erreurs"
				value="3"
				icon="system"
				variant="variant-soft-error"
				trend="down"
				trendValue="-2"
				size="sm"
			/>
			<StatCard
				title="Services"
				value="12/15"
				icon="monitor"
				variant="variant-soft-warning"
				subtitle="en ligne"
				size="lg"
			/>
		</div>
	</section>

	<!-- Section QuickAction -->
	<section>
		<h2 class="h2 mb-4">QuickAction - Actions Rapides</h2>
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
			<QuickAction
				title="Nouveau Torrent"
				description="Ajouter un fichier torrent"
				icon="add"
				href="/torrents"
				variant="variant-soft-primary"
			/>
			<QuickAction
				title="Paramètres"
				description="Configuration avancée"
				icon="settings"
				disabled={false}
				variant="variant-soft-secondary"
			/>
			<QuickAction
				title="Actualiser"
				description="Recharger les données"
				icon="refresh"
				badge="Nouveau"
				badgeVariant="variant-filled-success"
				variant="variant-soft-tertiary"
			/>
		</div>
	</section>

	<!-- Section ServiceCard -->
	<section>
		<h2 class="h2 mb-4">ServiceCard - Cartes de Services</h2>
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
			<ServiceCard
				name="Real-Debrid"
				description="Service de téléchargement premium"
				status="online"
				url="https://real-debrid.com"
				version="API v2"
				lastCheck={new Date(Date.now() - 120000).toISOString()}
				responseTime={145}
			/>
			<ServiceCard
				name="Plex Server"
				description="Serveur média local"
				status="warning"
				url="http://localhost:32400"
				version="1.32.5"
				lastCheck={new Date(Date.now() - 300000).toISOString()}
				responseTime={1250}
			/>
			<ServiceCard
				name="Service Hors Ligne"
				description="Service indisponible"
				status="offline"
				version="1.0.0"
				lastCheck={new Date(Date.now() - 900000).toISOString()}
			/>
		</div>
	</section>

	<!-- Section SettingCard -->
	<section>
		<h2 class="h2 mb-4">SettingCard - Paramètres</h2>
		<div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
			<SettingCard
				title="Token API"
				description="Clé d'authentification pour l'API Real-Debrid"
				category="Sécurité"
				type="password"
				bind:value={settingValue}
				placeholder="Entrez votre token API"
				icon="api"
				required={true}
				on:change={handleSettingChange}
			/>
			<SettingCard
				title="Téléchargements automatiques"
				description="Activer le téléchargement automatique des torrents"
				category="Automatisation"
				type="toggle"
				bind:value={toggleValue}
				icon="download"
				on:change={handleSettingChange}
			/>
			<SettingCard
				title="Limite de bande passante"
				description="Limite de téléchargement en Mo/s"
				category="Réseau"
				type="number"
				bind:value={numberValue}
				min={1}
				max={1000}
				icon="network"
				on:change={handleSettingChange}
			/>
			<SettingCard
				title="Dossier de téléchargement"
				description="Répertoire de destination pour les fichiers"
				category="Stockage"
				type="input"
				value="/downloads"
				placeholder="/path/to/downloads"
				icon="folder"
				on:change={handleSettingChange}
			/>
		</div>
	</section>

	<!-- Section LoadingSpinner -->
	<section>
		<h2 class="h2 mb-4">LoadingSpinner - Indicateurs de Chargement</h2>
		<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
			<div class="card p-6 text-center">
				<h3 class="h4 mb-4">Petit (sm)</h3>
				<LoadingSpinner size="sm" message="Chargement..." />
			</div>
			<div class="card p-6 text-center">
				<h3 class="h4 mb-4">Moyen (md)</h3>
				<LoadingSpinner size="md" message="Traitement..." />
			</div>
			<div class="card p-6 text-center">
				<h3 class="h4 mb-4">Grand (lg)</h3>
				<LoadingSpinner size="lg" message="Synchronisation..." />
			</div>
		</div>
		
		<div class="mt-6 text-center">
			<button 
				class="btn variant-filled-primary"
				on:click={simulateLoading}
				disabled={isLoading}
			>
				{isLoading ? 'Chargement...' : 'Simuler Overlay de Chargement'}
			</button>
		</div>
		
		{#if isLoading}
			<LoadingSpinner 
				overlay={true} 
				size="lg" 
				message="Simulation d'un processus long..." 
			/>
		{/if}
	</section>

	<!-- Section ActivityFeed -->
	<section>
		<h2 class="h2 mb-4">ActivityFeed - Flux d'Activités</h2>
		<div class="max-w-2xl">
			<ActivityFeed activities={exampleActivities} />
		</div>
	</section>
</div>
