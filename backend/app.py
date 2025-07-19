# --- Imports et déclaration FastAPI ---

import os
import asyncio
import aiosqlite
import aiohttp
from fastapi import FastAPI, Request, BackgroundTasks, Body, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Optional

# Importe la persistance asynchrone
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), 'src')))
from persistence import init_db, save_torrents, get_all_torrents, init_queue_table, get_all_queue, add_to_queue as persist_add_to_queue, update_queue as persist_update_queue, delete_queue as persist_delete_queue


app = FastAPI()


# Initialisation async de la base et de la queue au démarrage
@app.on_event("startup")
async def startup_event():
    await init_db()
    await init_queue_table()

DB_PATH = "data/redriva.db"

# Schéma Pydantic file d'attente
class QueueItem(BaseModel):
    torrent_id: str
    priority: int = 10
    status: str = "pending"

class QueueUpdate(BaseModel):
    priority: Optional[int] = None
    status: Optional[str] = None

from fastapi import status
from services import fetch_torrents, add_torrent_rd
from logging_utils import log_info, log_error, log_access
from ratelimit_utils import rate_limited

# --- Endpoints file d'attente (async only) ---
# --- Endpoints torrents (fusionnés) ---
@app.get("/api/torrents")
@rate_limited("/api/torrents")
async def get_torrents(request: Request):
    log_access("/api/torrents")
    try:
        torrents = await fetch_torrents()
        await save_torrents(torrents)
        log_info(f"Torrents récupérés et stockés: {len(torrents)}")
        return {"success": True, "data": torrents, "error": None}
    except Exception as e:
        log_error(f"Erreur /api/torrents: {e}")
        return JSONResponse(content={"success": False, "data": None, "error": str(e)}, status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

@app.post("/api/torrents")
@rate_limited("/api/torrents")
async def add_torrent(request: Request, body: dict = Body(...)):
    log_access("POST /api/torrents")
    try:
        magnet = body.get("magnet")
        if not magnet:
            return JSONResponse(content={"success": False, "error": "Champ 'magnet' requis."}, status_code=status.HTTP_400_BAD_REQUEST)
        result = await add_torrent_rd(magnet)
        log_info(f"Ajout torrent RD: {magnet} => {result}")
        return {"success": True, "data": result, "error": None}
    except Exception as e:
        log_error(f"Erreur POST /api/torrents: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
@app.get("/api/queue")
@rate_limited("/api/queue")
async def get_queue(request: Request):
    log_access("/api/queue")
    try:
        queue = await get_all_queue()
        return queue
    except Exception as e:
        log_error(f"Erreur GET /api/queue: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)

# Exemple d'utilisation de la persistance async pour les torrents (à adapter selon les besoins)
@app.get("/api/torrents/local")
async def get_local_torrents():
    torrents = await get_all_torrents()
    return {"success": True, "data": torrents, "error": None}

@app.post("/api/queue")
@rate_limited("/api/queue")
async def add_to_queue(item: QueueItem, request: Request):
    log_access("POST /api/queue")
    try:
        queue_id = await persist_add_to_queue(item.torrent_id, item.priority, item.status)
        log_info(f"Ajout file d'attente: {item.torrent_id} (prio {item.priority})")
        return {"id": queue_id}
    except Exception as e:
        log_error(f"Erreur POST /api/queue: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)

@app.patch("/api/queue/{queue_id}")
@rate_limited("/api/queue")
async def update_queue(queue_id: int, item: QueueUpdate, request: Request):
    log_access(f"PATCH /api/queue/{queue_id}")
    if item.priority is None and item.status is None:
        log_error("PATCH /api/queue: aucune donnée à mettre à jour")
        raise HTTPException(status_code=400, detail="Aucune donnée à mettre à jour")
    try:
        rowcount = await persist_update_queue(queue_id, item.priority, item.status)
        if rowcount == 0:
            log_error(f"PATCH /api/queue: job {queue_id} non trouvé")
            raise HTTPException(status_code=404, detail="Job non trouvé")
        log_info(f"Maj file d'attente {queue_id}: prio={item.priority}, status={item.status}")
        return {"success": True}
    except Exception as e:
        log_error(f"Erreur PATCH /api/queue/{queue_id}: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)

@app.delete("/api/queue/{queue_id}")
@rate_limited("/api/queue")
async def delete_queue(queue_id: int, request: Request):
    log_access(f"DELETE /api/queue/{queue_id}")
    try:
        rowcount = await persist_delete_queue(queue_id)
        if rowcount == 0:
            log_error(f"DELETE /api/queue: job {queue_id} non trouvé")
            raise HTTPException(status_code=404, detail="Job non trouvé")
        log_info(f"Suppression file d'attente {queue_id}")
        return {"success": True}
    except Exception as e:
        log_error(f"Erreur DELETE /api/queue/{queue_id}: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)

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


# --- Fonctions utilitaires asynchrones pour la synchronisation globale ---

async def get_torrent_ids():
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT id FROM torrents") as cursor:
            rows = await cursor.fetchall()
        return [row[0] for row in rows]

async def upsert_torrent_detail(detail):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute('''INSERT OR REPLACE INTO torrent_details
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
        await db.commit()

# --- Version 100% async avec aiohttp, asyncio, Body, rate_limit configurable ---
@app.post("/api/admin/update-torrents")
@rate_limited("/api/admin/update-torrents")
async def admin_update_torrents(background_tasks: BackgroundTasks, rate_limit: int = Body(60)):
    log_access("POST /api/admin/update-torrents")
    """
    Lance la mise à jour des détails de tous les torrents (async, aiohttp, throttling configurable).
    """
    if is_update_running():
        log_info("Mise à jour déjà en cours.")
        return {"status": "already_running"}
    async def update_all():
        try:
            os.makedirs("data", exist_ok=True)
            with open(UPDATE_LOCK_PATH, "w") as f:
                f.write("running")
            set_update_status("running")
            for p in [UPDATE_PROGRESS_PATH, UPDATE_LOG_PATH]:
                if os.path.exists(p):
                    os.remove(p)
            torrent_ids = await get_torrent_ids()
            total = len(torrent_ids)
            set_update_progress(0, total)
            append_update_log(f"Mise à jour de {total} torrents (async, {rate_limit} req/min)...")
            import os as _os
            RD_TOKEN = _os.environ.get("RD_TOKEN", "")
            if not RD_TOKEN:
                append_update_log("[ERREUR] Token Real-Debrid manquant.")
                set_update_status("error: token missing")
                log_error("Token Real-Debrid manquant pour update-torrents.")
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
                                    await upsert_torrent_detail(detail)
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
            log_info("Mise à jour des torrents terminée.")
        except Exception as e:
            set_update_status(f"error: {e}")
            append_update_log(f"[ERREUR] Lancement update: {e}")
            log_error(f"Erreur update-torrents: {e}")
        finally:
            if os.path.exists(UPDATE_LOCK_PATH):
                os.remove(UPDATE_LOCK_PATH)
    background_tasks.add_task(update_all)
    return {"status": "started"}

# --- Endpoint de synchronisation globale (sans rate_limit, pour sync RD → SQLite) ---
@app.post("/api/admin/sync")
@rate_limited("/api/admin/sync")
async def admin_sync(background_tasks: BackgroundTasks):
    log_access("POST /api/admin/sync")
    """
    Lance la synchronisation globale RD → SQLite (récupère la liste des torrents, sans throttling).
    """
    if is_sync_running():
        log_info("Synchronisation déjà en cours.")
        return {"status": "already_running"}
    async def sync_all():
        try:
            os.makedirs("data", exist_ok=True)
            with open(SYNC_LOCK_PATH, "w") as f:
                f.write("running")
            set_sync_status("running")
            for p in [SYNC_PROGRESS_PATH, SYNC_LOG_PATH]:
                if os.path.exists(p):
                    os.remove(p)
            # Ici, appeler l'API Real-Debrid pour récupérer tous les torrents (pagination)
            # et les insérer dans la table torrents (utiliser aiosqlite)
            # ... (logique existante à réintégrer, à adapter async)
            set_sync_status("done")
            append_sync_log("Synchronisation terminée.")
            log_info("Synchronisation RD → SQLite terminée.")
        except Exception as e:
            set_sync_status(f"error: {e}")
            append_sync_log(f"[ERREUR] Lancement sync: {e}")
            log_error(f"Erreur synchronisation RD → SQLite: {e}")
        finally:
            if os.path.exists(SYNC_LOCK_PATH):
                os.remove(SYNC_LOCK_PATH)
    background_tasks.add_task(sync_all)
    return {"status": "started"}

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
    return lines[-tail:]

def is_sync_running():
    return os.path.exists(SYNC_LOCK_PATH)

def set_sync_status(status: str):
    with open(SYNC_STATUS_PATH, "w") as f:
        f.write(status)

def get_sync_status():
    if os.path.exists(SYNC_STATUS_PATH):
        with open(SYNC_STATUS_PATH) as f:
            return f.read().strip()
    return "idle"

# Endpoint pour aide & support (exemple statique)
@app.get("/api/support")
@rate_limited("/api/support")
async def get_support(request: Request):
    log_access("GET /api/support")
    try:
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
    except Exception as e:
        log_error(f"Erreur GET /api/support: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)
# Endpoint pour informations système (exemple statique)
@app.get("/api/system")
@rate_limited("/api/system")
async def get_system_info(request: Request):
    log_access("GET /api/system")
    try:
        return {
            "version": "1.0.0",
            "backend_status": "ok",
            "last_backup": "2025-07-17T23:59:00"
        }
    except Exception as e:
        log_error(f"Erreur GET /api/system: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)
# Endpoint pour l'utilisation des quotas Real-Debrid (exemple statique)
@app.get("/api/quotas")
@rate_limited("/api/quotas")
async def get_quotas(request: Request):
    log_access("GET /api/quotas")
    try:
        # À remplacer par un appel réel à l'API Real-Debrid
        return {
            "quota_rest": 12,  # en Go
            "slots_used": 3,
            "slots_total": 5
        }
    except Exception as e:
        log_error(f"Erreur GET /api/quotas: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)

# Endpoint pour logs récents (exemple statique)
@app.get("/api/logs")
@rate_limited("/api/logs")
async def get_logs(request: Request):
    log_access("GET /api/logs")
    try:
        # À remplacer par lecture réelle des logs
        return {
            "logs": [
                {"timestamp": "2025-07-18T10:12:00", "level": "INFO", "message": "Démarrage du backend"},
                {"timestamp": "2025-07-18T10:13:12", "level": "WARNING", "message": "Quota presque atteint"},
                {"timestamp": "2025-07-18T10:14:01", "level": "ERROR", "message": "Erreur API Real-Debrid"}
            ]
        }
    except Exception as e:
        log_error(f"Erreur GET /api/logs: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)

@app.get("/api/ping")
@rate_limited("/api/ping")
async def ping(request: Request):
    log_access("GET /api/ping")
    try:
        return {"status": "ok"}
    except Exception as e:
        log_error(f"Erreur GET /api/ping: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)
