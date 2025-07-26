"""
Client API pour Real-Debrid - Intégration basée sur RDM avec système de cache
Patterns RDM : pagination infinie, throttling intelligent, session persistante
"""
import os
import aiohttp
import asyncio
from typing import List, Dict, Any, Optional
import logging
from database.auth_db import auth_db
from database.torrents_cache import TorrentsCache

logger = logging.getLogger(__name__)

class RealDebridClient:
    def __init__(self, token: str):
        self.static_token = token  # Token personnel de l'utilisateur
        self.base_url = "https://api.real-debrid.com/rest/1.0"
        
        # Limites de pagination RDM améliorées
        self.max_limit_per_request = 1000  # Real-Debrid limite par requête
        self.max_total_limit = None        # Pagination infinie comme RDM
        
        # Session persistante aiohttp (pattern RDM)
        self.session: Optional[aiohttp.ClientSession] = None
        self.throttle_counter = 0  # Compteur pour throttling intelligent
        
        # Initialisation du système de cache
        self.cache = TorrentsCache()
    
    async def _get_session(self) -> aiohttp.ClientSession:
        """Initialise et retourne la session aiohttp persistante (pattern RDM)"""
        if self.session is None or self.session.closed:
            timeout = aiohttp.ClientTimeout(total=30.0)
            self.session = aiohttp.ClientSession(
                timeout=timeout,
                headers={
                    "User-Agent": "Redriva/1.0.0",
                    "Accept": "application/json"
                }
            )
        return self.session
    
    async def close(self):
        """Ferme proprement la session aiohttp"""
        if self.session and not self.session.closed:
            await self.session.close()
    
    async def get_headers(self) -> Dict[str, str]:
        """Obtient les headers d'authentification avec User-Agent RDM-style"""
        # Priorité au token dynamique stocké en base
        token = await auth_db.get_access_token()
        
        # Fallback sur le token statique s'il n'y en a pas en base
        if not token and self.static_token:
            token = self.static_token
            
        if not token:
            raise ValueError("Aucun token d'authentification disponible. Veuillez vous authentifier.")
        
        return {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "User-Agent": "Redriva/1.0"  # User-Agent personnalisé comme RDM
        }
    
    async def _fetch_page_rdm(self, page: int, limit: int) -> List[Dict[str, Any]]:
        """
        Récupère une page de torrents avec pattern RDM (throttling + session persistante)
        """
        # Throttling intelligent RDM : pause toutes les 5 requêtes
        if self.throttle_counter % 5 == 0 and self.throttle_counter > 0:
            logger.info(f"Throttling API : pause de 1s après {self.throttle_counter} requêtes")
            await asyncio.sleep(1)
        
        try:
            headers = await self.get_headers()
            session = await self._get_session()
            
            params = {
                "limit": limit,
                "page": page
            }
            
            async with session.get(
                f"{self.base_url}/torrents",
                headers=headers,
                params=params
            ) as response:
                response.raise_for_status()
                data = await response.json()
                
                self.throttle_counter += 1
                
                logger.info(f"Page {page} récupérée: {len(data) if data else 0} torrents")
                return data if data else []
                
        except Exception as e:
            logger.error(f"Erreur lors de la récupération de la page {page}: {e}")
            return []

    async def get_all_torrents_rdm(self) -> List[Dict[str, Any]]:
        """
        Récupération complète avec pagination infinie (pattern RDM)
        """
        all_torrents = []
        page = 1
        limit = self.max_limit_per_request
        
        logger.info("Début de la récupération complète des torrents (pattern RDM)")
        
        while True:
            torrents_batch = await self._fetch_page_rdm(page, limit)
            
            # Si pas de résultats, on arrête la pagination
            if not torrents_batch:
                logger.info(f"Pagination terminée à la page {page} (aucun résultat)")
                break
            
            all_torrents.extend(torrents_batch)
            
            # Si on a récupéré moins que demandé, il n'y a plus de données
            if len(torrents_batch) < limit:
                logger.info(f"Pagination terminée à la page {page} (dernière page incomplète)")
                break
            
            page += 1
            
            # Sécurité : éviter les boucles infinies
            if page > 1000:  # Limite raisonnable
                logger.warning("Limite de sécurité atteinte (1000 pages)")
                break
        
        logger.info(f"Récupération complète terminée: {len(all_torrents)} torrents sur {page-1} pages")
        return all_torrents
    
    async def get_torrents(self, limit: int = 25, use_cache: bool = True) -> List[Dict[str, Any]]:
        """
        Récupère la liste des torrents avec cache intelligent
        - use_cache: Si True, utilise le cache en priorité et ne fait l'appel API qu'en cas de cache vide/expiré
        """
        # Si le cache est demandé et valide, le retourner
        if use_cache and self.cache.is_cache_valid():
            cached_torrents = self.cache.get_torrents()
            if cached_torrents:
                logger.info(f"Retour de {len(cached_torrents)} torrents depuis le cache")
                return cached_torrents[:limit] if limit else cached_torrents
        
        # Sinon, utiliser le pattern RDM pour récupération complète
        fresh_torrents = await self.get_all_torrents_rdm()
        
        # Sauvegarder en cache pour 6 heures
        if fresh_torrents:
            self.cache.set_torrents(fresh_torrents, ttl_hours=6)
            logger.info(f"Sauvegarde de {len(fresh_torrents)} torrents en cache")
        
        # Retourner la limite demandée
        return fresh_torrents[:limit] if limit else fresh_torrents
    
    async def refresh_torrents_cache(self, limit: int = None) -> List[Dict[str, Any]]:
        """
        Force le rafraîchissement du cache avec récupération complète RDM
        """
        logger.info("Rafraîchissement forcé du cache des torrents (pattern RDM)")
        fresh_torrents = await self.get_all_torrents_rdm()
        
        if fresh_torrents:
            self.cache.set_torrents(fresh_torrents, ttl_hours=6)
            logger.info(f"Cache rafraîchi avec {len(fresh_torrents)} torrents")
        
        return fresh_torrents[:limit] if limit else fresh_torrents
    
    def get_cache_info(self) -> Dict[str, Any]:
        """
        Retourne les informations sur le cache
        """
        return self.cache.get_cache_info()
    
    def clear_cache(self):
        """
        Vide le cache des torrents
        """
        self.cache.clear_cache()
        logger.info("Cache des torrents vidé")
    
    async def get_torrent_info(self, torrent_id: str) -> Dict[str, Any]:
        """
        Récupère les informations détaillées d'un torrent avec session persistante
        """
        try:
            headers = await self.get_headers()
            session = await self._get_session()
            
            async with session.get(
                f"{self.base_url}/torrents/info/{torrent_id}",
                headers=headers
            ) as response:
                response.raise_for_status()
                return await response.json()
                
        except Exception as e:
            logger.error(f"Erreur lors de la récupération des informations du torrent: {e}")
            raise

    async def add_torrent(self, magnet_url: str) -> Dict[str, Any]:
        """
        Ajoute un torrent à Real-Debrid via une URL magnet avec session persistante
        """
        try:
            headers = await self.get_headers()
            session = await self._get_session()
            
            data = {"magnet": magnet_url}
            
            async with session.post(
                f"{self.base_url}/torrents/addMagnet",
                headers=headers,
                data=data
            ) as response:
                response.raise_for_status()
                return await response.json()
                
        except Exception as e:
            logger.error(f"Erreur lors de l'ajout du torrent: {e}")
            raise
    
    async def delete_torrent(self, torrent_id: str) -> bool:
        """
        Supprime un torrent de Real-Debrid
        """
        try:
            headers = await self.get_headers()
            async with httpx.AsyncClient() as client:
                response = await client.delete(
                    f"{self.base_url}/torrents/delete/{torrent_id}",
                    headers=headers,
                    timeout=30.0
                )
                return response.status_code == 204
        except httpx.HTTPError as e:
            logger.error(f"Erreur lors de la suppression du torrent: {e}")
            raise
        except Exception as e:
            logger.error(f"Erreur inattendue: {e}")
            raise

# Instance globale du client - sera initialisée avec un token lors de l'utilisation
rd_client = None

def get_rd_client() -> RealDebridClient:
    """Obtient une instance du client Real-Debrid avec le token approprié"""
    import os
    token = os.getenv('REALDEBRID_API_TOKEN')
    if not token:
        raise ValueError("Token Real-Debrid non configuré dans les variables d'environnement")
    return RealDebridClient(token)
