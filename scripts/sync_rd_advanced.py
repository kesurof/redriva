#!/usr/bin/env python3
"""
Script avancé de synchronisation Real-Debrid avec aiohttp et asyncio
Utilise la base de code fournie dans les instructions pour la récupération rapide
des torrents avec pagination et throttling.
"""

import asyncio
import aiohttp
import os
import sys
import sqlite3
from datetime import datetime
from pathlib import Path

# Configuration
RD_API_URL = "https://api.real-debrid.com/rest/1.0/torrents"
RD_TOKEN = os.environ.get("RD_TOKEN", "")

# Paths - ajuster pour la nouvelle structure
BACKEND_DIR = Path(__file__).parent.parent / "backend"
sys.path.insert(0, str(BACKEND_DIR))

from src.persistence import get_setting

async def fetch_page(session, page, limit):
    """Récupère une page de torrents depuis l'API Real-Debrid"""
    headers = {"Authorization": f"Bearer {RD_TOKEN}"}
    params = {"page": page, "limit": limit}
    async with session.get(RD_API_URL, headers=headers, params=params) as resp:
        resp.raise_for_status()
        return await resp.json()

async def fetch_all_torrents():
    """Récupère tous les torrents avec pagination et throttling"""
    limit = 1000
    all_torrents = []
    page = 1
    
    async with aiohttp.ClientSession() as session:
        while True:
            try:
                torrents = await fetch_page(session, page, limit)
                if not torrents:
                    break
                all_torrents.extend(torrents)
                print(f"Page {page}: {len(torrents)} torrents récupérés")
                page += 1
                
                # Throttle : pause de 1s toutes les 5 pages
                if page % 5 == 0:
                    await asyncio.sleep(1)
                    
            except Exception as e:
                print(f"Erreur sur la page {page}: {e}")
                break
                
    print(f"Total récupéré: {len(all_torrents)} torrents")
    return all_torrents

def normalize_torrent(t):
    """Normalise les données d'un torrent pour la base de données"""
    return {
        "id": t.get("id"),
        "filename": t.get("filename"),
        "status": t.get("status"),
        "size": t.get("bytes"),
        "hash": t.get("hash"),
        "host": t.get("host"),
        "progress": t.get("progress", 0),
        "seeders": t.get("seeders", 0),
        "speed": t.get("speed", 0),
        "added": t.get("added"),
        "ended": t.get("ended"),
    }

async def sync_to_database(torrents):
    """Synchronise les torrents dans la base de données SQLite"""
    db_path = BACKEND_DIR / "data" / "torrents.db"
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Créer la table si elle n'existe pas
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS rd_torrents (
            id TEXT PRIMARY KEY,
            filename TEXT,
            status TEXT,
            size INTEGER,
            hash TEXT,
            host TEXT,
            progress INTEGER,
            seeders INTEGER,
            speed INTEGER,
            added TEXT,
            ended TEXT,
            synced_at TEXT
        )
    """)
    
    # Vider la table pour une synchronisation complète
    cursor.execute("DELETE FROM rd_torrents")
    
    # Insérer les nouveaux torrents
    synced_at = datetime.now().isoformat()
    for torrent in torrents:
        normalized = normalize_torrent(torrent)
        normalized["synced_at"] = synced_at
        
        cursor.execute("""
            INSERT INTO rd_torrents (
                id, filename, status, size, hash, host,
                progress, seeders, speed, added, ended, synced_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            normalized["id"],
            normalized["filename"],
            normalized["status"],
            normalized["size"],
            normalized["hash"],
            normalized["host"],
            normalized["progress"],
            normalized["seeders"],
            normalized["speed"],
            normalized["added"],
            normalized["ended"],
            normalized["synced_at"]
        ))
    
    conn.commit()
    conn.close()
    
    print(f"✓ {len(torrents)} torrents synchronisés dans la base de données")

async def get_token_from_config():
    """Récupère le token depuis la configuration de l'application"""
    try:
        token = await get_setting("client_id")  # Changé de RD_API_TOKEN vers client_id
        if token:
            return token
        else:
            print("❌ Aucun client_id configuré dans l'application")
            return None
    except Exception as e:
        print(f"❌ Erreur lors de la récupération du token: {e}")
        return None

async def main():
    """Fonction principale de synchronisation"""
    print("🔄 Démarrage de la synchronisation Real-Debrid...")
    
    # Récupérer le token
    global RD_TOKEN
    if not RD_TOKEN:
        RD_TOKEN = await get_token_from_config()
        
    if not RD_TOKEN:
        print("❌ Token Real-Debrid manquant. Configurez RD_TOKEN ou utilisez l'interface web.")
        print("💡 Pour tester, définissez RD_TOKEN dans l'environnement:")
        print("   export RD_TOKEN='votre_token_ici'")
        print("   python scripts/sync_rd_advanced.py")
        sys.exit(1)
    
    try:
        # Récupérer tous les torrents
        print("📥 Récupération des torrents depuis Real-Debrid...")
        torrents = await fetch_all_torrents()
        
        if not torrents:
            print("ℹ️ Aucun torrent trouvé sur le compte Real-Debrid")
            return
        
        # Normaliser les données
        normalized_torrents = [normalize_torrent(t) for t in torrents]
        print(f"✓ {len(normalized_torrents)} torrents normalisés")
        
        # Synchroniser avec la base de données
        print("💾 Synchronisation avec la base de données...")
        await sync_to_database(torrents)
        
        # Afficher un résumé
        print("\n📊 Résumé de la synchronisation:")
        status_counts = {}
        for t in normalized_torrents:
            status = t["status"]
            status_counts[status] = status_counts.get(status, 0) + 1
        
        for status, count in status_counts.items():
            print(f"  - {status}: {count}")
        
        print(f"\n✅ Synchronisation terminée avec succès!")
        
    except Exception as e:
        print(f"❌ Erreur pendant la synchronisation: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
