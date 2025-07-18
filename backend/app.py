# --- File d’attente/priorités ---
import sqlite3
from fastapi import Request
from typing import Optional

DB_PATH = "data/redriva.db"

def get_db():
    return sqlite3.connect(DB_PATH)

@app.get("/api/queue")
def get_queue():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, torrent_id, priority, status, added_at, updated_at FROM queue ORDER BY priority ASC, added_at ASC")
    rows = cur.fetchall()
    conn.close()
    return [{
        "id": row[0],
        "torrent_id": row[1],
        "priority": row[2],
        "status": row[3],
        "added_at": row[4],
        "updated_at": row[5]
    } for row in rows]

@app.post("/api/queue")
def add_to_queue(item: dict):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO queue (torrent_id, priority, status) VALUES (?, ?, ?)",
        (item.get("torrent_id"), item.get("priority", 10), item.get("status", "pending"))
    )
    conn.commit()
    queue_id = cur.lastrowid
    conn.close()
    return {"id": queue_id}

@app.patch("/api/queue/{queue_id}")
def update_queue(queue_id: int, item: dict):
    conn = get_db()
    cur = conn.cursor()
    fields = []
    values = []
    for k in ["priority", "status"]:
        if k in item:
            fields.append(f"{k} = ?")
            values.append(item[k])
    if not fields:
        conn.close()
        return {"error": "Aucune donnée à mettre à jour"}
    values.append(queue_id)
    cur.execute(f"UPDATE queue SET {', '.join(fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", values)
    conn.commit()
    conn.close()
    return {"success": True}

@app.delete("/api/queue/{queue_id}")
def delete_queue(queue_id: int):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM queue WHERE id = ?", (queue_id,))
    conn.commit()
    conn.close()
    return {"success": True}
# Endpoint pour aide & support (exemple statique)
@app.get("/api/support")
def get_support():
    return {
        "faq": [
            {"q": "Comment ajouter un torrent ?", "a": "Utilisez le bouton 'Ajouter' sur le dashboard ou la page Torrents."},
            {"q": "Où trouver mon token Real-Debrid ?", "a": "Connectez-vous sur real-debrid.com, section 'Mon compte' > 'Applications'"},
            {"q": "Comment signaler un bug ?", "a": "Ouvrez une issue sur GitHub ou contactez le support via le formulaire."}
        ],
        "links": [
            {"label": "Documentation", "url": "https://github.com/kesurof/redriva#readme"},
            {"label": "FAQ complète", "url": "https://github.com/kesurof/redriva/wiki/FAQ"},
            {"label": "Support GitHub", "url": "https://github.com/kesurof/redriva/issues"}
        ]
    }
# Endpoint pour informations système (exemple statique)
@app.get("/api/system")
def get_system_info():
    return {
        "version": "1.0.0",
        "backend_status": "ok",
        "last_backup": "2025-07-17T23:59:00"
    }
# Backend minimal pour Redriva (FastAPI)
from fastapi import FastAPI
from fastapi.responses import JSONResponse
import sqlite3
from typing import Optional

app = FastAPI()

# --- File d’attente/priorités ---
DB_PATH = "data/redriva.db"

def get_db():
    return sqlite3.connect(DB_PATH)

@app.get("/api/queue")
def get_queue():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, torrent_id, priority, status, added_at, updated_at FROM queue ORDER BY priority ASC, added_at ASC")
    rows = cur.fetchall()
    conn.close()
    return [{
        "id": row[0],
        "torrent_id": row[1],
        "priority": row[2],
        "status": row[3],
        "added_at": row[4],
        "updated_at": row[5]
    } for row in rows]

@app.post("/api/queue")
def add_to_queue(item: dict):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO queue (torrent_id, priority, status) VALUES (?, ?, ?)",
        (item.get("torrent_id"), item.get("priority", 10), item.get("status", "pending"))
    )
    conn.commit()
    queue_id = cur.lastrowid
    conn.close()
    return {"id": queue_id}

@app.patch("/api/queue/{queue_id}")
def update_queue(queue_id: int, item: dict):
    conn = get_db()
    cur = conn.cursor()
    fields = []
    values = []
    for k in ["priority", "status"]:
        if k in item:
            fields.append(f"{k} = ?")
            values.append(item[k])
    if not fields:
        conn.close()
        return {"error": "Aucune donnée à mettre à jour"}
    values.append(queue_id)
    cur.execute(f"UPDATE queue SET {', '.join(fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", values)
    conn.commit()
    conn.close()
    return {"success": True}

@app.delete("/api/queue/{queue_id}")
def delete_queue(queue_id: int):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM queue WHERE id = ?", (queue_id,))
    conn.commit()
    conn.close()
    return {"success": True}

@app.get("/api/support")
def get_support():
    return {
        "faq": [
            {"q": "Comment ajouter un torrent ?", "a": "Utilisez le bouton 'Ajouter' sur le dashboard ou la page Torrents."},
            {"q": "Où trouver mon token Real-Debrid ?", "a": "Connectez-vous sur real-debrid.com, section 'Mon compte' > 'Applications'"},
            {"q": "Comment signaler un bug ?", "a": "Ouvrez une issue sur GitHub ou contactez le support via le formulaire."}
        ],
        "links": [
            {"label": "Documentation", "url": "https://github.com/kesurof/redriva#readme"},
            {"label": "FAQ complète", "url": "https://github.com/kesurof/redriva/wiki/FAQ"},
            {"label": "Support GitHub", "url": "https://github.com/kesurof/redriva/issues"}
        ]
    }

@app.get("/api/system")
def get_system_info():
    return {
        "version": "1.0.0",
        "backend_status": "ok",
        "last_backup": "2025-07-17T23:59:00"
    }

@app.get("/api/ping")
def ping():
    return {"status": "ok"}



# Endpoint pour l'utilisation des quotas Real-Debrid (exemple statique)
@app.get("/api/quotas")
def get_quotas():
    # À remplacer par un appel réel à l'API Real-Debrid
    return {
        "quota_rest": 12,  # en Go
        "slots_used": 3,
        "slots_total": 5
    }

# Endpoint pour logs récents (exemple statique)
@app.get("/api/logs")
def get_logs():
    # À remplacer par lecture réelle des logs
    return {
        "logs": [
            {"timestamp": "2025-07-18T10:12:00", "level": "INFO", "message": "Démarrage du backend"},
            {"timestamp": "2025-07-18T10:13:12", "level": "WARNING", "message": "Quota presque atteint"},
            {"timestamp": "2025-07-18T10:14:01", "level": "ERROR", "message": "Erreur API Real-Debrid"}
        ]
    }
