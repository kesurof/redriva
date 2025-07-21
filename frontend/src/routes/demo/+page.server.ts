import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
	// Simuler des données pour la démonstration des composants
	return {
		message: 'Aperçu de tous les composants Redriva',
		timestamp: new Date().toISOString()
	};
};
