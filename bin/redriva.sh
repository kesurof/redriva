#!/bin/bash
################################################################################
# Redriva CLI - Script Wrapper Shell
# Responsabilité: Lancer le core Python avec paramètres corrects
# Version: 3.0
# Date: 2026-01-04
################################################################################

set -Eeuo pipefail

# ============================================================================
# CONFIGURATION - Chemins et variables
# ============================================================================

# Déterminer le répertoire du script (chemin absolu)
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Répertoire racine Redriva (parent de bin/)
REDRIVA_HOME="$(cd -P "${SCRIPT_DIR}/.." && pwd)"

# Répertoire lib contenant les modules Python
PYTHON_CORE="${REDRIVA_HOME}/bin/redriva-core.py"

# Configuration utilisateur
export REDRIVA_HOME
export HOME_CONFIG="${HOME}/.redriva"

# ============================================================================
# FONCTIONS UTILITAIRES
# ============================================================================

log_error() {
    printf "\033[91m✗ %s\033[0m\n" "$1" >&2
    exit 1
}

log_info() {
    printf "\033[96mℹ %s\033[0m\n" "$1" >&2
}

# ============================================================================
# VALIDATIONS - Préalables avant exécution
# ============================================================================

# Vérifier que Python 3 est disponible
if ! command -v python3 &> /dev/null; then
    log_error "Python 3 n'est pas installé"
fi

# Vérifier que le core Python existe
if [[ ! -f "${PYTHON_CORE}" ]]; then
    log_error "Fichier core Python non trouvé: ${PYTHON_CORE}"
fi

# Vérifier que Docker est disponible
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé"
fi

# ============================================================================
# EXÉCUTION - Lancer le core Python
# ============================================================================

# Exporter les variables pour que Python les voit
export PYTHONUNBUFFERED=1

# Transmettre tous les arguments au script Python
exec python3 "${PYTHON_CORE}" "$@"
