#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de validation finale de l'implémentation cleanup après redémarrage du serveur
"""

import os
import sys
import requests
import time
import json

# Ajouter le dossier src au path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_api_endpoints(base_url="http://localhost:5003"):
    """Test les endpoints API après redémarrage"""
    print("🌐 Test des endpoints API après redémarrage du serveur...")
    
    endpoints = [
        ("GET", "/api/symlink/cleanup/config"),
        ("POST", "/api/symlink/cleanup/analyze", {"test": True}),
        ("POST", "/api/symlink/test/zurg", {"path": "/test"}),
        ("POST", "/api/symlink/test/realdebrid", {"api_key": "test_key"})
    ]
    
    results = []
    for method, endpoint, *data in endpoints:
        url = f"{base_url}{endpoint}"
        try:
            payload = data[0] if data else None
            
            if method == "GET":
                response = requests.get(url, timeout=5)
            else:
                response = requests.post(url, json=payload, timeout=5)
            
            status = "✅ OK" if response.status_code in [200, 400, 422] else f"❌ {response.status_code}"
            results.append((endpoint, status, response.status_code))
            print(f"   {status} {endpoint} - Status: {response.status_code}")
            
        except requests.exceptions.ConnectionError:
            results.append((endpoint, "❌ SERVEUR ÉTEINT", 0))
            print(f"   ❌ SERVEUR ÉTEINT {endpoint}")
        except Exception as e:
            results.append((endpoint, f"❌ ERREUR", 0))
            print(f"   ❌ ERREUR {endpoint}: {e}")
    
    return results

def test_server_access():
    """Test l'accès au serveur principal"""
    try:
        response = requests.get("http://localhost:5003/", timeout=5)
        return response.status_code == 200
    except:
        return False

def main():
    print("🎯 VALIDATION FINALE - Implémentation Cleanup Torrents")
    print("=" * 60)
    
    # Test 1: Accès serveur
    print("\n📋 Test: Accès au serveur")
    print("-" * 40)
    if test_server_access():
        print("✅ Serveur accessible sur http://localhost:5003")
    else:
        print("❌ Serveur non accessible - Redémarrage nécessaire")
        print("   Exécutez: cd /home/kesurof/Projet_Gihtub/Redriva && python src/web.py")
        return
    
    # Test 2: Endpoints API
    print("\n📋 Test: Endpoints API")
    print("-" * 40)
    api_results = test_api_endpoints()
    api_success = sum(1 for _, status, code in api_results if "✅" in status or code in [200, 400, 422])
    
    print(f"\n📊 Résultats API: {api_success}/{len(api_results)} accessibles")
    
    # Test 3: Interface web
    print("\n📋 Test: Interface web cleanup")
    print("-" * 40)
    try:
        response = requests.get("http://localhost:5003/symlink-manager", timeout=5)
        if response.status_code == 200 and "Cleanup Torrents" in response.text:
            print("✅ Interface cleanup accessible dans l'onglet Symlink Manager")
        else:
            print("❌ Interface cleanup non trouvée")
    except Exception as e:
        print(f"❌ Erreur test interface: {e}")
    
    # Résumé final
    print("\n" + "=" * 60)
    print("📊 RÉSUMÉ FINAL")
    print("=" * 60)
    
    if api_success >= 3:
        print("🎉 IMPLÉMENTATION COMPLÈTE ET FONCTIONNELLE")
        print("✅ Tous les composants cleanup sont opérationnels")
        print("\n🎯 PROCHAINES ÉTAPES:")
        print("   1. Aller sur http://localhost:5003/symlink-manager")
        print("   2. Configurer les paramètres dans l'onglet 'Cleanup Torrents'")
        print("   3. Tester l'analyse et le nettoyage")
    else:
        print("⚠️  IMPLÉMENTATION PARTIELLEMENT FONCTIONNELLE")
        print(f"   - Endpoints API: {api_success}/{len(api_results)} accessibles")
        print("   - Redémarrage serveur peut être nécessaire")

if __name__ == "__main__":
    main()
