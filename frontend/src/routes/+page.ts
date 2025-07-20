// /frontend/src/routes/+page.ts
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch, depends }) => {
  // Déclarer une dépendance pour permettre l'invalidation ciblée
  depends('app:system');
  
  try {
    const response = await fetch('/api/system');
    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }
    const systemInfo = await response.json();
    return {
      systemInfo
    };
  } catch (error) {
    console.error("Impossible de charger les informations système:", error);
    return {
      systemInfo: null,
      error: "Les données système n'ont pas pu être récupérées."
    };
  }
};
