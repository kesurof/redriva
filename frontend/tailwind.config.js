const { skeleton } = require('@skeletonlabs/skeleton/plugin');
const forms = require('@tailwindcss/forms');
const path = require('path');

/** @type {import('tailwindcss').Config} */
module.exports = {
	darkMode: 'class',
	content: [
		'./src/**/*.{html,js,svelte,ts}',
		// Chemin standard pour inclure les fichiers du plugin Skeleton en v2/v3
		path.join(require.resolve('@skeletonlabs/skeleton'), '../**/*.{html,js,svelte,ts}')
	],
	theme: {
		extend: {},
	},
	plugins: [
		forms,
		skeleton({
			themes: {
				preset: [ "skeleton", "wintry", "modern" ]
			}
		})
	],
};
