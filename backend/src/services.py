# Services métier pour Redriva

import httpx
import aiohttp
import asyncio
from fastapi.responses import RedirectResponse
from .persistence import get_setting

RD_API_URL = "https://api.real-debrid.com/rest/1.0/torrents"

async def get_api_client():
    """Récupère le client HTTP pré-configuré pour l'API Real-Debrid."""
    api_token = await get_setting("RD_API_TOKEN")
    
    if not api_token:
        return RedirectResponse(url="/setup", status_code=303)
    
    return httpx.AsyncClient(headers={"Authorization": f"Bearer {api_token}"})

async def fetch_torrents():
    """Récupère la liste des torrents via l'API Real-Debrid (token sécurisé)."""
    client = await get_api_client()
    if isinstance(client, RedirectResponse):
        return client
    
    limit = 1000
    all_torrents = []
    page = 1
    
    try:
        while True:
            params = {"page": page, "limit": limit}
            response = await client.get(RD_API_URL, params=params)
            response.raise_for_status()
            torrents = response.json()
            
            if not torrents:
                break
            all_torrents.extend(torrents)
            page += 1
            if page % 5 == 0:
                await asyncio.sleep(1)
        return all_torrents
    finally:
        await client.aclose()


# Ajout d'un torrent (magnet)
async def add_torrent_rd(magnet: str):
    client = await get_api_client()
    if isinstance(client, RedirectResponse):
        return client
    
    try:
        data = {"magnet": magnet}
        response = await client.post(RD_API_URL, data=data)
        response.raise_for_status()
        return response.json()
    finally:
        await client.aclose()

# Suppression d'un torrent
async def delete_torrent_rd(torrent_id: str):
    client = await get_api_client()
    if isinstance(client, RedirectResponse):
        return client
    
    try:
        url = f"{RD_API_URL}/delete/{torrent_id}"
        response = await client.post(url)
        response.raise_for_status()
        return response.json()
    finally:
        await client.aclose()

# Détail d'un torrent
async def get_torrent_detail_rd(torrent_id: str):
    client = await get_api_client()
    if isinstance(client, RedirectResponse):
        return client
    
    try:
        url = f"{RD_API_URL}/info/{torrent_id}"
        response = await client.get(url)
        response.raise_for_status()
        return response.json()
    finally:
        await client.aclose()
