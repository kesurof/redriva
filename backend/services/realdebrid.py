"""
Client API pour Real-Debrid
"""
import os
import httpx
from typing import List, Dict, Any, Optional
import logging
from database.auth_db import auth_db

logger = logging.getLogger(__name__)

class RealDebridClient:
    def __init__(self):
        # Pour la compatibilité descendante, on garde la possibilité d'utiliser un token statique
        self.static_token = os.getenv('REALDEBRID_API_TOKEN')
        self.base_url = "https://api.real-debrid.com/rest/1.0"
        self.oauth_url = "https://api.real-debrid.com/oauth/v2"
    
    async def get_headers(self) -> Dict[str, str]:
        """Obtient les headers d'authentification"""
        # Priorité au token dynamique stocké en base
        token = await auth_db.get_access_token()
        
        # Fallback sur le token statique s'il n'y en a pas en base
        if not token and self.static_token:
            token = self.static_token
            
        if not token:
            raise ValueError("Aucun token d'authentification disponible. Veuillez vous authentifier.")
        
        return {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
    
    async def get_device_code(self) -> Dict[str, Any]:
        """Initie le flux OAuth Device Flow"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.oauth_url}/device/code",
                    params={
                        "client_id": "X245A4XAIBGVM",  # Client ID public de Real-Debrid
                        "new_credentials": "yes"
                    },
                    timeout=30.0
                )
                response.raise_for_status()
                return response.json()
        except httpx.HTTPError as e:
            logger.error(f"Erreur lors de l'obtention du device code: {e}")
            raise
    
    async def check_device_authorization(self, device_code: str) -> Dict[str, Any]:
        """Vérifie l'état de l'autorisation du device"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.oauth_url}/device/credentials",
                    params={
                        "client_id": "X245A4XAIBGVM",
                        "code": device_code
                    },
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    return {"status": "success", "data": response.json()}
                elif response.status_code == 403:
                    return {"status": "pending", "message": "En attente de l'autorisation utilisateur"}
                else:
                    response.raise_for_status()
                    
        except httpx.HTTPError as e:
            logger.error(f"Erreur lors de la vérification du device: {e}")
            raise
    
    async def get_torrents(self) -> List[Dict[str, Any]]:
        """
        Récupère la liste des torrents depuis Real-Debrid
        """
        try:
            headers = await self.get_headers()
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.base_url}/torrents",
                    headers=headers,
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
            headers = await self.get_headers()
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.base_url}/torrents/info/{torrent_id}",
                    headers=headers,
                    timeout=30.0
                )
                response.raise_for_status()
                return response.json()
        except httpx.HTTPError as e:
            logger.error(f"Erreur lors de la récupération des informations du torrent: {e}")
            raise
        except Exception as e:
            logger.error(f"Erreur inattendue: {e}")
            raise
    
    async def add_torrent(self, magnet_url: str) -> Dict[str, Any]:
        """
        Ajoute un torrent à Real-Debrid via une URL magnet
        """
        try:
            headers = await self.get_headers()
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/torrents/addMagnet",
                    headers=headers,
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

# Instance globale du client
rd_client = RealDebridClient()
