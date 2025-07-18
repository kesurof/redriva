# Logiciel de gestion de file d’attente Redriva
# Limite le nombre de téléchargements simultanés et gère les priorités

import aiosqlite
import asyncio

DB_PATH = "data/redriva.db"
MAX_ACTIVE = 2  # Nombre de téléchargements simultanés autorisés


async def get_next_pending():
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT id, torrent_id FROM queue WHERE status = 'pending' ORDER BY priority ASC, added_at ASC LIMIT 1") as cursor:
            row = await cursor.fetchone()
        return row


async def count_active():
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT COUNT(*) FROM queue WHERE status = 'active'") as cursor:
            row = await cursor.fetchone()
        return row[0] if row else 0


async def set_status(queue_id, status):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("UPDATE queue SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?", (status, queue_id))
        await db.commit()


async def worker_loop():
    import asyncio
    while True:
        if await count_active() < MAX_ACTIVE:
            next_item = await get_next_pending()
            if next_item:
                queue_id, torrent_id = next_item
                await set_status(queue_id, 'active')
                # Ici, lancer le téléchargement réel (appel API RD, etc.)
                # Pour la démo, on simule un téléchargement
                print(f"[QUEUE] Lancement du téléchargement {torrent_id} (queue_id={queue_id})")
                asyncio.create_task(simulate_download(queue_id))
        await asyncio.sleep(5)


async def simulate_download(queue_id):
    import asyncio
    await asyncio.sleep(20)
    await set_status(queue_id, 'completed')
    print(f"[QUEUE] Téléchargement terminé pour queue_id={queue_id}")


if __name__ == "__main__":
    import asyncio
    print("[QUEUE] Gestionnaire de file d’attente démarré (async)")
    asyncio.run(worker_loop())
