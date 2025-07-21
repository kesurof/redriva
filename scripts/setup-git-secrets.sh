#!/bin/bash

# Setup Git Secrets for Redriva
# Ce script configure git-secrets pour prévenir l'accidental commit de secrets

set -e

echo "[INFO] === CONFIGURATION GIT-SECRETS POUR REDRIVA ==="

# Vérifier si git-secrets est installé
if ! command -v git-secrets &> /dev/null; then
    echo "[ERROR] git-secrets n'est pas installé"
    echo "[INFO] Installation sur Ubuntu/Debian:"
    echo "       sudo apt-get install git-secrets"
    echo "[INFO] Installation sur macOS:"
    echo "       brew install git-secrets"
    echo "[INFO] Installation manuelle:"
    echo "       git clone https://github.com/awslabs/git-secrets.git"
    echo "       cd git-secrets && sudo make install"
    exit 1
fi

echo "[INFO] 1. Installation des hooks git-secrets..."
git secrets --install

echo "[INFO] 2. Configuration des patterns de sécurité..."

# Patterns pour Real-Debrid
git secrets --add 'real[-_]?debrid.*['"'"'"][^'"'"'"]{10,}'
git secrets --add 'rd[-_]?token.*['"'"'"][^'"'"'"]{10,}'

# Patterns pour clés API génériques
git secrets --add 'api[-_]?key.*['"'"'"][^'"'"'"]{15,}'
git secrets --add 'secret[-_]?key.*['"'"'"][^'"'"'"]{15,}'
git secrets --add 'access[-_]?token.*['"'"'"][^'"'"'"]{15,}'

# Patterns pour variables d'environnement sensibles
git secrets --add 'REAL_DEBRID.*=.*[a-zA-Z0-9]{10,}'
git secrets --add 'API_KEY.*=.*[a-zA-Z0-9]{15,}'
git secrets --add 'SECRET.*=.*[a-zA-Z0-9]{15,}'

# Patterns pour mots de passe
git secrets --add 'password.*['"'"'"][^'"'"'"]{8,}'
git secrets --add 'passwd.*['"'"'"][^'"'"'"]{8,}'

echo "[INFO] 3. Configuration globale (pour tous les futurs repos)..."
git secrets --install ~/.git-templates/git-secrets
git config --global init.templateDir ~/.git-templates/git-secrets

echo "[INFO] 4. Test de la configuration..."
echo 'REAL_DEBRID_TOKEN="test_secret_1234567890"' > /tmp/test-secret.txt
if git secrets --scan /tmp/test-secret.txt 2>/dev/null; then
    echo "[ERROR] Le test de détection de secret a échoué"
    rm -f /tmp/test-secret.txt
    exit 1
else
    echo "[INFO] ✅ Test de détection de secret réussi"
    rm -f /tmp/test-secret.txt
fi

echo "[INFO] 5. Scan du repository actuel..."
if git secrets --scan; then
    echo "[INFO] ✅ Aucun secret détecté dans le repository"
else
    echo "[WARN] ⚠️  Des secrets potentiels ont été détectés"
    echo "[INFO] Utilisez 'git secrets --scan' pour plus de détails"
fi

echo ""
echo "=== CONFIGURATION TERMINÉE ==="
echo ""
echo "git-secrets est maintenant configuré pour Redriva:"
echo "• Détection automatique lors des commits"
echo "• Patterns personnalisés pour Real-Debrid et autres API"
echo "• Configuration globale pour tous les futurs projets"
echo ""
echo "Commandes utiles:"
echo "• git secrets --scan          : Scanner le repository"
echo "• git secrets --scan-history  : Scanner l'historique Git"
echo "• git secrets --list          : Lister les patterns configurés"
echo ""
echo "Pour désactiver temporairement (à éviter):"
echo "• git commit --no-verify"
echo ""

exit 0
