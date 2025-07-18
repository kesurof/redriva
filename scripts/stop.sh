#!/bin/bash
# Script d'arrêt Redriva (arrête le process uvicorn)

pkill -f "uvicorn.*api:app" || echo "Aucun process uvicorn trouvé."
