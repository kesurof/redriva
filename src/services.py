# Services métier pour Redriva

from utils import get_rd_token
import aiohttp
import asyncio

RD_API_URL = "https://api.real-debrid.com/rest/1.0/torrents"

async def fetch_torrents():
    """Récupère la liste des torrents via l'API Real-Debrid (token sécurisé)."""
    token = get_rd_token()
    headers = {"Authorization": f"Bearer {token}"}
    limit = 1000
    all_torrents = []
    page = 1
    async with aiohttp.ClientSession() as session:
        while True:
            params = {"page": page, "limit": limit}
            async with session.get(RD_API_URL, headers=headers, params=params) as resp:
                resp.raise_for_status()
                torrents = await resp.json()
            if not torrents:
                break
            all_torrents.extend(torrents)
            page += 1
            if page % 5 == 0:
                await asyncio.sleep(1)
    return all_torrents


# Ajout d'un torrent (magnet)
async def add_torrent_rd(magnet: str):
    token = get_rd_token()
    headers = {"Authorization": f"Bearer {token}"}
    data = {"magnet": magnet}
    async with aiohttp.ClientSession() as session:
        async with session.post(RD_API_URL, headers=headers, data=data) as resp:
            resp.raise_for_status()
            return await resp.json()

# Suppression d'un torrent
async def delete_torrent_rd(torrent_id: str):
    token = get_rd_token()
    headers = {"Authorization": f"Bearer {token}"}
    url = f"{RD_API_URL}/delete/{torrent_id}"
    async with aiohttp.ClientSession() as session:
        async with session.post(url, headers=headers) as resp:
            resp.raise_for_status()
            return await resp.json()

# Détail d'un torrent
async def get_torrent_detail_rd(torrent_id: str):
    token = get_rd_token()
    headers = {"Authorization": f"Bearer {token}"}
    url = f"{RD_API_URL}/info/{torrent_id}"
    async with aiohttp.ClientSession() as session:
        async with session.get(url, headers=headers) as resp:
            resp.raise_for_status()
            return await resp.json()
