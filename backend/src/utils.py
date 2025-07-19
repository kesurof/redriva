# Fonctions utilitaires pour Redriva


def normalize_torrent(t):
    return {
        "id": t.get("id"),
        "filename": t.get("filename"),
        "status": t.get("status"),
        "size": t.get("bytes"),
    }

def get_rd_token():
    import os
    token = os.environ.get("RD_TOKEN")
    if not token:
        raise RuntimeError("Token Real-Debrid manquant : exportez RD_TOKEN côté serveur.")
    return token
