#!/bin/bash
# Script de démarrage du service Redriva

source ../config/venv.conf
source ../config/environment.conf

if [ -d "$VIRTUAL_ENV" ]; then
    source "$VIRTUAL_ENV/bin/activate"
fi

python3 ../backend/app.py
