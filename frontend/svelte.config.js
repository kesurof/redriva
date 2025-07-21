import adapter from '@sveltejs/adapter-static';
// Le chemin correct pour importer vitePreprocess dans notre configuration
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consultation de la documentation pour plus d'informations sur les préprocesseurs
	// https://kit.svelte.dev/docs/integrations#preprocessors
	preprocess: vitePreprocess(),

	kit: {
		adapter: adapter({
			// Configuration pour serveur statique (Nginx)
			pages: 'build',
			assets: 'build',
			fallback: 'index.html', // SPA fallback pour les routes dynamiques
			precompress: false,
			strict: true
		})
	}
};

export default config;
