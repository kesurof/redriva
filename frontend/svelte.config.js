import adapter from '@sveltejs/adapter-node';
// Le chemin correct pour importer vitePreprocess dans notre configuration
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consultation de la documentation pour plus d'informations sur les préprocesseurs
	// https://kit.svelte.dev/docs/integrations#preprocessors
	preprocess: vitePreprocess(),

	kit: {
		adapter: adapter({
			// Configuration pour serveur Node.js
			out: 'build'
		})
	}
};

export default config;
