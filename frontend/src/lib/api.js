// Utilitaire pour obtenir l'URL de l'API backend dynamiquement
export function apiUrl(path) {
  const base = import.meta.env.VITE_API_URL || '';
  if (path.startsWith('/')) return base + path;
  return base + '/' + path;
}
