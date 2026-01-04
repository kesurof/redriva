#!/usr/bin/env bash
################################################################################
# Redriva CLI - Wrapper Shell
# Responsabilité unique :
# - Résoudre le vrai chemin du projet (même via symlink)
# - Valider l’environnement minimal
# - Lancer le core Python
################################################################################

set -Eeuo pipefail

# ==============================================================================
# RÉSOLUTION DU CHEMIN RÉEL (ANTI-SYMLINK BUG)
# ==============================================================================

resolve_script_path() {
    local src="$1"
    while [ -L "$src" ]; do
        local dir
        dir="$(cd -P "$(dirname "$src")" && pwd)"
        src="$(readlink "$src")"
        [[ "$src" != /* ]] && src="$dir/$src"
    done
    cd -P "$(dirname "$src")" && pwd
}

# Répertoire réel du script, même via /usr/local/bin/redriva
SCRIPT_DIR="$(resolve_script_path "${BASH_SOURCE[0]}")"

# Racine réelle du projet
REDRIVA_HOME="$(cd -P "${SCRIPT_DIR}/.." && pwd)"

# Core Python
PYTHON_CORE="${REDRIVA_HOME}/bin/redriva-core.py"

# Répertoire utilisateur (aligné avec le core Python)
export REDRIVA_USER_HOME="${HOME}/my_redriva"

# ==============================================================================
# LOGS
# ==============================================================================

log_error() {
    printf "\033[91m✗ %s\033[0m\n" "$1" >&2
    exit 1
}

# ==============================================================================
# VALIDATIONS
# ==============================================================================

command -v python3 >/dev/null 2>&1 \
    || log_error "Python 3 est requis mais non installé"

command -v docker >/dev/null 2>&1 \
    || log_error "Docker est requis mais non installé"

[[ -f "${PYTHON_CORE}" ]] \
    || log_error "Core Python introuvable: ${PYTHON_CORE}"

[[ -r "${PYTHON_CORE}" ]] \
    || log_error "Droits insuffisants sur ${PYTHON_CORE}"

# ==============================================================================
# EXÉCUTION
# ==============================================================================

export PYTHONUNBUFFERED=1
exec python3 "${PYTHON_CORE}" "$@"
