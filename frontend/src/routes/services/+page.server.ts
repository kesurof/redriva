import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ fetch }) => {
	try {
		// Récupérer les services depuis l'API backend
		const servicesResponse = await fetch('http://backend:8000/api/services');
		
		if (!servicesResponse.ok) {
			console.error('Erreur lors de la récupération des services:', servicesResponse.status);
			// Retourner des données par défaut en cas d'erreur
			return {
				services: [],
				error: 'Impossible de charger les services depuis l\'API',
				lastUpdate: new Date().toISOString()
			};
		}
		
		const services = await servicesResponse.json();
		
		return {
			services,
			lastUpdate: new Date().toISOString()
		};
	} catch (error) {
		console.error('Erreur lors de la connexion à l\'API des services:', error);
		// Retourner des données par défaut en cas d'erreur
		return {
			services: [],
			error: 'Impossible de se connecter à l\'API backend',
			lastUpdate: new Date().toISOString()
		};
	}
};
