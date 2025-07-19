# Modèles de données pour Redriva
from pydantic import BaseModel

class Torrent(BaseModel):
    id: str
    filename: str
    status: str
    size: int
