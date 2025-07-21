"""
Gestionnaire de base de données pour l'authentification
"""
import aiosqlite
import os
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class AuthDatabase:
    def __init__(self, db_path: str = "/app/data/auth.db"):
        self.db_path = db_path
        os.makedirs(os.path.dirname(db_path), exist_ok=True)
    
    async def init_db(self):
        """Initialise la base de données avec les tables nécessaires"""
        async with aiosqlite.connect(self.db_path) as db:
            await db.execute("""
                CREATE TABLE IF NOT EXISTS auth_tokens (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    access_token TEXT NOT NULL,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            await db.execute("""
                CREATE TABLE IF NOT EXISTS device_codes (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    device_code TEXT NOT NULL UNIQUE,
                    user_code TEXT NOT NULL,
                    verification_url TEXT NOT NULL,
                    expires_in INTEGER NOT NULL,
                    interval_time INTEGER NOT NULL,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            await db.commit()
            logger.info("Base de données d'authentification initialisée")
    
    async def store_access_token(self, access_token: str):
        """Stocke ou met à jour le token d'accès"""
        async with aiosqlite.connect(self.db_path) as db:
            # Supprimer l'ancien token s'il existe
            await db.execute("DELETE FROM auth_tokens")
            
            # Insérer le nouveau token
            await db.execute(
                "INSERT INTO auth_tokens (access_token) VALUES (?)",
                (access_token,)
            )
            await db.commit()
            logger.info("Token d'accès stocké avec succès")
    
    async def get_access_token(self) -> Optional[str]:
        """Récupère le token d'accès stocké"""
        async with aiosqlite.connect(self.db_path) as db:
            cursor = await db.execute(
                "SELECT access_token FROM auth_tokens ORDER BY created_at DESC LIMIT 1"
            )
            row = await cursor.fetchone()
            return row[0] if row else None
    
    async def store_device_code(self, device_code: str, user_code: str, 
                               verification_url: str, expires_in: int, interval_time: int):
        """Stocke les informations du device code"""
        async with aiosqlite.connect(self.db_path) as db:
            await db.execute("""
                INSERT INTO device_codes (device_code, user_code, verification_url, expires_in, interval_time)
                VALUES (?, ?, ?, ?, ?)
            """, (device_code, user_code, verification_url, expires_in, interval_time))
            await db.commit()
            logger.info(f"Device code stocké: {user_code}")
    
    async def get_device_code_info(self, device_code: str) -> Optional[dict]:
        """Récupère les informations d'un device code"""
        async with aiosqlite.connect(self.db_path) as db:
            cursor = await db.execute("""
                SELECT device_code, user_code, verification_url, expires_in, interval_time, created_at
                FROM device_codes 
                WHERE device_code = ?
                ORDER BY created_at DESC LIMIT 1
            """, (device_code,))
            row = await cursor.fetchone()
            
            if row:
                return {
                    "device_code": row[0],
                    "user_code": row[1],
                    "verification_url": row[2],
                    "expires_in": row[3],
                    "interval_time": row[4],
                    "created_at": row[5]
                }
            return None
    
    async def clear_expired_device_codes(self):
        """Nettoie les device codes expirés"""
        async with aiosqlite.connect(self.db_path) as db:
            await db.execute("""
                DELETE FROM device_codes 
                WHERE datetime(created_at, '+' || expires_in || ' seconds') < datetime('now')
            """)
            await db.commit()
    
    async def is_authenticated(self) -> bool:
        """Vérifie si l'utilisateur est authentifié"""
        token = await self.get_access_token()
        return token is not None

# Instance globale
auth_db = AuthDatabase()
