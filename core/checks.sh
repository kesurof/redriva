#!/usr/bin/env bash

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo ""
    echo "❌ REDRIVA doit être exécuté avec des privilèges administrateur"
    echo ""
    echo "👉 Utilise : sudo redriva menu"
    echo ""
    exit 1
  fi
}
