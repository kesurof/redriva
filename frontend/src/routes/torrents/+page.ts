// /frontend/src/routes/torrents/+page.ts
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch }) => {
  try {
    const response = await fetch('/api/torrents');
    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }
    const torrents = await response.json();
    return {
      torrents
    };
  } catch (error) {
    console.error("Impossible de charger la liste des torrents:", error);
    return {
      torrents: [],
      error: "La liste des torrents n'a pas pu être récupérée."
    };
  }
};
