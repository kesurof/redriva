# persistence.py : gestion de la persistance des torrents (SQLite)
import aiosqlite
import os
from typing import List, Dict

def get_db_path():
    base_dir = os.path.dirname(os.path.dirname(__file__))
    data_dir = os.path.join(base_dir, "data")
    os.makedirs(data_dir, exist_ok=True)
    return os.path.join(data_dir, "torrents.db")

async def init_db():
    db_path = get_db_path()
    async with aiosqlite.connect(db_path) as db:
        await db.execute("""
        CREATE TABLE IF NOT EXISTS torrents (
            id TEXT PRIMARY KEY,
            filename TEXT,
            status TEXT,
            size INTEGER
        )
        """)
        # Ajout des colonnes manquantes (migration douce)
        for col, typ in [
            ("added", "INTEGER"),
            ("links", "TEXT"),
            ("details", "TEXT")
        ]:
            try:
                await db.execute(f"ALTER TABLE torrents ADD COLUMN {col} {typ}")
            except Exception:
                pass  # Colonne déjà existante
        await db.commit()

async def save_torrents(torrents: List[Dict]):
    db_path = get_db_path()
    async with aiosqlite.connect(db_path) as db:
        for t in torrents:
            await db.execute(
                """
                INSERT OR REPLACE INTO torrents (id, filename, status, size, added, links, details)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    t.get("id"),
                    t.get("filename"),
                    t.get("status"),
                    t.get("bytes"),
                    t.get("added"),
                    ",".join(t.get("links", [])) if t.get("links") else None,
                    str(t)
                )
            )
        await db.commit()

async def get_all_torrents():
    db_path = get_db_path()
    async with aiosqlite.connect(db_path) as db:
        db.row_factory = aiosqlite.Row
        async with db.execute("SELECT id, filename, status, size, added, links, details FROM torrents") as cursor:
            rows = await cursor.fetchall()
        return [
            {
                "id": row["id"],
                "filename": row["filename"],
                "status": row["status"],
                "size": row["size"],
                "added": row["added"],
                "links": row["links"].split(",") if row["links"] else [],
                "details": row["details"]
            }
            for row in rows
        ]


# --- Gestion asynchrone de la file d'attente (queue) ---
async def init_queue_table():
    db_path = get_db_path()
    async with aiosqlite.connect(db_path) as db:
        await db.execute('''
            CREATE TABLE IF NOT EXISTS queue (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                torrent_id TEXT NOT NULL,
                priority INTEGER DEFAULT 10,
                status TEXT DEFAULT 'pending',
                added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        await db.commit()

async def get_all_queue():
    db_path = get_db_path()
    async with aiosqlite.connect(db_path) as db:
        db.row_factory = aiosqlite.Row
        async with db.execute("SELECT id, torrent_id, priority, status, added_at, updated_at FROM queue ORDER BY priority ASC, added_at ASC") as cursor:
            rows = await cursor.fetchall()
        return [dict(row) for row in rows]

async def add_to_queue(torrent_id: str, priority: int = 10, status: str = "pending"):
    db_path = get_db_path()
    async with aiosqlite.connect(db_path) as db:
        cursor = await db.execute(
            "INSERT INTO queue (torrent_id, priority, status) VALUES (?, ?, ?)",
            (torrent_id, priority, status)
        )
        await db.commit()
        return cursor.lastrowid

async def update_queue(queue_id: int, priority: int = None, status: str = None):
    db_path = get_db_path()
    fields = []
    values = []
    if priority is not None:
        fields.append("priority = ?")
        values.append(priority)
    if status is not None:
        fields.append("status = ?")
        values.append(status)
    if not fields:
        return 0
    values.append(queue_id)
    async with aiosqlite.connect(db_path) as db:
        cursor = await db.execute(f"UPDATE queue SET {', '.join(fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", values)
        await db.commit()
        return cursor.rowcount

async def delete_queue(queue_id: int):
    db_path = get_db_path()
    async with aiosqlite.connect(db_path) as db:
        cursor = await db.execute("DELETE FROM queue WHERE id = ?", (queue_id,))
        await db.commit()
        return cursor.rowcount
