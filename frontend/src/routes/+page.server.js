/** @type {import('./$types').PageServerLoad} */
export async function load({ fetch }) {
	try {
		// Utiliser la variable d'environnement ou l'URL par défaut
		const apiUrl = process.env.VITE_API_URL || 'http://localhost:8080/api';
		console.log('API URL utilisée:', apiUrl);
		
		// Récupérer les torrents
		const torrentsResponse = await fetch(`${apiUrl}/torrents`);
		let torrents = [];
		
		if (torrentsResponse.ok) {
			torrents = await torrentsResponse.json();
		} else {
			console.error('Erreur lors de la récupération des torrents:', torrentsResponse.status);
		}

		// Récupérer les informations système
		const systemResponse = await fetch(`${apiUrl}/system`);
		let systemInfo = null;
		
		if (systemResponse.ok) {
			systemInfo = await systemResponse.json();
		} else {
			console.error('Erreur lors de la récupération des infos système:', systemResponse.status);
		}

		// Récupérer la queue
		const queueResponse = await fetch(`${apiUrl}/queue`);
		let queue = [];
		
		if (queueResponse.ok) {
			queue = await queueResponse.json();
		} else {
			console.error('Erreur lors de la récupération de la queue:', queueResponse.status);
		}

		return {
			torrents,
			systemInfo,
			queue
		};
	} catch (error) {
		console.error('Erreur lors du chargement des données:', error);
		
		// Retourner des données par défaut en cas d'erreur
		return {
			torrents: [],
			systemInfo: {
				cpu_usage: 0,
				memory_usage: 0,
				disk_usage: 0,
				uptime: 'N/A'
			},
			queue: []
		};
	}
}
