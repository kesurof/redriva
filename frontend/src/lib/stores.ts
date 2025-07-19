import { writable, derived } from 'svelte/store';
import type { Torrent, QueueItem, SystemInfo } from './api';

// Stores pour les données
export const torrents = writable<Torrent[]>([]);
export const queue = writable<QueueItem[]>([]);
export const systemInfo = writable<SystemInfo | null>(null);
export const isLoading = writable<boolean>(false);
export const error = writable<string | null>(null);

// Store pour l'UI
export const theme = writable<'light' | 'dark'>('light');
export const sidebarOpen = writable<boolean>(false);

// Store pour les filtres et recherche
export const searchQuery = writable<string>('');
export const statusFilter = writable<string>('all');
export const categoryFilter = writable<string>('all');

// Derived stores
export const filteredTorrents = derived(
	[torrents, searchQuery, statusFilter, categoryFilter],
	([$torrents, $searchQuery, $statusFilter, $categoryFilter]) => {
		let filtered = $torrents;

		// Filtrage par recherche
		if ($searchQuery) {
			const query = $searchQuery.toLowerCase();
			filtered = filtered.filter(torrent =>
				torrent.name.toLowerCase().includes(query) ||
				torrent.title.toLowerCase().includes(query)
			);
		}

		// Filtrage par statut
		if ($statusFilter !== 'all') {
			filtered = filtered.filter(torrent => torrent.status === $statusFilter);
		}

		// Filtrage par catégorie
		if ($categoryFilter !== 'all') {
			filtered = filtered.filter(torrent => torrent.category === $categoryFilter);
		}

		return filtered;
	}
);

export const activeDownloads = derived(
	torrents,
	($torrents) => $torrents.filter(t => t.status === 'downloading')
);

export const completedTorrents = derived(
	torrents,
	($torrents) => $torrents.filter(t => t.status === 'completed')
);

export const totalSize = derived(
	torrents,
	($torrents) => {
		const totalSizeInGB = $torrents.reduce((total, torrent) => {
			const sizeMatch = torrent.size.match(/([\d.]+)\s*(GB|MB|TB)/);
			if (sizeMatch) {
				const value = parseFloat(sizeMatch[1]);
				const unit = sizeMatch[2];
				switch (unit) {
					case 'TB': return total + (value * 1024);
					case 'GB': return total + value;
					case 'MB': return total + (value / 1024);
					default: return total;
				}
			}
			return total;
		}, 0);
		
		return `${totalSizeInGB.toFixed(1)} GB`;
	}
);

// Fonctions utilitaires pour mettre à jour les stores
export function setError(message: string) {
	error.set(message);
	setTimeout(() => error.set(null), 5000);
}

export function clearError() {
	error.set(null);
}

export function toggleTheme() {
	theme.update(current => current === 'light' ? 'dark' : 'light');
}

export function toggleSidebar() {
	sidebarOpen.update(current => !current);
}
