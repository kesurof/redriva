#!/bin/bash

# Build script pour Redriva - Architecture SvelteKit + FastAPI
set -e

echo "🚀 Building Redriva..."

# Vérification des prérequis
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is required but not installed."
    exit 1
fi

# Build des images
echo "📦 Building Docker images..."
docker-compose build

echo "✅ Build completed successfully!"
echo ""
echo "To start the application:"
echo "  docker-compose up -d"
echo ""
echo "Services will be available at:"
echo "  • Frontend (SvelteKit): http://localhost:5173"
echo "  • Backend (FastAPI): http://localhost:8080"
