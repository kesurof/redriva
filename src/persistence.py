# persistence.py : gestion de la persistance des torrents (SQLite)
import sqlite3
import os
from typing import List, Dict

def get_db_path():
    base_dir = os.path.dirname(os.path.dirname(__file__))
    data_dir = os.path.join(base_dir, "data")
    os.makedirs(data_dir, exist_ok=True)
    return os.path.join(data_dir, "torrents.db")

def init_db():
    db_path = get_db_path()
    with sqlite3.connect(db_path) as conn:
        c = conn.cursor()
        # Création initiale si besoin
        c.execute("""
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
                c.execute(f"ALTER TABLE torrents ADD COLUMN {col} {typ}")
            except sqlite3.OperationalError:
                pass  # Colonne déjà existante
        conn.commit()

def save_torrents(torrents: List[Dict]):
    db_path = get_db_path()
    with sqlite3.connect(db_path) as conn:
        c = conn.cursor()
        for t in torrents:
            c.execute("""
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
            ))
        conn.commit()

def get_all_torrents():
    db_path = get_db_path()
    with sqlite3.connect(db_path) as conn:
        c = conn.cursor()
        c.execute("SELECT id, filename, status, size, added, links, details FROM torrents")
        rows = c.fetchall()
        return [
            {
                "id": row[0],
                "filename": row[1],
                "status": row[2],
                "size": row[3],
                "added": row[4],
                "links": row[5].split(",") if row[5] else [],
                "details": row[6]
            }
            for row in rows
        ]

# Initialisation automatique à l'import
init_db()
