# --- Imports et déclaration FastAPI ---
import os
import sqlite3
import subprocess
from typing import Optional
import aiohttp
import asyncio
from fastapi import FastAPI, Request, BackgroundTasks, Body
from fastapi.responses import JSONResponse

app = FastAPI()

DB_PATH = "data/redriva.db"

def get_db():
    return sqlite3.connect(DB_PATH)

# --- Fonctions utilitaires pour la synchronisation globale (analogue à update) ---
def is_sync_running():
    return os.path.exists(SYNC_LOCK_PATH)

def set_sync_status(status: str):
    with open(SYNC_STATUS_PATH, "w") as f:
        f.write(status)

# --- Version 100% async avec aiohttp, asyncio, Body, rate_limit configurable ---
import aiohttp
import asyncio
from fastapi import Body

@app.post("/api/admin/update-torrents")
def admin_update_torrents(background_tasks: BackgroundTasks, rate_limit: int = Body(60)):
    """
    Lance la mise à jour des détails de tous les torrents (async, aiohttp, throttling configurable).
    """
    if is_update_running():
        return {"status": "already_running"}
    def run_update():
        async def update_all():
            try:
                os.makedirs("data", exist_ok=True)
                with open(UPDATE_LOCK_PATH, "w") as f:
                    f.write("running")
                set_update_status("running")
                for p in [UPDATE_PROGRESS_PATH, UPDATE_LOG_PATH]:
                    if os.path.exists(p):
                        os.remove(p)
                with sqlite3.connect(DB_PATH) as conn:
                    c = conn.cursor()
                    c.execute("SELECT id FROM torrents")
                    torrent_ids = [row[0] for row in c.fetchall()]
                total = len(torrent_ids)
                set_update_progress(0, total)
                append_update_log(f"Mise à jour de {total} torrents (async, {rate_limit} req/min)...")
                import os as _os
                RD_TOKEN = _os.environ.get("RD_TOKEN", "")
                if not RD_TOKEN:
                    append_update_log("[ERREUR] Token Real-Debrid manquant.")
                    set_update_status("error: token missing")
                    return
                headers = {"Authorization": f"Bearer {RD_TOKEN}"}
                sem = asyncio.Semaphore(rate_limit)
                delay = 60.0 / rate_limit if rate_limit > 0 else 1.0
                async def fetch_detail(idx, tid):
                    url = f"https://api.real-debrid.com/rest/1.0/torrents/info/{tid}"
                    for attempt in range(3):
                        try:
                            async with sem:
                                async with aiohttp.ClientSession() as session:
                                    async with session.get(url, headers=headers, timeout=20) as resp:
                                        if resp.status == 429:
                                            append_update_log(f"Quota API atteint, pause 10s...")
                                            await asyncio.sleep(10)
                                            continue
                                        if resp.status == 404:
                                            append_update_log(f"[404] Torrent {tid} introuvable.")
                                            return
                                        resp.raise_for_status()
                                        detail = await resp.json()
                                        with sqlite3.connect(DB_PATH) as conn:
                                            c = conn.cursor()
                                            c.execute('''INSERT OR REPLACE INTO torrent_details
                                                (id, name, status, size, files_count, added, downloaded, speed, progress, hash, original_filename, host, split, links, ended, error, links_count, folder, priority, custom1)
                                                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                                                (
                                                    detail.get('id'),
                                                    detail.get('filename') or detail.get('name'),
                                                    detail.get('status'),
                                                    detail.get('bytes'),
                                                    len(detail.get('files', [])),
                                                    detail.get('added'),
                                                    detail.get('downloaded'),
                                                    detail.get('speed'),
                                                    detail.get('progress'),
                                                    detail.get('hash'),
                                                    detail.get('original_filename'),
                                                    detail.get('host'),
                                                    detail.get('split'),
                                                    ",".join(detail.get('links', [])) if detail.get('links') else None,
                                                    detail.get('ended'),
                                                    detail.get('error'),
                                                    detail.get('links_count'),
                                                    detail.get('folder'),
                                                    detail.get('priority'),
                                                    None
                                                )
                                            )
                                            conn.commit()
                                        append_update_log(f"{idx+1}/{total} - {tid} OK")
                                        return
                        except Exception as e:
                            append_update_log(f"{idx+1}/{total} - {tid} ERREUR: {e}")
                            await asyncio.sleep(2)
                    append_update_log(f"Echec récupération détail pour {tid}")
                tasks = []
                for idx, tid in enumerate(torrent_ids):
                    tasks.append(fetch_detail(idx, tid))
                    await asyncio.sleep(delay)
                    set_update_progress(idx+1, total)
                await asyncio.gather(*tasks)
                set_update_status("done")
                append_update_log("Mise à jour terminée.")
            except Exception as e:
                set_update_status(f"error: {e}")
                append_update_log(f"[ERREUR] Lancement update: {e}")
            finally:
                if os.path.exists(UPDATE_LOCK_PATH):
                    os.remove(UPDATE_LOCK_PATH)
        asyncio.run(update_all())
    background_tasks.add_task(run_update)
    return {"status": "started"}

# --- Endpoint de synchronisation globale (sans rate_limit, pour sync RD → SQLite) ---
@app.post("/api/admin/sync")
def admin_sync(background_tasks: BackgroundTasks):
    """
    Lance la synchronisation globale RD → SQLite (récupère la liste des torrents, sans throttling).
    """
    if is_sync_running():
        return {"status": "already_running"}
    def run_sync():
        try:
            os.makedirs("data", exist_ok=True)
            with open(SYNC_LOCK_PATH, "w") as f:
                f.write("running")
            set_sync_status("running")
            for p in [SYNC_PROGRESS_PATH, SYNC_LOG_PATH]:
                if os.path.exists(p):
                    os.remove(p)
            with sqlite3.connect(DB_PATH) as conn:
                c = conn.cursor()
                # Ici, appeler l'API Real-Debrid pour récupérer tous les torrents (pagination)
                # et les insérer dans la table torrents
                # ... (logique existante à réintégrer)
            set_sync_status("done")
            append_sync_log("Synchronisation terminée.")
        except Exception as e:
            set_sync_status(f"error: {e}")
            append_sync_log(f"[ERREUR] Lancement sync: {e}")
        finally:
            if os.path.exists(SYNC_LOCK_PATH):
                os.remove(SYNC_LOCK_PATH)
    background_tasks.add_task(run_sync)
    return {"status": "started"}

# --- Gestion de l'état de mise à jour des détails torrents (lock file) ---
UPDATE_LOCK_PATH = os.path.join("data", ".update_torrents.lock")
UPDATE_STATUS_PATH = os.path.join("data", ".update_torrents.status")
UPDATE_PROGRESS_PATH = os.path.join("data", ".update_torrents.progress")
UPDATE_LOG_PATH = os.path.join("data", ".update_torrents.log")

def set_update_progress(progress: int, total: int):
    with open(UPDATE_PROGRESS_PATH, "w") as f:
        f.write(f"{progress}/{total}")

def get_update_progress():
    if os.path.exists(UPDATE_PROGRESS_PATH):
        with open(UPDATE_PROGRESS_PATH) as f:
            val = f.read().strip()
            try:
                done, total = map(int, val.split("/"))
                return {"done": done, "total": total}
            except Exception:
                return {"done": 0, "total": 0}
    return {"done": 0, "total": 0}

def append_update_log(line: str):
    with open(UPDATE_LOG_PATH, "a") as f:
        f.write(line.rstrip("\n") + "\n")

def get_update_log(tail=100):
    if not os.path.exists(UPDATE_LOG_PATH):
        return []
    with open(UPDATE_LOG_PATH) as f:
        lines = f.readlines()
    return lines[-tail:]

def is_update_running():
    return os.path.exists(UPDATE_LOCK_PATH)

def set_update_status(status: str):
    with open(UPDATE_STATUS_PATH, "w") as f:
        f.write(status)

def get_update_status():
    if os.path.exists(UPDATE_STATUS_PATH):
        with open(UPDATE_STATUS_PATH) as f:
            return f.read().strip()
    return "idle"


# Les endpoints FastAPI doivent être déclarés après l'objet app = FastAPI()
# (déplacement plus bas dans le fichier)

from fastapi import FastAPI, Request, BackgroundTasks
from fastapi.responses import JSONResponse
import sqlite3
from typing import Optional
import subprocess
import os

app = FastAPI()

DB_PATH = "data/redriva.db"

def get_db():
    return sqlite3.connect(DB_PATH)

@app.get("/api/queue")
def get_queue():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, torrent_id, priority, status, added_at, updated_at FROM queue ORDER BY priority ASC, added_at ASC")
    rows = cur.fetchall()
    conn.close()
    return [{
        "id": row[0],
        "torrent_id": row[1],
        "priority": row[2],
        "status": row[3],
        "added_at": row[4],
        "updated_at": row[5]
    } for row in rows]

@app.post("/api/queue")
def add_to_queue(item: dict):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO queue (torrent_id, priority, status) VALUES (?, ?, ?)",
        (item.get("torrent_id"), item.get("priority", 10), item.get("status", "pending"))
    )
    conn.commit()
    queue_id = cur.lastrowid
    conn.close()
    return {"id": queue_id}

@app.patch("/api/queue/{queue_id}")
def update_queue(queue_id: int, item: dict):
    conn = get_db()
    cur = conn.cursor()
    fields = []
    values = []
    for k in ["priority", "status"]:
        if k in item:
            fields.append(f"{k} = ?")
            values.append(item[k])
    if not fields:
        conn.close()
        return {"error": "Aucune donnée à mettre à jour"}
    values.append(queue_id)
    cur.execute(f"UPDATE queue SET {', '.join(fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", values)
    conn.commit()
    conn.close()
    return {"success": True}

@app.delete("/api/queue/{queue_id}")
def delete_queue(queue_id: int):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM queue WHERE id = ?", (queue_id,))
    conn.commit()
    conn.close()
    return {"success": True}
# Endpoint pour aide & support (exemple statique)
@app.get("/api/support")
def get_support():
    return {
        "faq": [
            {"q": "Comment ajouter un torrent ?", "a": "Utilisez le bouton 'Ajouter' sur le dashboard ou la page Torrents."},
            {"q": "Où trouver mon token Real-Debrid ?", "a": "Connectez-vous sur real-debrid.com, section 'Mon compte' > 'Applications'"},
            {"q": "Comment signaler un bug ?", "a": "Ouvrez une issue sur GitHub ou contactez le support via le formulaire."}
        ],
        "links": [
            {"label": "Documentation", "url": "https://github.com/kesurof/redriva#readme"},
            {"label": "FAQ complète", "url": "https://github.com/kesurof/redriva/wiki/FAQ"},
            {"label": "Support GitHub", "url": "https://github.com/kesurof/redriva/issues"}
        ]
    }
# Endpoint pour informations système (exemple statique)
@app.get("/api/system")
def get_system_info():
    return {
        "version": "1.0.0",
        "backend_status": "ok",
        "last_backup": "2025-07-17T23:59:00"
    }
# Backend minimal pour Redriva (FastAPI)
from fastapi import FastAPI
from fastapi.responses import JSONResponse
import sqlite3
from typing import Optional


app = FastAPI()
# --- File d’attente/priorités ---
DB_PATH = "data/redriva.db"


# --- Gestion de l'état de synchronisation (lock file) ---
SYNC_LOCK_PATH = os.path.join("data", ".sync_rd.lock")
SYNC_STATUS_PATH = os.path.join("data", ".sync_rd.status")
SYNC_PROGRESS_PATH = os.path.join("data", ".sync_rd.progress")
SYNC_LOG_PATH = os.path.join("data", ".sync_rd.log")
def set_sync_progress(progress: int, total: int):
    with open(SYNC_PROGRESS_PATH, "w") as f:
        f.write(f"{progress}/{total}")

def get_sync_progress():
    if os.path.exists(SYNC_PROGRESS_PATH):
        with open(SYNC_PROGRESS_PATH) as f:
            val = f.read().strip()
            try:
                done, total = map(int, val.split("/"))
                return {"done": done, "total": total}
            except Exception:
                return {"done": 0, "total": 0}
    return {"done": 0, "total": 0}

def append_sync_log(line: str):
    with open(SYNC_LOG_PATH, "a") as f:
        f.write(line.rstrip("\n") + "\n")

def get_sync_log(tail=100):
    if not os.path.exists(SYNC_LOG_PATH):
        return []
    with open(SYNC_LOG_PATH) as f:
        lines = f.readlines()

# Nouvelle version 100% async
@app.post("/api/admin/update-torrents")
def admin_update_torrents(background_tasks: BackgroundTasks, rate_limit: int = Body(60)):  # par défaut 60 req/min
    """
    Lance la mise à jour des détails de tous les torrents (async, aiohttp, throttling configurable).
    """
    if is_update_running():
        return {"status": "already_running"}
    def run_update():
        async def update_all():
            try:
                os.makedirs("data", exist_ok=True)
                with open(UPDATE_LOCK_PATH, "w") as f:
                    f.write("running")
                set_update_status("running")
                for p in [UPDATE_PROGRESS_PATH, UPDATE_LOG_PATH]:
                    if os.path.exists(p):
                        os.remove(p)
                with sqlite3.connect(DB_PATH) as conn:
                    c = conn.cursor()
                    c.execute("SELECT id FROM torrents")
                    torrent_ids = [row[0] for row in c.fetchall()]
                total = len(torrent_ids)
                set_update_progress(0, total)
                append_update_log(f"Mise à jour de {total} torrents (async, {rate_limit} req/min)...")
                import os as _os
                RD_TOKEN = _os.environ.get("RD_TOKEN", "")
                if not RD_TOKEN:
                    append_update_log("[ERREUR] Token Real-Debrid manquant.")
                    set_update_status("error: token missing")
                    return
                headers = {"Authorization": f"Bearer {RD_TOKEN}"}
                sem = asyncio.Semaphore(rate_limit)  # max req en parallèle
                delay = 60.0 / rate_limit if rate_limit > 0 else 1.0
                results = []
                async def fetch_detail(idx, tid):
                    url = f"https://api.real-debrid.com/rest/1.0/torrents/info/{tid}"
                    for attempt in range(3):
                        try:
                            async with sem:
                                async with aiohttp.ClientSession() as session:
                                    async with session.get(url, headers=headers, timeout=20) as resp:
                                        if resp.status == 429:
                                            append_update_log(f"Quota API atteint, pause 10s...")
                                            await asyncio.sleep(10)
                                            continue
                                        if resp.status == 404:
                                            append_update_log(f"[404] Torrent {tid} introuvable.")
                                            return
                                        resp.raise_for_status()
                                        detail = await resp.json()
                                        with sqlite3.connect(DB_PATH) as conn:
                                            c = conn.cursor()
                                            c.execute('''INSERT OR REPLACE INTO torrent_details
                                                (id, name, status, size, files_count, added, downloaded, speed, progress, hash, original_filename, host, split, links, ended, error, links_count, folder, priority, custom1)
                                                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                                                (
                                                    detail.get('id'),
                                                    detail.get('filename') or detail.get('name'),
                                                    detail.get('status'),
                                                    detail.get('bytes'),
                                                    len(detail.get('files', [])),
                                                    detail.get('added'),
                                                    detail.get('downloaded'),
                                                    detail.get('speed'),
                                                    detail.get('progress'),
                                                    detail.get('hash'),
                                                    detail.get('original_filename'),
                                                    detail.get('host'),
                                                    detail.get('split'),
                                                    ",".join(detail.get('links', [])) if detail.get('links') else None,
                                                    detail.get('ended'),
                                                    detail.get('error'),
                                                    detail.get('links_count'),
                                                    detail.get('folder'),
                                                    detail.get('priority'),
                                                    None
                                                )
                                            )
                                            conn.commit()
                                        append_update_log(f"{idx+1}/{total} - {tid} OK")
                                        return
                        except Exception as e:
                            append_update_log(f"{idx+1}/{total} - {tid} ERREUR: {e}")
                            await asyncio.sleep(2)
                    append_update_log(f"Echec récupération détail pour {tid}")
                tasks = []
                for idx, tid in enumerate(torrent_ids):
                    tasks.append(fetch_detail(idx, tid))
                    await asyncio.sleep(delay)
                    set_update_progress(idx+1, total)
                await asyncio.gather(*tasks)
                set_update_status("done")
                append_update_log("Mise à jour terminée.")
            except Exception as e:
                set_update_status(f"error: {e}")
                append_update_log(f"[ERREUR] Lancement update: {e}")
            finally:
                if os.path.exists(UPDATE_LOCK_PATH):
                    os.remove(UPDATE_LOCK_PATH)
        asyncio.run(update_all())
    background_tasks.add_task(run_update)
    return {"status": "started"}

@app.post("/api/queue")
def add_to_queue(item: dict):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO queue (torrent_id, priority, status) VALUES (?, ?, ?)",
        (item.get("torrent_id"), item.get("priority", 10), item.get("status", "pending"))
    )
    conn.commit()
    queue_id = cur.lastrowid
    conn.close()
    return {"id": queue_id}

@app.patch("/api/queue/{queue_id}")
def update_queue(queue_id: int, item: dict):
    conn = get_db()
    cur = conn.cursor()
    fields = []
    values = []
    for k in ["priority", "status"]:
        if k in item:
            fields.append(f"{k} = ?")
            values.append(item[k])
    if not fields:
        conn.close()
        return {"error": "Aucune donnée à mettre à jour"}
    values.append(queue_id)
    cur.execute(f"UPDATE queue SET {', '.join(fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", values)
    conn.commit()
    conn.close()
    return {"success": True}

@app.delete("/api/queue/{queue_id}")
def delete_queue(queue_id: int):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM queue WHERE id = ?", (queue_id,))
    conn.commit()
    conn.close()
    return {"success": True}

@app.get("/api/support")
def get_support():
    return {
        "faq": [
            {"q": "Comment ajouter un torrent ?", "a": "Utilisez le bouton 'Ajouter' sur le dashboard ou la page Torrents."},
            {"q": "Où trouver mon token Real-Debrid ?", "a": "Connectez-vous sur real-debrid.com, section 'Mon compte' > 'Applications'"},
            {"q": "Comment signaler un bug ?", "a": "Ouvrez une issue sur GitHub ou contactez le support via le formulaire."}
        ],
        "links": [
            {"label": "Documentation", "url": "https://github.com/kesurof/redriva#readme"},
            {"label": "FAQ complète", "url": "https://github.com/kesurof/redriva/wiki/FAQ"},
            {"label": "Support GitHub", "url": "https://github.com/kesurof/redriva/issues"}
        ]
    }

@app.get("/api/system")
def get_system_info():
    return {
        "version": "1.0.0",
        "backend_status": "ok",
        "last_backup": "2025-07-17T23:59:00"
    }

@app.get("/api/ping")
def ping():
    return {"status": "ok"}



# Endpoint pour l'utilisation des quotas Real-Debrid (exemple statique)
@app.get("/api/quotas")
def get_quotas():
    # À remplacer par un appel réel à l'API Real-Debrid
    return {
        "quota_rest": 12,  # en Go
        "slots_used": 3,
        "slots_total": 5
    }

# Endpoint pour logs récents (exemple statique)
@app.get("/api/logs")
def get_logs():
    # À remplacer par lecture réelle des logs
    return {
        "logs": [
            {"timestamp": "2025-07-18T10:12:00", "level": "INFO", "message": "Démarrage du backend"},
            {"timestamp": "2025-07-18T10:13:12", "level": "WARNING", "message": "Quota presque atteint"},
            {"timestamp": "2025-07-18T10:14:01", "level": "ERROR", "message": "Erreur API Real-Debrid"}
        ]
    }
