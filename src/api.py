# API FastAPI minimal pour Redriva
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi import Request, Body, Path
from .services import fetch_torrents, add_torrent_rd, delete_torrent_rd, get_torrent_detail_rd

# API FastAPI minimal pour Redriva
from fastapi import FastAPI, Request, Body, Path
from fastapi.responses import JSONResponse
from .services import fetch_torrents
from . import persistence
from .logging_utils import log_info, log_error, log_access
from .ratelimit_utils import rate_limited

app = FastAPI()

@app.get("/api/ping")
def ping():
    log_access("/api/ping")
    return {"success": True, "message": "pong"}

@app.get("/api/torrents")
@rate_limited("/api/torrents")
async def get_torrents(request: Request):
    log_access("/api/torrents")
    try:
        torrents = await fetch_torrents()
        persistence.save_torrents(torrents)
        log_info(f"Torrents récupérés et stockés: {len(torrents)}")
        return JSONResponse(content={"success": True, "data": torrents, "error": None})
    except Exception as e:
        log_error(f"Erreur /api/torrents: {e}")
        return JSONResponse(content={"success": False, "data": None, "error": str(e)}, status_code=500)

@app.get("/api/torrents/local")
@rate_limited("/api/torrents/local")
def get_local_torrents(request: Request):
    log_access("/api/torrents/local")
    try:
        torrents = persistence.get_all_torrents()
        return JSONResponse(content={"success": True, "data": torrents, "error": None})
    except Exception as e:
        log_error(f"Erreur /api/torrents/local: {e}")
        return JSONResponse(content={"success": False, "data": None, "error": str(e)}, status_code=500)

@app.post("/api/torrents")
@rate_limited("/api/torrents")
async def add_torrent(request: Request, body: dict = Body(...)):
    log_access("POST /api/torrents")
    try:
        magnet = body.get("magnet")
        if not magnet:
            return JSONResponse(content={"success": False, "error": "Champ 'magnet' requis."}, status_code=400)
        result = await add_torrent_rd(magnet)
        log_info(f"Ajout torrent RD: {magnet} => {result}")
        return JSONResponse(content={"success": True, "data": result, "error": None})
    except Exception as e:
        log_error(f"Erreur POST /api/torrents: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)

@app.delete("/api/torrents/{torrent_id}")
@rate_limited("/api/torrents/{id}")
async def delete_torrent(request: Request, torrent_id: str = Path(...)):
    log_access(f"DELETE /api/torrents/{torrent_id}")
    try:
        result = await delete_torrent_rd(torrent_id)
        log_info(f"Suppression torrent RD: {torrent_id} => {result}")
        return JSONResponse(content={"success": True, "data": result, "error": None})
    except Exception as e:
        log_error(f"Erreur DELETE /api/torrents/{torrent_id}: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)

@app.get("/api/torrents/{torrent_id}")
@rate_limited("/api/torrents/{id}")
async def get_torrent_detail(request: Request, torrent_id: str = Path(...)):
    log_access(f"GET /api/torrents/{torrent_id}")
    try:
        result = await get_torrent_detail_rd(torrent_id)
        log_info(f"Détail torrent RD: {torrent_id} => {result}")
        return JSONResponse(content={"success": True, "data": result, "error": None})
    except Exception as e:
        log_error(f"Erreur GET /api/torrents/{torrent_id}: {e}")
        return JSONResponse(content={"success": False, "error": str(e)}, status_code=500)
        return JSONResponse(content={"success": False, "data": None, "error": str(e)}, status_code=500)
