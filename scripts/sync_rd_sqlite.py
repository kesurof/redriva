#!/usr/bin/env python3
"""
Script de synchronisation complète Real-Debrid → SQLite pour Redriva
- Récupère tous les torrents via l’API RD (pagination, throttle)
- Insère ou met à jour chaque torrent dans la base locale
- Récupère les détails de chaque torrent (batch asynchrone, gestion quota)
- Logs structurés dans logs/
"""
import os
import sys
import asyncio
import logging
from datetime import datetime
from src.services import fetch_torrents, get_torrent_detail_rd
from src.persistence import save_torrents
from src.utils import get_rd_token
import sqlite3

LOG_PATH = os.path.join("logs", "sync_rd_sqlite.log")
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    handlers=[logging.FileHandler(LOG_PATH), logging.StreamHandler()]
)

DB_PATH = os.path.join("data", "redriva.db")

async def fetch_and_save_all():
    logging.info("Démarrage de la synchronisation Real-Debrid → SQLite...")
    try:
        torrents = await fetch_torrents()
        logging.info(f"{len(torrents)} torrents récupérés depuis l’API RD.")
        save_torrents(torrents)
        logging.info("Torrents insérés/mis à jour dans la base locale.")
        # Récupération des détails (optionnel, batch)
        ids = [t.get("id") for t in torrents if t.get("id")]
        details = await fetch_all_details(ids)
        logging.info(f"Détails récupérés pour {len(details)} torrents.")
    except Exception as e:
        logging.error(f"Erreur lors de la synchronisation : {e}")
        sys.exit(1)
    logging.info("Synchronisation terminée.")

async def fetch_all_details(ids, max_concurrent=30):
    semaphore = asyncio.Semaphore(max_concurrent)
    results = []
    async def fetch_one(tid):
        async with semaphore:
            try:
                detail = await get_torrent_detail_rd(tid)
                # Optionnel : insérer dans la base ici
                return detail
            except Exception as e:
                logging.warning(f"Erreur détail {tid}: {e}")
                return None
    tasks = [fetch_one(tid) for tid in ids]
    for i in range(0, len(tasks), 200):
        batch = tasks[i:i+200]
        batch_results = await asyncio.gather(*batch)
        results.extend([r for r in batch_results if r])
        if i + 200 < len(tasks):
            logging.info("Pause 60s pour respecter le quota API...")
            await asyncio.sleep(60)
    return results

def main():
    if not os.path.exists("logs"): os.makedirs("logs")
    if not os.path.exists("data"): os.makedirs("data")
    try:
        get_rd_token()  # Vérifie la présence du token
    except Exception as e:
        logging.error(str(e))
        sys.exit(1)
    asyncio.run(fetch_and_save_all())

if __name__ == "__main__":
    main()
