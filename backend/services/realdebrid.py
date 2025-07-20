"""
Client API pour Real-Debrid
"""
import os
import httpx
from typing import List, Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)

class RealDebridClient:
    def __init__(self):
        self.api_token = os.getenv('REALDEBRID_API_TOKEN')
        if not self.api_token:
            raise ValueError("REALDEBRID_API_TOKEN environment variable is required")
        
        self.base_url = "https://api.real-debrid.com/rest/1.0"
        self.headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }
    
    async def get_torrents(self) -> List[Dict[str, Any]]:
        """
        Récupère la liste des torrents depuis Real-Debrid
        """
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.base_url}/torrents",
                    headers=self.headers,
                    timeout=30.0
                )
                response.raise_for_status()
                return response.json()
        except httpx.HTTPError as e:
            logger.error(f"Erreur lors de la récupération des torrents: {e}")
            raise
        except Exception as e:
            logger.error(f"Erreur inattendue: {e}")
            raise
    
    async def get_torrent_info(self, torrent_id: str) -> Dict[str, Any]:
        """
        Récupère les informations détaillées d'un torrent
        """
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.base_url}/torrents/info/{torrent_id}",
                    headers=self.headers,
                    timeout=30.0
                )
                response.raise_for_status()
                return response.json()
        except httpx.HTTPError as e:
            logger.error(f"Erreur lors de la récupération du torrent {torrent_id}: {e}")
            raise
        except Exception as e:
            logger.error(f"Erreur inattendue: {e}")
            raise
    
    async def add_torrent(self, magnet_url: str) -> Dict[str, Any]:
        """
        Ajoute un torrent via un lien magnet
        """
        try:
            async with httpx.AsyncClient() as client:
                response = await client.put(
                    f"{self.base_url}/torrents/addMagnet",
                    headers=self.headers,
                    data={"magnet": magnet_url},
                    timeout=30.0
                )
                response.raise_for_status()
                return response.json()
        except httpx.HTTPError as e:
            logger.error(f"Erreur lors de l'ajout du torrent: {e}")
            raise
        except Exception as e:
            logger.error(f"Erreur inattendue: {e}")
            raise
    
    async def delete_torrent(self, torrent_id: str) -> bool:
        """
        Supprime un torrent
        """
        try:
            async with httpx.AsyncClient() as client:
                response = await client.delete(
                    f"{self.base_url}/torrents/delete/{torrent_id}",
                    headers=self.headers,
                    timeout=30.0
                )
                response.raise_for_status()
                return True
        except httpx.HTTPError as e:
            logger.error(f"Erreur lors de la suppression du torrent {torrent_id}: {e}")
            raise
        except Exception as e:
            logger.error(f"Erreur inattendue: {e}")
            raise

# Instance globale du client
rd_client = RealDebridClient()
