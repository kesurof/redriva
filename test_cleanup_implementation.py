#!/usr/bin/env python3
"""
Script de test pour valider l'implémentation du cleanup des torrents
selon la roadmap CLEANUP_ROADMAP.md
"""

import sqlite3
import json
import requests
import sys
import os

def test_database_extensions():
    """Teste les extensions de la base de données pour le cleanup"""
    print("🔍 Test des extensions de base de données...")
    
    try:
        db_path = '/home/kesurof/Projet_Gihtub/Redriva/data/symlink.db'
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Vérifier les nouvelles colonnes cleanup
        cursor.execute("PRAGMA table_info(symlink_config)")
        columns = [col[1] for col in cursor.fetchall()]
        
        cleanup_columns = [
            'cleanup_enabled', 'zurg_path', 'cleanup_min_age_days', 'cleanup_min_size_mb',
            'organized_media_path', 'cleanup_dry_run_default', 'rd_api_key',
            'cleanup_batch_limit', 'cleanup_delay_ms', 'cleanup_ignore_extensions',
            'cleanup_whitelist', 'cleanup_match_threshold', 'cleanup_max_workers',
            'cleanup_preserve_recent', 'cleanup_detailed_logs', 'cleanup_auto_schedule'
        ]
        
        missing_columns = [col for col in cleanup_columns if col not in columns]
        
        if missing_columns:
            print(f"❌ Colonnes manquantes: {missing_columns}")
            return False
        else:
            print("✅ Toutes les colonnes cleanup sont présentes")
            return True
            
    except Exception as e:
        print(f"❌ Erreur test DB: {e}")
        return False
    finally:
        if 'conn' in locals():
            conn.close()

def test_api_endpoints():
    """Teste les nouveaux endpoints API cleanup"""
    print("\n🌐 Test des endpoints API cleanup...")
    
    base_url = 'http://localhost:5000'
    endpoints_to_test = [
        ('/api/symlink/cleanup/config', 'GET'),
        ('/api/symlink/cleanup/analyze', 'POST'),
        ('/api/symlink/test/zurg', 'POST'),
        ('/api/symlink/test/realdebrid', 'POST')
    ]
    
    results = []
    
    for endpoint, method in endpoints_to_test:
        try:
            url = base_url + endpoint
            
            if method == 'GET':
                response = requests.get(url, timeout=5)
            else:
                response = requests.post(url, 
                    json={'test': True}, 
                    headers={'Content-Type': 'application/json'},
                    timeout=5
                )
            
            if response.status_code in [200, 400, 500]:  # Connexion OK
                results.append((endpoint, '✅'))
                print(f"   ✅ {endpoint} ({method}) - Status: {response.status_code}")
            else:
                results.append((endpoint, '❌'))
                print(f"   ❌ {endpoint} ({method}) - Status: {response.status_code}")
                
        except requests.exceptions.ConnectionError:
            results.append((endpoint, '🚫'))
            print(f"   🚫 {endpoint} ({method}) - Serveur non accessible")
        except Exception as e:
            results.append((endpoint, '❌'))
            print(f"   ❌ {endpoint} ({method}) - Erreur: {e}")
    
    success_count = sum(1 for _, status in results if status == '✅')
    total_count = len(results)
    
    print(f"\n📊 Résultats endpoints: {success_count}/{total_count} accessibles")
    return success_count == total_count

def test_html_interface():
    """Teste la présence des éléments HTML pour le cleanup"""
    print("\n🌐 Test de l'interface HTML...")
    
    try:
        html_path = '/home/kesurof/Projet_Gihtub/Redriva/src/templates/symlink_tool.html'
        
        if not os.path.exists(html_path):
            print(f"❌ Fichier HTML non trouvé: {html_path}")
            return False
            
        with open(html_path, 'r', encoding='utf-8') as f:
            html_content = f.read()
        
        # Éléments requis selon la roadmap
        required_elements = [
            'id="cleanup-tab"',           # Onglet cleanup
            'id="cleanup-stats"',         # Statistiques
            'id="cleanup-results"',       # Tableau des résultats
            'id="selectAllCleanup"',      # Sélection multiple
            'id="cleanup-torrents-list"', # Liste des torrents
            'analyzeUnusedTorrents(',      # Bouton d'analyse (fonction)
            'id="zurg-path"',             # Configuration Zurg
            'id="cleanup-enabled"',       # Activation cleanup
            'id="rd-api-key"',            # API Key RD
            'testZurgConnection(',        # Test Zurg (fonction)
            'testRealDebridConnection('   # Test RD (fonction)
        ]
        
        missing_elements = []
        for element in required_elements:
            if element not in html_content:
                missing_elements.append(element)
        
        if missing_elements:
            print(f"❌ Éléments HTML manquants: {missing_elements}")
            return False
        else:
            print("✅ Tous les éléments HTML cleanup sont présents")
            return True
            
    except Exception as e:
        print(f"❌ Erreur test HTML: {e}")
        return False

def test_javascript_functions():
    """Teste la présence des fonctions JavaScript pour le cleanup"""
    print("\n📜 Test des fonctions JavaScript...")
    
    try:
        js_path = '/home/kesurof/Projet_Gihtub/Redriva/src/static/js/symlink_tool.js'
        
        if not os.path.exists(js_path):
            print(f"❌ Fichier JS non trouvé: {js_path}")
            return False
            
        with open(js_path, 'r', encoding='utf-8') as f:
            js_content = f.read()
        
        # Fonctions requises selon la roadmap
        required_functions = [
            'function loadCleanup(',
            'function analyzeUnusedTorrents(',
            'function displayCleanupResults(',
            'function updateCleanupSelection(',
            'function toggleSelectAllCleanup(',
            'function clearCleanupSelection(',
            'function confirmCleanupDeletion(',
            'function deleteSelectedCleanupTorrents(',
            'function testZurgConnection(',
            'function testRealDebridConnection(',
            'function saveCleanupConfiguration(',
            'function loadCleanupConfiguration(',
            'function populateCleanupConfigForm('
        ]
        
        missing_functions = []
        for func in required_functions:
            if func not in js_content:
                missing_functions.append(func.replace('function ', '').replace('(', ''))
        
        if missing_functions:
            print(f"❌ Fonctions JS manquantes: {missing_functions}")
            return False
        else:
            print("✅ Toutes les fonctions JavaScript cleanup sont présentes")
            return True
            
    except Exception as e:
        print(f"❌ Erreur test JS: {e}")
        return False

def test_backend_class():
    """Teste la présence de la classe TorrentCleanupAnalyzer"""
    print("\n🐍 Test de la classe backend...")
    
    try:
        backend_path = '/home/kesurof/Projet_Gihtub/Redriva/src/symlink_tool.py'
        
        if not os.path.exists(backend_path):
            print(f"❌ Fichier backend non trouvé: {backend_path}")
            return False
            
        with open(backend_path, 'r', encoding='utf-8') as f:
            backend_content = f.read()
        
        # Méthodes requises selon la roadmap
        required_methods = [
            'class TorrentCleanupAnalyzer:',
            'def scan_zurg_usage(',
            'def normalize_torrent_name(',
            'def find_unused_torrents(',
            'def calculate_age_days(',
            'def delete_torrents_via_rd_api(',
            'def test_zurg_connection(',
            'def test_realdebrid_connection(',
            "@app.route('/api/symlink/cleanup/config'",
            "@app.route('/api/symlink/cleanup/analyze'",
            "@app.route('/api/symlink/cleanup/delete'"
        ]
        
        missing_methods = []
        for method in required_methods:
            if method not in backend_content:
                missing_methods.append(method)
        
        if missing_methods:
            print(f"❌ Méthodes/routes backend manquantes: {missing_methods}")
            return False
        else:
            print("✅ Classe TorrentCleanupAnalyzer et routes complètes")
            return True
            
    except Exception as e:
        print(f"❌ Erreur test backend: {e}")
        return False

def main():
    """Exécute tous les tests de validation"""
    print("🚀 Validation de l'implémentation cleanup des torrents Real-Debrid")
    print("=" * 60)
    
    tests = [
        ("Base de données", test_database_extensions),
        ("Endpoints API", test_api_endpoints),
        ("Interface HTML", test_html_interface),
        ("JavaScript", test_javascript_functions),
        ("Backend Python", test_backend_class)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        print(f"\n📋 Test: {test_name}")
        print("-" * 40)
        result = test_func()
        results.append((test_name, result))
    
    print("\n" + "=" * 60)
    print("📊 RÉSUMÉ DES TESTS")
    print("=" * 60)
    
    success_count = 0
    for test_name, result in results:
        status = "✅ RÉUSSI" if result else "❌ ÉCHEC"
        print(f"   {status:<12} {test_name}")
        if result:
            success_count += 1
    
    total_tests = len(results)
    print(f"\n🎯 Score: {success_count}/{total_tests} tests réussis")
    
    if success_count == total_tests:
        print("🎉 Implémentation cleanup conforme à la roadmap !")
        return True
    else:
        print("⚠️  Implémentation incomplète - voir les erreurs ci-dessus")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
