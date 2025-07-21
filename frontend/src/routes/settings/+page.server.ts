import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ fetch }) => {
    try {
        // Vérifier le statut d'authentification
        const response = await fetch('http://backend:8000/api/auth/status');
        
        if (!response.ok) {
            console.error('Erreur lors de la vérification du statut d\'authentification');
            return {
                authStatus: {
                    authenticated: false,
                    message: 'Erreur de connexion'
                }
            };
        }
        
        const authStatus = await response.json();
        
        return {
            authStatus
        };
    } catch (error) {
        console.error('Erreur lors du chargement des paramètres:', error);
        return {
            authStatus: {
                authenticated: false,
                message: 'Erreur de connexion'
            }
        };
    }
};
