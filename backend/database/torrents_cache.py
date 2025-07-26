import sqlite3
import json
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
import os

class TorrentsCache:
    def __init__(self, db_path: str = "data/torrents_cache.db"):
        self.db_path = db_path
        # Créer le répertoire si nécessaire
        os.makedirs(os.path.dirname(db_path), exist_ok=True)
        self.init_db()
    
    def init_db(self):
        """Initialise la base de données avec les tables (schéma RDM amélioré)"""
        with sqlite3.connect(self.db_path) as conn:
            # Table principale avec schéma RDM
            conn.execute("""
                CREATE TABLE IF NOT EXISTS torrents (
                    id TEXT PRIMARY KEY,
                    filename TEXT,
                    status TEXT,
                    size INTEGER,
                    added INTEGER,
                    links TEXT,  -- JSON array format RDM
                    host TEXT,
                    progress INTEGER DEFAULT 0,
                    seeders INTEGER,
                    speed INTEGER,
                    split INTEGER DEFAULT 0,
                    cached_at INTEGER DEFAULT (strftime('%s', 'now')),
                    expires_at TIMESTAMP NOT NULL
                )
            """)
            
            # Index pour performance (pattern RDM)
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_torrents_expires_at 
                ON torrents(expires_at)
            """)
            
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_torrents_status 
                ON torrents(status)
            """)
            
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_torrents_added 
                ON torrents(added DESC)
            """)
            
            # Table de métadonnées
            conn.execute("""
                CREATE TABLE IF NOT EXISTS cache_metadata (
                    key TEXT PRIMARY KEY,
                    value TEXT NOT NULL,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
    
    def set_torrents(self, torrents: List[Dict[str, Any]], ttl_hours: int = 24):
        """Sauvegarde les torrents en cache avec format RDM optimisé"""
        expires_at = datetime.now() + timedelta(hours=ttl_hours)
        
        with sqlite3.connect(self.db_path) as conn:
            # Vider le cache existant
            conn.execute("DELETE FROM torrents")
            
            # Insérer les nouveaux torrents avec schéma RDM
            for torrent in torrents:
                torrent_id = torrent.get('id', torrent.get('hash', str(hash(str(torrent)))))
                
                # Extraction des champs RDM
                filename = torrent.get('filename', torrent.get('original_filename', ''))
                status = torrent.get('status', 'unknown')
                size = torrent.get('bytes', torrent.get('size', 0))
                added = torrent.get('added', 0)
                links = json.dumps(torrent.get('links', []))  # JSON format RDM
                host = torrent.get('host', '')
                progress = torrent.get('progress', 0)
                seeders = torrent.get('seeders')
                speed = torrent.get('speed')
                split = torrent.get('split', 0)
                
                conn.execute("""
                    INSERT OR REPLACE INTO torrents 
                    (id, filename, status, size, added, links, host, progress, 
                     seeders, speed, split, expires_at) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (torrent_id, filename, status, size, added, links, host, 
                     progress, seeders, speed, split, expires_at))
            
            # Mettre à jour les métadonnées
            conn.execute("""
                INSERT OR REPLACE INTO cache_metadata 
                (key, value) VALUES ('last_update', ?)
            """, (datetime.now().isoformat(),))
            
            conn.execute("""
                INSERT OR REPLACE INTO cache_metadata 
                (key, value) VALUES ('total_count', ?)
            """, (str(len(torrents)),))
    
    def get_torrents(self) -> Optional[List[Dict[str, Any]]]:
        """Récupère les torrents du cache avec format RDM"""
        with sqlite3.connect(self.db_path) as conn:
            # Supprimer les entrées expirées
            conn.execute("DELETE FROM torrents WHERE expires_at < ?", (datetime.now(),))
            
            # Récupérer les torrents avec tous les champs RDM
            cursor = conn.execute("""
                SELECT id, filename, status, size, added, links, host, 
                       progress, seeders, speed, split, cached_at
                FROM torrents 
                WHERE expires_at > ?
                ORDER BY added DESC
            """, (datetime.now(),))
            
            rows = cursor.fetchall()
            if not rows:
                return None
            
            # Reconstruire les objets torrent format RDM
            torrents = []
            for row in rows:
                torrent = {
                    'id': row[0],
                    'filename': row[1],
                    'original_filename': row[1],  # Compatibilité
                    'status': row[2],
                    'bytes': row[3],
                    'size': row[3],  # Compatibilité
                    'added': row[4],
                    'links': json.loads(row[5]) if row[5] else [],
                    'host': row[6],
                    'progress': row[7],
                    'seeders': row[8],
                    'speed': row[9],
                    'split': row[10],
                    'cached_at': row[11]
                }
                torrents.append(torrent)
            
            return torrents
    
    def is_cache_valid(self) -> bool:
        """Vérifie si le cache est encore valide"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("""
                SELECT COUNT(*) FROM torrents 
                WHERE expires_at > ?
            """, (datetime.now(),))
            
            count = cursor.fetchone()[0]
            return count > 0
    
    def get_cache_info(self) -> Dict[str, Any]:
        """Retourne les informations sur le cache avec stats RDM"""
        with sqlite3.connect(self.db_path) as conn:
            # Compter les entrées valides
            cursor = conn.execute("""
                SELECT COUNT(*) FROM torrents 
                WHERE expires_at > ?
            """, (datetime.now(),))
            valid_count = cursor.fetchone()[0]
            
            # Stats par statut (pattern RDM)
            cursor = conn.execute("""
                SELECT status, COUNT(*) FROM torrents 
                WHERE expires_at > ?
                GROUP BY status
            """, (datetime.now(),))
            status_stats = dict(cursor.fetchall())
            
            # Récupérer les métadonnées
            cursor = conn.execute("""
                SELECT key, value, updated_at FROM cache_metadata
            """)
            metadata = {}
            for row in cursor.fetchall():
                metadata[row[0]] = {
                    'value': row[1],
                    'updated_at': row[2]
                }
            
            return {
                'valid_entries': valid_count,
                'status_distribution': status_stats,
                'last_update': metadata.get('last_update', {}).get('value'),
                'total_cached': metadata.get('total_count', {}).get('value', '0'),
                'cache_file': self.db_path
            }
    
    def clear_cache(self):
        """Vide complètement le cache"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("DELETE FROM torrents")
            conn.execute("DELETE FROM cache_metadata")
    
    def cleanup_expired(self):
        """Nettoie les entrées expirées"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("""
                DELETE FROM torrents WHERE expires_at < ?
            """, (datetime.now(),))
            return cursor.rowcount
