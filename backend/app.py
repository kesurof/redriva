# API FastAPI pure pour Redriva
import os
import random
from datetime import datetime, timedelta
from fastapi import FastAPI, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import logging

# Import de nos services
from services.realdebrid import rd_client
from services.data_mapper import map_rd_torrent_to_response, map_rd_torrent_detail_to_response
from database.auth_db import auth_db

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Redriva API", version="1.0.0")

# Configuration CORS pour permettre les requêtes depuis le frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],  # SvelteKit dev server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialisation de la base de données au démarrage
@app.on_event("startup")
async def startup_event():
    await auth_db.init_db()

# Modèles Pydantic pour l'API
class TorrentResponse(BaseModel):
    id: str
    name: str
    title: str
    size: str
    status: str
    state: str
    progress: int
    speed: str
    category: str
    seeders: int
    added_date: str
    hash: str
    magnet_url: str

class TorrentCreate(BaseModel):
    magnet_url: str

class QueueItemResponse(BaseModel):
    id: int
    status: str
    created_at: str
    updated_at: str
    data: Dict[str, Any]

class QueueItemCreate(BaseModel):
    data: Dict[str, Any]

class SystemInfoResponse(BaseModel):
    cpu_usage: float
    memory_usage: float
    disk_usage: float
    uptime: str

class ApiResponse(BaseModel):
    success: bool
    message: Optional[str] = None
    data: Optional[Any] = None

class DeviceCodeResponse(BaseModel):
    device_code: str
    user_code: str
    verification_url: str
    expires_in: int
    interval: int

class AuthStatusResponse(BaseModel):
    authenticated: bool
    message: Optional[str] = None

# Initialisation de la base de données
@app.on_event("startup")
async def startup_event():
    print("Redriva API démarrage...")

# Fonction utilitaire pour générer des torrents factices
def generate_fake_torrents(count: int = 10) -> List[TorrentResponse]:
    """Génère des torrents factices pour le développement"""
    torrents = []
    base_names = [
        "Ubuntu.22.04.LTS.Desktop", "Debian.12.Bookworm.DVD", "Fedora.39.Workstation",
        "Linux.Mint.21.Cinnamon", "PopOS.22.04.LTS", "Elementary.OS.7", "Manjaro.KDE.Plasma",
        "OpenSUSE.Leap.15.5", "CentOS.Stream.9", "Arch.Linux.2024"
    ]
    statuses = ["downloading", "queued", "seeding", "error", "completed"]
    states = ["active", "paused", "stopped"]
    categories = ["OS", "Software", "Media", "Games", "Books"]
    
    for i in range(count):
        base_name = random.choice(base_names)
        torrent = TorrentResponse(
            id=str(i),
            name=f"{base_name}.{random.randint(1000, 9999)}",
            title=f"{base_name}.{random.randint(1000, 9999)}",
            size=f"{random.uniform(0.5, 50):.1f} GB",
            status=random.choice(statuses),
            state=random.choice(states),
            progress=random.randint(0, 100),
            speed=f"{random.uniform(0, 10):.1f} MB/s" if random.choice([True, False]) else "0 B/s",
            category=random.choice(categories),
            seeders=random.randint(0, 1000),
            added_date=(datetime.now() - timedelta(days=random.randint(0, 30))).strftime("%d/%m/%Y %H:%M"),
            hash=f"{''.join(random.choices('abcdef0123456789', k=40))}",
            magnet_url=f"magnet:?xt=urn:btih:{''.join(random.choices('abcdef0123456789', k=40))}&dn={base_name}"
        )
        torrents.append(torrent)
    
    return torrents

# === ROUTES API ===

@app.get("/api/ping")
async def ping():
    """Endpoint de vérification de l'état de l'API"""
    return {"status": "ok", "timestamp": datetime.now().isoformat()}

# === ROUTES D'AUTHENTIFICATION ===

@app.get("/api/auth/status", response_model=AuthStatusResponse)
async def get_auth_status():
    """Vérifie si l'utilisateur est authentifié"""
    is_authenticated = await auth_db.is_authenticated()
    return AuthStatusResponse(
        authenticated=is_authenticated,
        message="Authentifié" if is_authenticated else "Non authentifié"
    )

@app.post("/api/auth/device-code", response_model=DeviceCodeResponse)
async def get_device_code():
    """Initie le flux d'authentification OAuth Device Flow"""
    try:
        device_data = await rd_client.get_device_code()
        
        # Stocker les informations du device code
        await auth_db.store_device_code(
            device_code=device_data["device_code"],
            user_code=device_data["user_code"],
            verification_url=device_data["verification_url"],
            expires_in=device_data["expires_in"],
            interval_time=device_data["interval"]
        )
        
        logger.info(f"Device code généré: {device_data['user_code']}")
        
        return DeviceCodeResponse(
            device_code=device_data["device_code"],
            user_code=device_data["user_code"],
            verification_url=device_data["verification_url"],
            expires_in=device_data["expires_in"],
            interval=device_data["interval"]
        )
        
    except Exception as e:
        logger.error(f"Erreur lors de la génération du device code: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur lors de l'authentification: {str(e)}")

@app.post("/api/auth/check-token")
async def check_device_authorization(request: dict):
    """Vérifie l'état de l'autorisation et récupère le token si approuvé"""
    try:
        device_code = request.get('device_code')
        if not device_code:
            raise HTTPException(status_code=400, detail="device_code requis")
            
        result = await rd_client.check_device_authorization(device_code)
        
        if result["status"] == "success":
            # Stocker le token d'accès
            token_data = result["data"]
            await auth_db.store_access_token(token_data["access_token"])
            
            logger.info("Authentification réussie, token stocké")
            return {"status": "success", "message": "Authentification réussie"}
            
        elif result["status"] == "pending":
            return {"status": "pending", "message": result["message"]}
        else:
            return {"status": "error", "message": "Erreur lors de la vérification"}
            
    except Exception as e:
        logger.error(f"Erreur lors de la vérification du token: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur lors de la vérification: {str(e)}")

@app.post("/api/auth/logout")
async def logout():
    """Déconnecte l'utilisateur en supprimant le token"""
    try:
        # Supprimer le token de la base de données
        await auth_db.store_access_token("")  # Cela va écraser avec une chaîne vide
        logger.info("Déconnexion réussie")
        return {"status": "success", "message": "Déconnexion réussie"}
        
    except Exception as e:
        logger.error(f"Erreur lors de la déconnexion: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur lors de la déconnexion: {str(e)}")

# === ROUTES TORRENTS ===

@app.get("/api/torrents")
async def get_torrents():
    """Récupère la liste de tous les torrents depuis Real-Debrid"""
    try:
        rd_torrents = await rd_client.get_torrents()
        
        # Mapper les données Real-Debrid vers notre format
        mapped_torrents = [map_rd_torrent_to_response(rd_torrent) for rd_torrent in rd_torrents]
        
        logger.info(f"Récupéré {len(mapped_torrents)} torrents depuis Real-Debrid")
        return mapped_torrents
        
    except Exception as e:
        logger.error(f"Erreur lors de la récupération des torrents: {e}")
        # En cas d'erreur, retourner une liste vide plutôt que de planter
        return []

@app.post("/api/torrents")
async def add_torrent(torrent_data: TorrentCreate):
    """Ajoute un nouveau torrent via Real-Debrid"""
    try:
        # Ajouter le torrent via Real-Debrid
        rd_response = await rd_client.add_torrent(torrent_data.magnet_url)
        
        # Récupérer les informations du torrent ajouté
        torrent_id = rd_response.get("id")
        if torrent_id:
            rd_torrent = await rd_client.get_torrent_info(torrent_id)
            mapped_torrent = map_rd_torrent_to_response(rd_torrent)
            logger.info(f"Torrent ajouté avec succès: {torrent_id}")
            return mapped_torrent
        else:
            raise HTTPException(status_code=500, detail="Erreur lors de l'ajout du torrent")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erreur lors de l'ajout du torrent: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur lors de l'ajout: {str(e)}")

@app.delete("/api/torrents/{torrent_id}")
async def delete_torrent(torrent_id: str):
    """Supprime un torrent via Real-Debrid"""
    try:
        success = await rd_client.delete_torrent(torrent_id)
        if success:
            logger.info(f"Torrent supprimé avec succès: {torrent_id}")
            return {"success": True, "message": f"Torrent {torrent_id} supprimé"}
        else:
            raise HTTPException(status_code=500, detail="Erreur lors de la suppression")
            
    except Exception as e:
        logger.error(f"Erreur lors de la suppression du torrent {torrent_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur lors de la suppression: {str(e)}")

@app.get("/api/torrents/{torrent_id}")
async def get_torrent_detail(torrent_id: str):
    """Récupère les détails d'un torrent depuis Real-Debrid"""
    try:
        rd_torrent = await rd_client.get_torrent_info(torrent_id)
        mapped_torrent = map_rd_torrent_detail_to_response(rd_torrent)
        
        logger.info(f"Détails récupérés pour le torrent: {torrent_id}")
        return mapped_torrent
        
    except Exception as e:
        logger.error(f"Erreur lors de la récupération des détails du torrent {torrent_id}: {e}")
        raise HTTPException(status_code=404, detail=f"Torrent {torrent_id} non trouvé")

@app.post("/api/torrents/{torrent_id}/reinsert")
async def reinsert_torrent(torrent_id: str):
    """Réinsère un torrent dans la queue"""
    # TODO: Implémenter la logique de réinsertion
    return {"success": True, "message": f"Torrent {torrent_id} réinséré"}

@app.get("/api/queue", response_model=List[QueueItemResponse])
async def get_queue():
    """Récupère la queue des tâches"""
    try:
        # TODO: Remplacer par les vraies données de la base
        fake_queue = [
            QueueItemResponse(
                id=1,
                status="pending",
                created_at=datetime.now().isoformat(),
                updated_at=datetime.now().isoformat(),
                data={"type": "download", "name": "Example Torrent"}
            )
        ]
        return fake_queue
    except Exception as e:
        print(f"Erreur lors de la récupération de la queue: {e}")
        return []

@app.post("/api/queue", response_model=QueueItemResponse)
async def add_to_queue(item_data: QueueItemCreate):
    """Ajoute un élément à la queue"""
    try:
        # TODO: Implémenter l'ajout en base de données
        new_id = random.randint(1000, 9999)
        return QueueItemResponse(
            id=new_id,
            status="pending",
            created_at=datetime.now().isoformat(),
            updated_at=datetime.now().isoformat(),
            data=item_data.data
        )
    except Exception as e:
        print(f"Erreur lors de l'ajout à la queue: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/queue/{queue_id}")
async def delete_from_queue(queue_id: int):
    """Supprime un élément de la queue"""
    try:
        # TODO: Implémenter la suppression en base de données
        return {"success": True, "message": f"Élément {queue_id} supprimé de la queue"}
    except Exception as e:
        print(f"Erreur lors de la suppression de la queue: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/system", response_model=SystemInfoResponse)
async def get_system_info():
    """Récupère les informations système"""
    import psutil
    import time
    
    try:
        uptime_seconds = time.time() - psutil.boot_time()
        uptime_hours = int(uptime_seconds // 3600)
        uptime_minutes = int((uptime_seconds % 3600) // 60)
        
        return SystemInfoResponse(
            cpu_usage=psutil.cpu_percent(interval=1),
            memory_usage=psutil.virtual_memory().percent,
            disk_usage=psutil.disk_usage('/').percent,
            uptime=f"{uptime_hours}h {uptime_minutes}m"
        )
    except Exception as e:
        print(f"Erreur lors de la récupération des infos système: {e}")
        return SystemInfoResponse(
            cpu_usage=0.0,
            memory_usage=0.0,
            disk_usage=0.0,
            uptime="Unknown"
        )

@app.get("/api/logs")
async def get_logs():
    """Récupère les logs de l'application"""
    try:
        log_file_path = "logs/redriva.log"
        if os.path.exists(log_file_path):
            with open(log_file_path, "r", encoding="utf-8") as f:
                lines = f.readlines()
                # Retourne les 100 dernières lignes
                return {"logs": lines[-100:]}
        else:
            return {"logs": ["Aucun fichier de log trouvé"]}
    except Exception as e:
        print(f"Erreur lors de la lecture des logs: {e}")
        return {"logs": [f"Erreur: {str(e)}"]}

@app.post("/api/admin/update-torrents")
async def update_torrents(background_tasks: BackgroundTasks):
    """Met à jour les torrents en arrière-plan"""
    # TODO: Implémenter la logique de mise à jour
    background_tasks.add_task(lambda: print("Mise à jour des torrents démarrée"))
    return {"success": True, "message": "Mise à jour des torrents démarrée"}

@app.post("/api/admin/sync")
async def sync_with_real_debrid(background_tasks: BackgroundTasks):
    """Synchronise avec Real-Debrid en arrière-plan"""
    # TODO: Implémenter la logique de synchronisation
    background_tasks.add_task(lambda: print("Synchronisation Real-Debrid démarrée"))
    return {"success": True, "message": "Synchronisation Real-Debrid démarrée"}

# Routes de fallback pour les anciennes routes (compatibility)
@app.get("/")
async def root():
    """Redirection vers le frontend"""
    return {"message": "Redriva API - Frontend disponible sur port 5173"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
