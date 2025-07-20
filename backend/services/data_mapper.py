"""
Utilitaires de mapping pour les données Real-Debrid
"""
from typing import Dict, Any, List
from datetime import datetime

def map_rd_torrent_to_response(rd_torrent: Dict[str, Any]) -> Dict[str, Any]:
    """
    Mappe un torrent Real-Debrid vers le format attendu par le frontend
    """
    return {
        "id": rd_torrent.get("id", ""),
        "name": rd_torrent.get("filename", "Nom non disponible"),
        "size": rd_torrent.get("bytes", 0),
        "progress": rd_torrent.get("progress", 0),
        "status": map_rd_status(rd_torrent.get("status", "")),
        "added_date": rd_torrent.get("added", ""),
        "speed": format_speed(rd_torrent.get("speed", 0)),
        "category": "Torrent"  # Real-Debrid ne fournit pas de catégorie
    }

def map_rd_torrent_detail_to_response(rd_torrent: Dict[str, Any]) -> Dict[str, Any]:
    """
    Mappe les détails d'un torrent Real-Debrid vers le format attendu
    """
    base_data = map_rd_torrent_to_response(rd_torrent)
    
    # Ajouter les fichiers si disponibles
    files = []
    if "files" in rd_torrent and rd_torrent["files"]:
        files = [
            {
                "id": file_data.get("id", idx),
                "name": file_data.get("path", f"Fichier {idx + 1}"),
                "size": file_data.get("bytes", 0),
                "progress": 100 if file_data.get("selected", 0) == 1 else 0
            }
            for idx, file_data in enumerate(rd_torrent["files"])
        ]
    
    base_data["files"] = files
    return base_data

def map_rd_status(rd_status: str) -> str:
    """
    Mappe les statuts Real-Debrid vers des statuts lisibles
    """
    status_mapping = {
        "magnet_error": "Erreur",
        "magnet_conversion": "Conversion",
        "waiting_files_selection": "En attente",
        "queued": "En file",
        "downloading": "Téléchargement",
        "downloaded": "Terminé",
        "error": "Erreur",
        "virus": "Virus détecté",
        "compressing": "Compression",
        "uploading": "Upload"
    }
    return status_mapping.get(rd_status, rd_status.capitalize())

def format_speed(speed_bytes: int) -> str:
    """
    Formate la vitesse en unités lisibles
    """
    if speed_bytes == 0:
        return "0 B/s"
    
    units = ["B/s", "KB/s", "MB/s", "GB/s"]
    size = float(speed_bytes)
    unit_index = 0
    
    while size >= 1024 and unit_index < len(units) - 1:
        size /= 1024
        unit_index += 1
    
    return f"{size:.1f} {units[unit_index]}"
