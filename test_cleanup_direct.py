#!/usr/bin/env python3
"""
Test direct des fonctions cleanup sans dépendre du serveur web
"""

import sys
import os

# Ajouter le répertoire src au PYTHONPATH
sys.path.insert(0, '/home/kesurof/Projet_Gihtub/Redriva/src')

try:
    from symlink_tool import TorrentCleanupAnalyzer, init_symlink_database
    
    def test_cleanup_analyzer():
        """Test direct de la classe TorrentCleanupAnalyzer"""
        print("🧪 Test direct de TorrentCleanupAnalyzer...")
        
        try:
            # Initialiser la base de données
            init_symlink_database()
            print("✅ Base de données initialisée")
            
            # Créer une instance de l'analyseur
            analyzer = TorrentCleanupAnalyzer()
            print("✅ TorrentCleanupAnalyzer instancié")
            
            # Test de la connexion Zurg
            zurg_result = analyzer.test_zurg_connection()
            print(f"🔍 Test Zurg: {zurg_result}")
            
            # Test de scan Zurg (même si le montage n'existe pas)
            used_torrents = analyzer.scan_zurg_usage()
            print(f"✅ Scan Zurg réussi: {len(used_torrents)} torrents utilisés")
            
            # Test de normalisation des noms
            test_name = "Test.Movie.2023.1080p.BluRay.x264-GROUP"
            normalized = analyzer.normalize_torrent_name(test_name)
            print(f"✅ Normalisation: '{test_name}' -> '{normalized}'")
            
            # Test des fonctions de format
            formatted_size = analyzer._format_size(1024 * 1024 * 1024)  # 1GB
            print(f"✅ Formatage taille: 1GB -> {formatted_size}")
            
            # Test de calcul d'âge
            age = analyzer.calculate_age_days("2024-01-01 00:00:00")
            print(f"✅ Calcul âge: {age} jours depuis 2024-01-01")
            
            return True
            
        except Exception as e:
            print(f"❌ Erreur test analyzer: {e}")
            return False
    
    def test_database_functions():
        """Test des fonctions de base de données"""
        print("\n💾 Test des fonctions de base de données...")
        
        try:
            import sqlite3
            
            db_path = '/home/kesurof/Projet_Gihtub/Redriva/data/symlink.db'
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()
            
            # Test d'insertion d'une configuration par défaut
            cursor.execute("DELETE FROM symlink_config")  # Nettoyer
            cursor.execute("""
                INSERT INTO symlink_config (
                    media_path, max_workers, cleanup_enabled, zurg_path, cleanup_min_age_days
                ) VALUES (?, ?, ?, ?, ?)
            """, ('/app/medias', 6, 1, '/home/kesurof/seedbox/zurg/__all__', 2))
            
            conn.commit()
            
            # Test de lecture
            cursor.execute("SELECT * FROM symlink_config LIMIT 1")
            row = cursor.fetchone()
            
            if row:
                columns = [description[0] for description in cursor.description]
                config = dict(zip(columns, row))
                print(f"✅ Configuration test insérée et lue: {len(config)} paramètres")
                
                # Vérifier les nouveaux champs cleanup
                cleanup_fields = ['cleanup_enabled', 'zurg_path', 'cleanup_min_age_days']
                missing_fields = [field for field in cleanup_fields if field not in config]
                
                if missing_fields:
                    print(f"❌ Champs manquants: {missing_fields}")
                    return False
                else:
                    print("✅ Tous les champs cleanup présents")
                    return True
            else:
                print("❌ Impossible de lire la configuration")
                return False
                
            conn.close()
            
        except Exception as e:
            print(f"❌ Erreur test DB: {e}")
            return False
    
    def main():
        print("🧪 Test direct des fonctions cleanup")
        print("=" * 50)
        
        # Test de la base de données
        db_success = test_database_functions()
        
        # Test de l'analyseur
        analyzer_success = test_cleanup_analyzer()
        
        print("\n" + "=" * 50)
        print("📊 RÉSULTATS")
        print("=" * 50)
        
        print(f"   {'✅ RÉUSSI' if db_success else '❌ ÉCHEC':<12} Base de données")
        print(f"   {'✅ RÉUSSI' if analyzer_success else '❌ ÉCHEC':<12} TorrentCleanupAnalyzer")
        
        if db_success and analyzer_success:
            print("\n🎉 Tous les tests directs sont réussis !")
            print("📝 Note: Les endpoints API nécessitent un redémarrage du serveur")
            return True
        else:
            print("\n❌ Certains tests ont échoué")
            return False
    
    if __name__ == "__main__":
        success = main()
        sys.exit(0 if success else 1)
        
except ImportError as e:
    print(f"❌ Erreur d'import: {e}")
    print("📝 Assurez-vous que le module symlink_tool est accessible")
    sys.exit(1)
