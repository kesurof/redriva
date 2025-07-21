import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ fetch }) => {
	try {
		// Récupérer les données système depuis le backend
		const systemResponse = await fetch('http://backend:8000/api/system');
		
		if (!systemResponse.ok) {
			throw new Error(`HTTP ${systemResponse.status}: ${systemResponse.statusText}`);
		}
		
		const systemInfo = await systemResponse.json();
		
		return {
			systemInfo,
			lastUpdate: new Date().toISOString()
		};
	} catch (error) {
		console.error('Erreur lors du chargement des données système:', error);
		return {
			systemInfo: null,
			error: 'Impossible de charger les données système',
			lastUpdate: new Date().toISOString()
		};
	}
};
