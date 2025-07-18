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

app = FastAPI()

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
