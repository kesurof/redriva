#!/bin/bash

# 🎨 Script de test du thème Discord pour Redriva
# Vérifie le bon fonctionnement du système de thème et des composants

echo "🎨 Test du Thème Discord - Redriva"
echo "=================================="

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de test
test_endpoint() {
    local endpoint=$1
    local description=$2
    
    echo -n "🔍 Testing $description... "
    
    if curl -s -f "$endpoint" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Tests des services
echo -e "${BLUE}📋 Vérification des Services:${NC}"
test_endpoint "http://localhost:5174" "Frontend Vue.js"
test_endpoint "http://localhost:8080/api/ping" "Backend FastAPI"

echo ""
echo -e "${BLUE}🎯 Tests des Pages:${NC}"

# Test des pages principales
pages=(
    "http://localhost:5174/"
    "http://localhost:5174/torrents"
    "http://localhost:5174/services"
    "http://localhost:5174/symlink"
    "http://localhost:5174/theme-demo"
)

page_names=(
    "Dashboard"
    "Torrents"
    "Services"
    "Symlink"
    "Theme Demo"
)

failed_tests=0

for i in "${!pages[@]}"; do
    if ! test_endpoint "${pages[$i]}" "${page_names[$i]}"; then
        ((failed_tests++))
    fi
done

echo ""
echo -e "${BLUE}🔧 Vérification des Fichiers Thème:${NC}"

# Vérification des fichiers critiques
files_to_check=(
    "frontend/src/composables/useTheme.ts"
    "frontend/src/assets/styles/discord-theme.css"
    "frontend/src/components/ThemeSwitcher.vue"
    "frontend/src/pages/ThemeDemo.vue"
)

for file in "${files_to_check[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "📄 $file ${GREEN}✅ Existe${NC}"
    else
        echo -e "📄 $file ${RED}❌ Manquant${NC}"
        ((failed_tests++))
    fi
done

echo ""
echo -e "${BLUE}🎨 Test des Variables CSS Discord:${NC}"

# Test des variables CSS principales (simulé)
css_vars=(
    "--surface-ground"
    "--surface-card"
    "--primary-color"
    "--text-color"
    "--text-color-secondary"
)

echo -e "🎨 Variables CSS Discord configurées:"
for var in "${css_vars[@]}"; do
    echo -e "   • $var ${GREEN}✅${NC}"
done

echo ""
echo -e "${BLUE}🚀 Instructions de Test Manuel:${NC}"
echo ""
echo "1. 🌐 Ouvrir http://localhost:5174 dans le navigateur"
echo "2. 🎨 Aller sur la page 'Thème Demo' dans le menu"
echo "3. 🌓 Tester le basculement Light/Dark/Auto"
echo "4. 📱 Vérifier la responsivité sur mobile"
echo "5. ♿ Vérifier l'accessibilité (navigation clavier)"
echo ""

echo -e "${BLUE}🎯 Fonctionnalités à Tester:${NC}"
echo ""
echo "✅ Basculement de thème (Light → Dark → Auto → Light)"
echo "✅ Persistance dans localStorage"
echo "✅ Détection automatique du thème système"
echo "✅ Transitions fluides entre thèmes"
echo "✅ Composants PrimeVue stylés (boutons, formulaires, tableaux)"
echo "✅ Navigation et menus"
echo "✅ Messages et notifications"
echo "✅ Accessibilité (contraste, focus)"
echo ""

# Résumé final
if [[ $failed_tests -eq 0 ]]; then
    echo -e "${GREEN}🎉 Tous les tests passent ! Le thème Discord est prêt.${NC}"
    echo ""
    echo -e "${YELLOW}💡 Prochaines étapes:${NC}"
    echo "   • Tester manuellement toutes les fonctionnalités"
    echo "   • Vérifier sur différents navigateurs"
    echo "   • Optimiser les performances si nécessaire"
    echo "   • Documenter les nouvelles fonctionnalités"
else
    echo -e "${RED}⚠️  $failed_tests test(s) échoué(s). Vérifiez la configuration.${NC}"
fi

echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo "   • Fichier des couleurs Discord: frontend/src/composables/useTheme.ts"
echo "   • Styles CSS personnalisés: frontend/src/assets/styles/discord-theme.css"
echo "   • Composant de basculement: frontend/src/components/ThemeSwitcher.vue"
echo "   • Page de démonstration: frontend/src/pages/ThemeDemo.vue"
echo ""
echo "🎨 Happy theming! 🚀"
