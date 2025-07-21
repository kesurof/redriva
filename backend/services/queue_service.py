"""
Service de file d'attente avec ARQ pour les tâches asynchrones
"""
import asyncio
import logging
from datetime import datetime
from typing import Any, Dict, Optional

import redis.asyncio as redis
from arq import ArqRedis, Worker, create_pool
from arq.connections import RedisSettings

# Configuration
REDIS_SETTINGS = RedisSettings(
    host='redis',  # Nom du service Redis dans Docker
    port=6379,
    database=0,
)

logger = logging.getLogger(__name__)

class QueueService:
    """Service de gestion de la file d'attente"""
    
    def __init__(self):
        self.redis: Optional[ArqRedis] = None
    
    async def init(self):
        """Initialise la connexion Redis"""
        try:
            self.redis = await create_pool(REDIS_SETTINGS)
            logger.info("Connexion Redis établie pour la file d'attente")
        except Exception as e:
            logger.error(f"Erreur de connexion Redis: {e}")
            self.redis = None
    
    async def close(self):
        """Ferme la connexion Redis"""
        if self.redis:
            await self.redis.close()
    
    async def enqueue_task(self, task_name: str, *args, **kwargs) -> Optional[str]:
        """Ajoute une tâche à la file d'attente"""
        if not self.redis:
            logger.error("Redis non initialisé")
            return None
        
        try:
            job = await self.redis.enqueue_job(task_name, *args, **kwargs)
            logger.info(f"Tâche {task_name} ajoutée à la file: {job.job_id}")
            return job.job_id
        except Exception as e:
            logger.error(f"Erreur lors de l'ajout de la tâche {task_name}: {e}")
            return None
    
    async def get_job_status(self, job_id: str) -> Optional[Dict[str, Any]]:
        """Récupère le statut d'une tâche"""
        if not self.redis:
            return None
        
        try:
            job = await self.redis.get_job(job_id)
            if not job:
                return None
            
            return {
                "job_id": job.job_id,
                "status": job.status,
                "result": job.result,
                "start_time": job.start_time,
                "finish_time": job.finish_time,
                "function": job.function,
            }
        except Exception as e:
            logger.error(f"Erreur lors de la récupération du job {job_id}: {e}")
            return None

# Instance globale
queue_service = QueueService()

# Tâches ARQ
async def sync_torrents_task(ctx: Dict) -> Dict[str, Any]:
    """Tâche de synchronisation des torrents"""
    logger.info("Début de la synchronisation des torrents")
    
    try:
        # Simuler le travail de synchronisation
        await asyncio.sleep(2)
        
        # Ici, on appellerait le service Real-Debrid
        result = {
            "status": "success",
            "torrents_synced": 42,
            "timestamp": datetime.now().isoformat()
        }
        
        logger.info(f"Synchronisation terminée: {result}")
        return result
        
    except Exception as e:
        logger.error(f"Erreur lors de la synchronisation: {e}")
        return {
            "status": "error",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }

async def update_quotas_task(ctx: Dict) -> Dict[str, Any]:
    """Tâche de mise à jour des quotas"""
    logger.info("Début de la mise à jour des quotas")
    
    try:
        # Simuler le travail de mise à jour
        await asyncio.sleep(1)
        
        result = {
            "status": "success",
            "quotas_updated": True,
            "timestamp": datetime.now().isoformat()
        }
        
        logger.info(f"Mise à jour des quotas terminée: {result}")
        return result
        
    except Exception as e:
        logger.error(f"Erreur lors de la mise à jour des quotas: {e}")
        return {
            "status": "error",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }

# Configuration du worker ARQ
class WorkerSettings:
    """Configuration du worker ARQ"""
    functions = [sync_torrents_task, update_quotas_task]
    redis_settings = REDIS_SETTINGS
    on_startup = None
    on_shutdown = None
    max_jobs = 10
    job_timeout = 300  # 5 minutes
