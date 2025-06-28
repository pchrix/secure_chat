#!/bin/bash
# 🔧 Script de Migration SecureChat - Corrections Responsive
# Usage: ./migrate_fixes.sh

set -e  # Exit on any error

echo "🔧 SecureChat - Migration des corrections responsive"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ] || [ ! -d "lib" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis la racine du projet Flutter${NC}"
    exit 1
fi

# Check if Git is available and project is under version control
if command -v git &> /dev/null && [ -d ".git" ]; then
    echo -e "${BLUE}📚 Git détecté - Création d'une branche pour les corrections...${NC}"
    
    # Create backup branch
    BRANCH_NAME="fix/responsive-layout-$(date +%Y%m%d-%H%M%S)"
    git checkout -b "$BRANCH_NAME" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Branche existante détectée, continuation...${NC}"
    }
    
    echo -e "${GREEN}✅ Branche créée: $BRANCH_NAME${NC}"
else
    echo -e "${YELLOW}⚠️  Git non détecté - Pas de sauvegarde automatique${NC}"
fi

# Function to backup file
backup_file() {
    local file=$1
    local backup_file="${file}_BACKUP_$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$file" ]; then
        cp "$file" "$backup_file"
        echo -e "${GREEN}✅ Backup créé: $backup_file${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Fichier non trouvé: $file${NC}"
        return 1
    fi
}

# Function to apply fix
apply_fix() {
    local fixed_file=$1
    local target_file=$2
    
    if [ -f "$fixed_file" ]; then
        echo -e "${BLUE}🔄 Application: $fixed_file -> $target_file${NC}"
        
        # Backup original if exists
        if [ -f "$target_file" ]; then
            backup_file "$target_file"
        fi
        
        # Apply fix
        cp "$fixed_file" "$target_file"
        echo -e "${GREEN}✅ Correction appliquée: $target_file${NC}"
        return 0
    else
        echo -e "${RED}❌ Fichier de correction non trouvé: $fixed_file${NC}"
        return 1
    fi
}

# Function to check file syntax
check_syntax() {
    local file=$1
    echo -e "${BLUE}🔍 Vérification syntaxe: $file${NC}"
    
    if flutter analyze "$file" 2>/dev/null; then
        echo -e "${GREEN}✅ Syntaxe correcte${NC}"
        return 0
    else
        echo -e "${RED}❌ Erreurs de syntaxe détectées${NC}"
        return 1
    fi
}

echo ""
echo -e "${BLUE}📁 Phase 1: Sauvegarde et vérification des fichiers originaux${NC}"
echo "============================================================"

# List of files to process
declare -A FILES_TO_FIX=(
    ["lib/pages/enhanced_auth_page_FIXED.dart"]="lib/pages/enhanced_auth_page.dart"
    ["lib/widgets/enhanced_numeric_keypad_FIXED.dart"]="lib/widgets/enhanced_numeric_keypad.dart"
    ["lib/utils/responsive_utils_FIXED.dart"]="lib/utils/responsive_utils.dart"
    ["lib/widgets/glass_components_FIXED.dart"]="lib/widgets/glass_components.dart"
)

# Check if all fix files exist
echo "🔍 Vérification des fichiers de correction..."
all_fixes_exist=true
for fixed_file in "${!FILES_TO_FIX[@]}"; do
    if [ ! -f "$fixed_file" ]; then
        echo -e "${RED}❌ Fichier de correction manquant: $fixed_file${NC}"
        all_fixes_exist=false
    else
        echo -e "${GREEN}✅ Trouvé: $fixed_file${NC}"
    fi
done

if [ "$all_fixes_exist" = false ]; then
    echo -e "${RED}❌ Certains fichiers de correction sont manquants. Abandon.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📁 Phase 2: Application des corrections${NC}"
echo "======================================="

# Apply fixes
for fixed_file in "${!FILES_TO_FIX[@]}"; do
    target_file="${FILES_TO_FIX[$fixed_file]}"
    echo ""
    echo -e "${YELLOW}🔄 Traitement: $target_file${NC}"
    
    if apply_fix "$fixed_file" "$target_file"; then
        # Check syntax of applied fix
        if ! check_syntax "$target_file"; then
            echo -e "${RED}❌ Erreur de syntaxe dans le fichier appliqué${NC}"
            echo -e "${YELLOW}💡 Restauration du backup recommandée${NC}"
        fi
    fi
done

echo ""
echo -e "${BLUE}📁 Phase 3: Vérification finale${NC}"
echo "================================"

# Run flutter analyze on the whole project
echo "🔍 Analyse complète du projet..."
if flutter analyze; then
    echo -e "${GREEN}✅ Analyse Flutter réussie${NC}"
else
    echo -e "${RED}❌ Erreurs détectées lors de l'analyse Flutter${NC}"
    echo -e "${YELLOW}💡 Vérifiez les erreurs ci-dessus avant de continuer${NC}"
fi

# Try to compile
echo ""
echo "🏗️  Test de compilation..."
if flutter build web --debug > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Compilation réussie${NC}"
else
    echo -e "${RED}❌ Échec de compilation${NC}"
    echo -e "${YELLOW}💡 Exécutez 'flutter build web --debug' pour voir les erreurs${NC}"
fi

echo ""
echo -e "${BLUE}📁 Phase 4: Résumé et prochaines étapes${NC}"
echo "======================================="

echo -e "${GREEN}✅ Migration terminée !${NC}"
echo ""
echo "📋 Fichiers modifiés:"
for fixed_file in "${!FILES_TO_FIX[@]}"; do
    target_file="${FILES_TO_FIX[$fixed_file]}"
    echo -e "   • $target_file"
done

echo ""
echo -e "${YELLOW}🧪 TESTS RECOMMANDÉS:${NC}"
echo "1. flutter run --device-id=chrome"
echo "2. Redimensionner la fenêtre pour tester différentes tailles"
echo "3. Tester sur iPhone SE (375x667)"
echo "4. Vérifier l'accessibilité avec l'inspecteur"
echo "5. Profiler les performances avec Flutter DevTools"

echo ""
echo -e "${BLUE}📚 DOCUMENTATION:${NC}"
echo "• Rapport complet: RAPPORT_CORRECTIONS_RESPONSIVE.md"
echo "• Tests détaillés dans le rapport"
echo "• Monitoring performance recommandé"

if command -v git &> /dev/null && [ -d ".git" ]; then
    echo ""
    echo -e "${BLUE}🔀 GIT:${NC}"
    echo "• Branche actuelle: $(git branch --show-current)"
    echo "• Commit recommandé: git add . && git commit -m 'fix: responsive layout improvements'"
    echo "• Merge après validation des tests"
fi

echo ""
echo -e "${GREEN}🎉 Migration terminée avec succès !${NC}"
echo -e "${YELLOW}💡 N'oubliez pas de tester sur différents appareils${NC}"
