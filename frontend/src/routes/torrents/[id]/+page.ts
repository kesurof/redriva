// /frontend/src/routes/torrents/[id]/+page.ts
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch, params }) => {
  try {
    const response = await fetch(`/api/torrents/${params.id}`);
    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }
    const torrent = await response.json();
    return {
      torrent
    };
  } catch (error) {
    console.error("Impossible de charger les détails du torrent:", error);
    return {
      torrent: null,
      error: "Les détails du torrent n'ont pas pu être récupérés."
    };
  }
};
