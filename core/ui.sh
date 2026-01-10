#!/usr/bin/env bash

title() {
  echo ""
  echo "================================================"
  echo " $1"
  echo "================================================"
}

info()    { echo "ℹ️  $1"; }
success() { echo "✅ $1"; }
error()   { echo "❌ $1"; exit 1; }

pause() {
  echo ""
  read -rp "👉 Appuie sur ENTRÉE pour continuer..."
}
