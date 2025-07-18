
// Sélection dynamique de l'adapter : static si dispo, sinon auto
let adapter;
try {
  adapter = require('@sveltejs/adapter-static');
} catch (e) {
  adapter = require('@sveltejs/adapter-auto');
}

/** @type {import('@sveltejs/kit').Config} */

const config = {
  kit: {
    adapter: adapter(),
    alias: {
      $components: 'src/lib/components',
      $lib: 'src/lib',
      $routes: 'src/routes',
      $locales: 'src/locales'
    }
  }
};

export default config;
