# API FastAPI pure pour Redriva
import os
import random
import psutil
import time
import asyncio
import aiohttp
import socket
from datetime import datetime, timedelta
from fastapi import FastAPI, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import logging

# Import de nos services
from services.realdebrid import rd_client
from services.data_mapper import map_rd_torrent_to_response, map_rd_torrent_detail_to_response
from services.queue_service import queue_service
from database.auth_db import auth_db

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Fonctions utilitaires pour la surveillance des services
async def check_port_connectivity(host: str, port: int, timeout: float = 5.0) -> bool:
    """Vérifie si un port est accessible"""
    try:
        reader, writer = await asyncio.wait_for(
            asyncio.open_connection(host, port), 
            timeout=timeout
        )
        writer.close()
        await writer.wait_closed()
        return True
    except (OSError, asyncio.TimeoutError):
        return False

async def check_http_health(url: str, timeout: float = 10.0) -> tuple[bool, Optional[int]]:
    """Vérifie la santé d'un service via HTTP et retourne (status, response_time_ms)"""
    try:
        start_time = time.time()
        async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=timeout)) as session:
            async with session.get(url) as response:
                response_time = int((time.time() - start_time) * 1000)
                return response.status < 500, response_time
    except Exception as e:
        logger.debug(f"Erreur HTTP pour {url}: {e}")
        return False, None

async def get_docker_container_info(container_name: str) -> Optional[Dict]:
    """Récupère les informations d'un conteneur Docker via l'API REST"""
    try:
        # Essayer d'accéder à l'API Docker via le socket Unix monté
        # Note: Il faudra monter /var/run/docker.sock dans le conteneur backend
        unix_socket_path = "/var/run/docker.sock"
        if not os.path.exists(unix_socket_path):
            return None
            
        # Pour l'instant, on simule - l'implémentation complète nécessiterait
        # une bibliothèque Docker ou des appels direct à l'API REST
        return {"running": True, "status": "Up"}
    except Exception as e:
        logger.debug(f"Impossible de récupérer les infos Docker pour {container_name}: {e}")
        return None

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
    await queue_service.init()

@app.on_event("shutdown") 
async def shutdown_event():
    await queue_service.close()

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
    cpu_percent: float
    memory: Dict[str, int]  # used, total, available
    disk: Dict[str, int]    # used, total, free
    uptime: str
    load_average: Optional[List[float]] = None
    boot_time: str
    network: Optional[Dict[str, int]] = None

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

class ServiceResponse(BaseModel):
    name: str
    status: str  # 'online', 'offline', 'warning', 'maintenance'
    description: str
    url: Optional[str] = None
    version: Optional[str] = None
    lastCheck: str  # ISO timestamp
    responseTime: Optional[int] = None  # en ms
    uptime: Optional[str] = None
    cpu_usage: Optional[float] = None
    memory_usage: Optional[float] = None
    port: Optional[int] = None

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
    """Récupère les informations système complètes"""
    try:
        # CPU
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Mémoire
        memory = psutil.virtual_memory()
        memory_info = {
            "used": memory.used,
            "total": memory.total,
            "available": memory.available
        }
        
        # Disque (partition racine)
        disk = psutil.disk_usage('/')
        disk_info = {
            "used": disk.used,
            "total": disk.total,
            "free": disk.free
        }
        
        # Uptime
        boot_time = psutil.boot_time()
        uptime_seconds = time.time() - boot_time
        uptime_hours = int(uptime_seconds // 3600)
        uptime_minutes = int((uptime_seconds % 3600) // 60)
        uptime_str = f"{uptime_hours}h {uptime_minutes}m"
        
        # Boot time
        boot_time_str = datetime.fromtimestamp(boot_time).strftime("%Y-%m-%d %H:%M:%S")
        
        # Load average (Linux/Unix seulement)
        load_avg = None
        try:
            load_avg = list(os.getloadavg())
        except (OSError, AttributeError):
            # Pas disponible sur Windows
            pass
        
        # Réseau (optionnel)
        network_info = None
        try:
            net_io = psutil.net_io_counters()
            network_info = {
                "bytes_sent": net_io.bytes_sent,
                "bytes_recv": net_io.bytes_recv
            }
        except:
            pass
        
        return SystemInfoResponse(
            cpu_percent=cpu_percent,
            memory=memory_info,
            disk=disk_info,
            uptime=uptime_str,
            load_average=load_avg,
            boot_time=boot_time_str,
            network=network_info
        )
    except Exception as e:
        logger.error(f"Erreur lors de la récupération des infos système: {e}")
        # Retourner des valeurs par défaut en cas d'erreur
        return SystemInfoResponse(
            cpu_percent=0.0,
            memory={"used": 0, "total": 1, "available": 1},
            disk={"used": 0, "total": 1, "free": 1},
            uptime="Unknown",
            boot_time="Unknown"
        )

@app.get("/api/services", response_model=List[ServiceResponse])
async def get_services():
    """Récupère la liste des services avec leur statut et métriques"""
    try:
        services = []
        
        # Définition des services à surveiller avec leurs vrais conteneurs
        # Utilisation de l'IP de la gateway Docker pour accéder aux services de l'hôte
        docker_host_ip = "172.17.0.1"  # IP de la gateway Docker par défaut
        
        service_configs = [
            {
                "name": "Redriva Backend", 
                "description": "API Backend Redriva",
                "host": docker_host_ip,
                "port": 8080,
                "url": f"http://{docker_host_ip}:8080/api/ping",
                "public_url": "http://localhost:8080",
                "version": "1.0.0",
                "container_name": "redriva-backend"
            },
            {
                "name": "Redriva Frontend",
                "description": "Interface utilisateur web SvelteKit",
                "host": docker_host_ip, 
                "port": 5173,
                "url": f"http://{docker_host_ip}:5173",
                "public_url": "http://localhost:5173",
                "version": "1.0.0",
                "container_name": "redriva-frontend"
            },
            {
                "name": "Sonarr",
                "description": "Gestionnaire de séries TV automatisé",
                "host": docker_host_ip,
                "port": 8989,
                "url": f"http://{docker_host_ip}:8989/api/v3/system/status",
                "public_url": "http://localhost:8989",
                "version": "4.0.0",
                "container_name": "sonarr"
            },
            {
                "name": "Radarr", 
                "description": "Gestionnaire de films automatisé",
                "host": docker_host_ip,
                "port": 7878,
                "url": f"http://{docker_host_ip}:7878/api/v3/system/status",
                "public_url": "http://localhost:7878",
                "version": "5.0.0",
                "container_name": "radarr"
            },
            {
                "name": "Prowlarr",
                "description": "Gestionnaire d'indexeurs",
                "host": docker_host_ip,
                "port": 9696,
                "url": f"http://{docker_host_ip}:9696/api/v1/system/status",
                "public_url": "http://localhost:9696",
                "version": "1.8.6",
                "container_name": "prowlarr"
            },
            {
                "name": "Jackett",
                "description": "Proxy pour indexeurs torrent",
                "host": docker_host_ip,
                "port": 9117,
                "url": f"http://{docker_host_ip}:9117/api/v2.0/server/config",
                "public_url": "http://localhost:9117",
                "version": "0.21.1",
                "container_name": "jackett"
            },
            {
                "name": "RDTClient",
                "description": "Client Real-Debrid",
                "host": docker_host_ip,
                "port": 6500,
                "url": f"http://{docker_host_ip}:6500",
                "public_url": "http://localhost:6500",
                "version": "2.0.0",
                "container_name": "rdtclient"
            }
        ]
        
        # Récupérer l'heure actuelle pour lastCheck
        current_time = datetime.now().isoformat()
        
        # Tester chaque service de manière asynchrone
        tasks = []
        for config in service_configs:
            tasks.append(check_service_status(config))
        
        # Attendre tous les résultats
        service_results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Construire la liste des services
        for i, config in enumerate(service_configs):
            result = service_results[i]
            
            if isinstance(result, Exception):
                # En cas d'exception lors du test
                logger.error(f"Erreur lors du test du service {config['name']}: {result}")
                status = "offline"
                response_time = None
                is_healthy = False
            else:
                is_healthy, response_time = result
                status = "online" if is_healthy else "offline"
            
            service = ServiceResponse(
                name=config["name"],
                status=status,
                description=config["description"],
                url=config.get("public_url"),
                version=config.get("version"),
                lastCheck=current_time,
                responseTime=response_time,
                uptime=None,  # On ne peut pas facilement obtenir l'uptime des autres conteneurs
                cpu_usage=None,  # Idem pour CPU
                memory_usage=None,  # Idem pour mémoire
                port=config.get("port")
            )
            
            services.append(service)
        
        logger.info(f"Récupéré {len(services)} services")
        return services
        
    except Exception as e:
        logger.error(f"Erreur lors de la récupération des services: {e}")
        # En cas d'erreur, retourner une liste vide
        return []

async def check_service_status(config: Dict) -> tuple[bool, Optional[int]]:
    """Vérifie le statut d'un service spécifique"""
    try:
        # D'abord, tester la connectivité du port
        port_open = await check_port_connectivity(config["host"], config["port"], timeout=3.0)
        
        if not port_open:
            return False, None
        
        # Si le port est ouvert, tester l'endpoint HTTP si disponible
        if "url" in config:
            return await check_http_health(config["url"], timeout=5.0)
        else:
            # Port ouvert mais pas d'endpoint HTTP - considérer comme en ligne
            return True, 50  # Temps de réponse simulé
            
    except Exception as e:
        logger.debug(f"Erreur lors du test de {config['name']}: {e}")
        return False, None

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

@app.post("/api/admin/sync-torrents")
async def sync_torrents():
    """Lance la synchronisation des torrents via la file d'attente"""
    job_id = await queue_service.enqueue_task("sync_torrents_task")
    if job_id:
        return {"success": True, "message": "Synchronisation des torrents démarrée", "job_id": job_id}
    else:
        return {"success": False, "message": "Erreur lors du lancement de la synchronisation"}

@app.post("/api/admin/update-quotas")
async def update_quotas():
    """Lance la mise à jour des quotas via la file d'attente"""
    job_id = await queue_service.enqueue_task("update_quotas_task")
    if job_id:
        return {"success": True, "message": "Mise à jour des quotas démarrée", "job_id": job_id}
    else:
        return {"success": False, "message": "Erreur lors du lancement de la mise à jour"}

@app.get("/api/admin/job/{job_id}")
async def get_job_status(job_id: str):
    """Récupère le statut d'une tâche"""
    status = await queue_service.get_job_status(job_id)
    if status:
        return status
    else:
        raise HTTPException(status_code=404, detail="Tâche non trouvée")

@app.post("/api/admin/update-torrents")
async def update_torrents(background_tasks: BackgroundTasks):
    """Met à jour les torrents en arrière-plan (legacy - sera supprimé)"""
    # TODO: Implémenter la logique de mise à jour
    background_tasks.add_task(lambda: print("Mise à jour des torrents démarrée"))
    return {"success": True, "message": "Mise à jour des torrents démarrée"}

@app.post("/api/admin/sync")
async def sync_with_real_debrid(background_tasks: BackgroundTasks):
    """Synchronise avec Real-Debrid en arrière-plan (legacy - sera supprimé)"""
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
