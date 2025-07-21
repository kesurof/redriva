#!/bin/bash

# Script de tests de performance pour Redriva
# Valide l'impact des mises à jour sur les performances

set -e

# Configuration
RESULTS_DIR="performance-results"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$RESULTS_DIR/performance-test-$TIMESTAMP.log"
REPORT_FILE="$RESULTS_DIR/performance-report-$TIMESTAMP.md"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARN:${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

# Créer le dossier de résultats
mkdir -p "$RESULTS_DIR"

# Vérifier que les services sont en cours d'exécution
check_services() {
    log "Vérification des services..."
    
    if ! docker compose ps | grep -q "running"; then
        log_error "Les services ne sont pas en cours d'exécution"
        log "Démarrage des services..."
        docker compose up -d
        sleep 15
    fi
    
    # Attendre que les services soient prêts
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -sf http://localhost:8000/health >/dev/null 2>&1; then
            log "Backend prêt ✓"
            break
        fi
        
        log "Attente du backend... (tentative $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "Timeout: le backend n'est pas accessible"
        return 1
    fi
}

# Test de charge basique
load_test() {
    log "=== Test de charge basique ==="
    
    local results_file="$RESULTS_DIR/load-test-$TIMESTAMP.json"
    
    # Installer Apache Bench si nécessaire
    if ! command -v ab >/dev/null 2>&1; then
        log "Installation d'Apache Bench..."
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y apache2-utils
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y httpd-tools
        else
            log_warn "Impossible d'installer Apache Bench automatiquement"
            return 1
        fi
    fi
    
    # Test de charge sur l'endpoint de santé
    log "Test de charge sur /health (100 requêtes, concurrence 10)..."
    ab -n 100 -c 10 -g "$RESULTS_DIR/ab-health-$TIMESTAMP.gnuplot" \
       http://localhost:8000/health > "$RESULTS_DIR/ab-health-$TIMESTAMP.txt" 2>&1
    
    # Test de charge sur l'API principale
    log "Test de charge sur /api/torrents (50 requêtes, concurrence 5)..."
    ab -n 50 -c 5 -g "$RESULTS_DIR/ab-api-$TIMESTAMP.gnuplot" \
       http://localhost:8000/api/torrents > "$RESULTS_DIR/ab-api-$TIMESTAMP.txt" 2>&1
    
    # Extraire les métriques principales
    extract_ab_metrics "$RESULTS_DIR/ab-health-$TIMESTAMP.txt" "health"
    extract_ab_metrics "$RESULTS_DIR/ab-api-$TIMESTAMP.txt" "api"
}

# Extraire les métriques d'Apache Bench
extract_ab_metrics() {
    local file="$1"
    local endpoint="$2"
    
    if [ ! -f "$file" ]; then
        log_error "Fichier de résultats non trouvé: $file"
        return 1
    fi
    
    log "Extraction des métriques pour $endpoint..."
    
    # Extraire les métriques principales
    local requests_per_sec=$(grep "Requests per second" "$file" | awk '{print $4}')
    local time_per_request=$(grep "Time per request" "$file" | head -1 | awk '{print $4}')
    local failed_requests=$(grep "Failed requests" "$file" | awk '{print $3}')
    local total_time=$(grep "Total:" "$file" | awk '{print $2}')
    
    # Stocker dans un format JSON
    cat >> "$RESULTS_DIR/metrics-$TIMESTAMP.json" << EOF
{
  "endpoint": "$endpoint",
  "timestamp": "$(date -Iseconds)",
  "requests_per_second": "$requests_per_sec",
  "time_per_request_ms": "$time_per_request",
  "failed_requests": "$failed_requests",
  "total_time_ms": "$total_time"
},
EOF
    
    log "$endpoint: $requests_per_sec req/s, $time_per_request ms/req"
}

# Test de mémoire et CPU
resource_test() {
    log "=== Test de ressources système ==="
    
    local duration=60
    local interval=5
    local samples=$((duration / interval))
    
    log "Surveillance des ressources pendant ${duration}s..."
    
    # Créer le fichier d'en-tête CSV
    echo "timestamp,backend_cpu,backend_memory_mb,frontend_cpu,frontend_memory_mb,system_load" > \
        "$RESULTS_DIR/resources-$TIMESTAMP.csv"
    
    for i in $(seq 1 $samples); do
        local timestamp=$(date -Iseconds)
        
        # Récupérer les stats Docker
        local backend_stats=$(docker stats redriva-backend-1 --no-stream --format "table {{.CPUPerc}},{{.MemUsage}}" 2>/dev/null | tail -1)
        local frontend_stats=$(docker stats redriva-frontend-1 --no-stream --format "table {{.CPUPerc}},{{.MemUsage}}" 2>/dev/null | tail -1)
        
        # Parser les stats
        local backend_cpu=$(echo "$backend_stats" | cut -d',' -f1 | sed 's/%//')
        local backend_memory=$(echo "$backend_stats" | cut -d',' -f2 | sed 's/MiB.*//' | sed 's/.*\///')
        
        local frontend_cpu=$(echo "$frontend_stats" | cut -d',' -f1 | sed 's/%//')
        local frontend_memory=$(echo "$frontend_stats" | cut -d',' -f2 | sed 's/MiB.*//' | sed 's/.*\///')
        
        # Load average système
        local system_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
        
        # Écrire dans le CSV
        echo "$timestamp,$backend_cpu,$backend_memory,$frontend_cpu,$frontend_memory,$system_load" >> \
            "$RESULTS_DIR/resources-$TIMESTAMP.csv"
        
        log "Sample $i/$samples: Backend CPU: ${backend_cpu}%, RAM: ${backend_memory}MB"
        
        sleep $interval
    done
    
    # Calculer les moyennes
    calculate_resource_averages
}

# Calculer les moyennes des ressources
calculate_resource_averages() {
    local csv_file="$RESULTS_DIR/resources-$TIMESTAMP.csv"
    
    if [ ! -f "$csv_file" ]; then
        log_error "Fichier CSV non trouvé: $csv_file"
        return 1
    fi
    
    log "Calcul des moyennes de ressources..."
    
    # Utiliser awk pour calculer les moyennes
    local averages=$(awk -F',' 'NR>1 {
        backend_cpu+=$2; backend_mem+=$3; frontend_cpu+=$4; frontend_mem+=$5; load+=$6; count++
    } END {
        printf "%.2f,%.2f,%.2f,%.2f,%.2f", 
        backend_cpu/count, backend_mem/count, frontend_cpu/count, frontend_mem/count, load/count
    }' "$csv_file")
    
    local avg_backend_cpu=$(echo "$averages" | cut -d',' -f1)
    local avg_backend_mem=$(echo "$averages" | cut -d',' -f2)
    local avg_frontend_cpu=$(echo "$averages" | cut -d',' -f3)
    local avg_frontend_mem=$(echo "$averages" | cut -d',' -f4)
    local avg_load=$(echo "$averages" | cut -d',' -f5)
    
    log "Moyennes calculées:"
    log "  Backend - CPU: ${avg_backend_cpu}%, RAM: ${avg_backend_mem}MB"
    log "  Frontend - CPU: ${avg_frontend_cpu}%, RAM: ${avg_frontend_mem}MB"
    log "  System Load: $avg_load"
    
    # Stocker les moyennes
    cat >> "$RESULTS_DIR/averages-$TIMESTAMP.json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "backend_cpu_avg": $avg_backend_cpu,
  "backend_memory_avg_mb": $avg_backend_mem,
  "frontend_cpu_avg": $avg_frontend_cpu,
  "frontend_memory_avg_mb": $avg_frontend_mem,
  "system_load_avg": $avg_load
}
EOF
}

# Test de temps de réponse
response_time_test() {
    log "=== Test de temps de réponse ==="
    
    local endpoints=(
        "/health"
        "/api/torrents"
        "/api/queue"
        "/api/downloads"
    )
    
    local response_file="$RESULTS_DIR/response-times-$TIMESTAMP.json"
    echo "["  > "$response_file"
    
    for endpoint in "${endpoints[@]}"; do
        log "Test de $endpoint..."
        
        local total_time=0
        local successful_requests=0
        local failed_requests=0
        local samples=10
        
        for i in $(seq 1 $samples); do
            local start_time=$(date +%s%N)
            
            if curl -sf "http://localhost:8000$endpoint" >/dev/null 2>&1; then
                local end_time=$(date +%s%N)
                local response_time=$(( (end_time - start_time) / 1000000 )) # Convertir en ms
                total_time=$((total_time + response_time))
                ((successful_requests++))
            else
                ((failed_requests++))
            fi
            
            sleep 0.1
        done
        
        local avg_response_time=0
        if [ $successful_requests -gt 0 ]; then
            avg_response_time=$((total_time / successful_requests))
        fi
        
        log "$endpoint: ${avg_response_time}ms (${successful_requests}/${samples} succès)"
        
        # Ajouter au JSON
        cat >> "$response_file" << EOF
{
  "endpoint": "$endpoint",
  "average_response_time_ms": $avg_response_time,
  "successful_requests": $successful_requests,
  "failed_requests": $failed_requests,
  "total_samples": $samples
},
EOF
    done
    
    # Fermer le JSON
    sed -i '$ s/,$//' "$response_file"
    echo "]" >> "$response_file"
}

# Générer le rapport final
generate_report() {
    log "=== Génération du rapport de performance ==="
    
    cat > "$REPORT_FILE" << EOF
# Rapport de Performance Redriva

**Date:** $(date)
**Durée du test:** $(date -d @$(($(date +%s) - start_time)) -u +%H:%M:%S)

## Résumé Exécutif

Ce rapport présente les résultats des tests de performance pour l'application Redriva.

## Tests de Charge

### Endpoint /health
EOF

    # Ajouter les résultats du test de charge si disponibles
    if [ -f "$RESULTS_DIR/ab-health-$TIMESTAMP.txt" ]; then
        local health_rps=$(grep "Requests per second" "$RESULTS_DIR/ab-health-$TIMESTAMP.txt" | awk '{print $4}')
        local health_time=$(grep "Time per request" "$RESULTS_DIR/ab-health-$TIMESTAMP.txt" | head -1 | awk '{print $4}')
        
        cat >> "$REPORT_FILE" << EOF
- **Requêtes par seconde:** $health_rps
- **Temps de réponse moyen:** $health_time ms

### Endpoint /api/torrents
EOF
    fi
    
    if [ -f "$RESULTS_DIR/ab-api-$TIMESTAMP.txt" ]; then
        local api_rps=$(grep "Requests per second" "$RESULTS_DIR/ab-api-$TIMESTAMP.txt" | awk '{print $4}')
        local api_time=$(grep "Time per request" "$RESULTS_DIR/ab-api-$TIMESTAMP.txt" | head -1 | awk '{print $4}')
        
        cat >> "$REPORT_FILE" << EOF
- **Requêtes par seconde:** $api_rps
- **Temps de réponse moyen:** $api_time ms

EOF
    fi
    
    # Ajouter les moyennes de ressources
    if [ -f "$RESULTS_DIR/averages-$TIMESTAMP.json" ]; then
        cat >> "$REPORT_FILE" << EOF
## Utilisation des Ressources (Moyennes)

EOF
        # Parser le JSON et l'ajouter au rapport
        if command -v jq >/dev/null 2>&1; then
            local backend_cpu=$(jq -r '.backend_cpu_avg' "$RESULTS_DIR/averages-$TIMESTAMP.json")
            local backend_mem=$(jq -r '.backend_memory_avg_mb' "$RESULTS_DIR/averages-$TIMESTAMP.json")
            local frontend_cpu=$(jq -r '.frontend_cpu_avg' "$RESULTS_DIR/averages-$TIMESTAMP.json")
            local frontend_mem=$(jq -r '.frontend_memory_avg_mb' "$RESULTS_DIR/averages-$TIMESTAMP.json")
            
            cat >> "$REPORT_FILE" << EOF
- **Backend CPU:** ${backend_cpu}%
- **Backend RAM:** ${backend_mem} MB
- **Frontend CPU:** ${frontend_cpu}%
- **Frontend RAM:** ${frontend_mem} MB

EOF
        fi
    fi
    
    cat >> "$REPORT_FILE" << EOF
## Recommandations

### Performance
- Surveiller les pics de CPU si > 70%
- Optimiser les requêtes si temps de réponse > 500ms
- Considérer la mise en cache pour améliorer les performances

### Ressources
- Ajuster les limites Docker si nécessaire
- Surveiller la consommation mémoire
- Optimiser les images Docker pour réduire l'empreinte

## Fichiers Générés

- Logs détaillés: \`$LOG_FILE\`
- Données CSV: \`$RESULTS_DIR/resources-$TIMESTAMP.csv\`
- Métriques JSON: \`$RESULTS_DIR/metrics-$TIMESTAMP.json\`
- Temps de réponse: \`$RESULTS_DIR/response-times-$TIMESTAMP.json\`

## Historique

Pour comparer avec les tests précédents, consultez le dossier \`$RESULTS_DIR/\`.

EOF

    log "Rapport généré: $REPORT_FILE"
}

# Fonction principale
main() {
    local start_time=$(date +%s)
    
    log "=== Démarrage des tests de performance Redriva ==="
    log "Timestamp: $TIMESTAMP"
    
    # Vérifications préalables
    check_services
    
    # Exécuter les tests
    load_test
    resource_test
    response_time_test
    
    # Générer le rapport
    generate_report
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log "=== Tests terminés en ${duration}s ==="
    log "Rapport disponible: $REPORT_FILE"
    log "Logs détaillés: $LOG_FILE"
}

# Fonction d'aide
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  --load-only     Exécuter uniquement les tests de charge
  --resource-only Exécuter uniquement les tests de ressources
  --response-only Exécuter uniquement les tests de temps de réponse
  --help, -h      Afficher cette aide

Exemples:
  $0                    # Exécuter tous les tests
  $0 --load-only        # Tests de charge uniquement
  $0 --resource-only    # Tests de ressources uniquement

Fichiers générés:
  - performance-results/performance-report-TIMESTAMP.md
  - performance-results/performance-test-TIMESTAMP.log
  - performance-results/resources-TIMESTAMP.csv
  - performance-results/metrics-TIMESTAMP.json

EOF
}

# Point d'entrée
case "${1:-all}" in
    --load-only)
        check_services
        load_test
        ;;
    --resource-only)
        check_services
        resource_test
        ;;
    --response-only)
        check_services
        response_time_test
        ;;
    --help|-h)
        show_help
        ;;
    *)
        main
        ;;
esac
