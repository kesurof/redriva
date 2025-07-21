"""
Monitoring et métriques pour Redriva Backend
Fournit des métriques Prometheus pour surveiller les performances de l'API
"""

from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
from fastapi import Response
from functools import wraps
import time
from typing import Dict, Any
import logging

# Métriques Prometheus
REQUEST_COUNT = Counter(
    'redriva_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code']
)

REQUEST_DURATION = Histogram(
    'redriva_http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

QUEUE_SIZE = Gauge(
    'redriva_queue_size',
    'Number of items in the queue'
)

ACTIVE_DOWNLOADS = Gauge(
    'redriva_active_downloads',
    'Number of active downloads'
)

TORRENTS_TOTAL = Gauge(
    'redriva_torrents_total',
    'Total number of torrents managed'
)

API_CALLS_RATE_LIMITED = Counter(
    'redriva_api_calls_rate_limited_total',
    'Number of rate-limited API calls to Real-Debrid'
)

logger = logging.getLogger(__name__)

class MetricsCollector:
    """Collecteur de métriques pour Redriva"""
    
    def __init__(self):
        self.start_time = time.time()
    
    def track_request(self, method: str, endpoint: str, status_code: int, duration: float):
        """Enregistre une requête HTTP"""
        REQUEST_COUNT.labels(method=method, endpoint=endpoint, status_code=status_code).inc()
        REQUEST_DURATION.labels(method=method, endpoint=endpoint).observe(duration)
    
    def update_queue_size(self, size: int):
        """Met à jour la taille de la queue"""
        QUEUE_SIZE.set(size)
    
    def update_active_downloads(self, count: int):
        """Met à jour le nombre de téléchargements actifs"""
        ACTIVE_DOWNLOADS.set(count)
    
    def update_torrents_total(self, count: int):
        """Met à jour le nombre total de torrents"""
        TORRENTS_TOTAL.set(count)
    
    def increment_rate_limited_calls(self):
        """Incrémente le compteur d'appels rate-limités"""
        API_CALLS_RATE_LIMITED.inc()

# Instance globale
metrics = MetricsCollector()

def track_metrics(endpoint_name: str = None):
    """Décorateur pour tracker automatiquement les métriques d'un endpoint"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            start_time = time.time()
            status_code = 200
            method = "GET"  # Par défaut, peut être amélioré
            endpoint = endpoint_name or func.__name__
            
            try:
                result = await func(*args, **kwargs)
                return result
            except Exception as e:
                status_code = 500
                logger.error(f"Error in {endpoint}: {e}")
                raise
            finally:
                duration = time.time() - start_time
                metrics.track_request(method, endpoint, status_code, duration)
        
        return wrapper
    return decorator

async def get_metrics() -> Response:
    """Endpoint pour exposer les métriques Prometheus"""
    try:
        # Mettre à jour les métriques avant de les exposer
        # Ces valeurs seraient normalement obtenues depuis les services
        # Pour l'instant, on utilise des valeurs par défaut
        
        return Response(
            content=generate_latest(),
            media_type=CONTENT_TYPE_LATEST
        )
    except Exception as e:
        logger.error(f"Error generating metrics: {e}")
        return Response(
            content="# Error generating metrics\n",
            media_type=CONTENT_TYPE_LATEST,
            status_code=500
        )
