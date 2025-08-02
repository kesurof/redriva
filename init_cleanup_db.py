#!/usr/bin/env python3
"""
Script pour initialiser manuellement les colonnes cleanup dans la base de données
"""

import sqlite3
import os

def init_cleanup_database():
    """Initialise les nouvelles colonnes cleanup dans la base de données"""
    
    db_path = '/home/kesurof/Projet_Gihtub/Redriva/data/symlink.db'
    
    if not os.path.exists(db_path):
        print(f"❌ Base de données non trouvée: {db_path}")
        return False
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Vérifier si la table existe
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='symlink_config'")
        if not cursor.fetchone():
            print("❌ Table symlink_config non trouvée")
            return False
        
        # Nouvelles colonnes cleanup à ajouter
        cleanup_columns = [
            ('cleanup_enabled', 'BOOLEAN DEFAULT 0'),
            ('zurg_path', 'TEXT DEFAULT "/home/kesurof/seedbox/zurg/__all__"'),
            ('cleanup_min_age_days', 'INTEGER DEFAULT 2'),
            ('cleanup_min_size_mb', 'INTEGER DEFAULT 0'),
            ('organized_media_path', 'TEXT DEFAULT "/app/medias"'),
            ('cleanup_dry_run_default', 'BOOLEAN DEFAULT 1'),
            ('rd_api_key', 'TEXT DEFAULT ""'),
            ('cleanup_batch_limit', 'INTEGER DEFAULT 20'),
            ('cleanup_delay_ms', 'INTEGER DEFAULT 1000'),
            ('cleanup_ignore_extensions', 'TEXT DEFAULT ".nfo,.txt,.srt,.jpg,.png,.xml"'),
            ('cleanup_whitelist', 'TEXT DEFAULT ""'),
            ('cleanup_match_threshold', 'INTEGER DEFAULT 80'),
            ('cleanup_max_workers', 'INTEGER DEFAULT 4'),
            ('cleanup_preserve_recent', 'BOOLEAN DEFAULT 1'),
            ('cleanup_detailed_logs', 'BOOLEAN DEFAULT 0'),
            ('cleanup_auto_schedule', 'BOOLEAN DEFAULT 0')
        ]
        
        added_columns = 0
        
        for column_name, column_def in cleanup_columns:
            try:
                cursor.execute(f'ALTER TABLE symlink_config ADD COLUMN {column_name} {column_def}')
                added_columns += 1
                print(f"✅ Colonne ajoutée: {column_name}")
            except sqlite3.OperationalError as e:
                if "duplicate column name" in str(e).lower():
                    print(f"ℹ️  Colonne déjà existante: {column_name}")
                else:
                    print(f"❌ Erreur pour {column_name}: {e}")
        
        conn.commit()
        conn.close()
        
        print(f"\n✅ {added_columns} nouvelles colonnes ajoutées à la base de données")
        return True
        
    except Exception as e:
        print(f"❌ Erreur initialisation DB: {e}")
        return False

if __name__ == "__main__":
    print("🔧 Initialisation des colonnes cleanup dans la base de données...")
    success = init_cleanup_database()
    if success:
        print("🎉 Initialisation terminée avec succès")
    else:
        print("❌ Échec de l'initialisation")
