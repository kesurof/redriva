import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ fetch }) => {
	try {
		// Récupérer les torrents depuis le backend
		const torrentsResponse = await fetch('http://backend:8000/api/torrents');
		
		if (!torrentsResponse.ok) {
			throw new Error(`HTTP ${torrentsResponse.status}: ${torrentsResponse.statusText}`);
		}
		
		const torrents = await torrentsResponse.json();
		
		return {
			torrents,
			lastUpdate: new Date().toISOString()
		};
	} catch (error) {
		console.error('Erreur lors du chargement des torrents:', error);
		return {
			torrents: [],
			error: 'Impossible de charger la liste des torrents',
			lastUpdate: new Date().toISOString()
		};
	}
};
