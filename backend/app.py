# Backend minimal pour Redriva (FastAPI)
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/api/ping")
def ping():
    return {"status": "ok"}

# TODO: Ajouter endpoints sécurisés pour /api/torrents, /api/downloads, etc.
