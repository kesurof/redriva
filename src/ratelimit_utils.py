# ratelimit_utils.py : rate limiting simple en mémoire pour FastAPI
import time
from fastapi import Request, HTTPException
from functools import wraps
from typing import Callable

# Limite : 10 requêtes par minute par IP
RATE_LIMIT = 10
RATE_PERIOD = 60  # secondes

# Dictionnaire {ip: [timestamps]}
_rate_limit_store = {}

def rate_limited(endpoint_name: str):
    import inspect
    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            request: Request = kwargs.get('request')
            if request is None:
                # Recherche dans args si non trouvé dans kwargs
                for arg in args:
                    if isinstance(arg, Request):
                        request = arg
                        break
            ip = request.client.host if request else 'unknown'
            now = time.time()
            timestamps = _rate_limit_store.get(ip, [])
            # On ne garde que les timestamps récents
            timestamps = [t for t in timestamps if now - t < RATE_PERIOD]
            if len(timestamps) >= RATE_LIMIT:
                raise HTTPException(status_code=429, detail=f"Trop de requêtes sur {endpoint_name}. Réessayez plus tard.")
            timestamps.append(now)
            _rate_limit_store[ip] = timestamps
            result = func(*args, **kwargs)
            import inspect
            if inspect.isawaitable(result):
                return await result
            return result
        return wrapper
    return decorator
