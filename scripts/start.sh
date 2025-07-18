#!/bin/bash
# Script de démarrage Redriva (active le venv et lance l'API)
set -e
cd "$(dirname "$0")/.."

if [ -z "$VIRTUAL_ENV" ]; then
  if [ -d "venv" ]; then
    source venv/bin/activate
  else
    echo "Erreur : venv non trouvé. Créez un environnement virtuel Python."
    exit 1
  fi
fi

export PYTHONPATH=src
python3 src/main.py
