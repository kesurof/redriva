import adapter from '@sveltejs/adapter-static';

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
