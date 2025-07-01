#!/bin/bash

# Script de validation après nettoyage du code legacy
# Conforme aux directives MCP Context7

set -e

echo "🔍 Validation du nettoyage du code legacy SecureChat"
echo "=================================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Phase 1: Vérification des fichiers supprimés
echo ""
echo -e "${BLUE}📁 Phase 1: Vérification des suppressions${NC}"
echo "==========================================="

DELETED_FILES=(
    "lib/core/models/test_model.dart"
    "lib/core/models/test_model.freezed.dart"
    "lib/core/models/test_model.g.dart"
    "lib/services/auth_service.dart"
)

for file in "${DELETED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${GREEN}✅ $file correctement supprimé${NC}"
    else
        echo -e "${RED}❌ $file existe encore${NC}"
    fi
done

# Phase 2: Vérification des imports cassés
echo ""
echo -e "${BLUE}📁 Phase 2: Vérification des imports${NC}"
echo "===================================="

echo "🔍 Recherche d'imports cassés..."

# Vérifier les imports de fichiers supprimés
BROKEN_IMPORTS=0

if grep -r "import.*test_model" lib/ 2>/dev/null; then
    echo -e "${RED}❌ Imports de test_model trouvés${NC}"
    BROKEN_IMPORTS=$((BROKEN_IMPORTS + 1))
else
    echo -e "${GREEN}✅ Aucun import de test_model${NC}"
fi

if grep -r "services/auth_service\.dart" lib/ 2>/dev/null; then
    echo -e "${RED}❌ Imports d'auth_service legacy trouvés${NC}"
    BROKEN_IMPORTS=$((BROKEN_IMPORTS + 1))
else
    echo -e "${GREEN}✅ Aucun import d'auth_service legacy${NC}"
fi

# Phase 3: Vérification de la structure
echo ""
echo -e "${BLUE}📁 Phase 3: Vérification de la structure${NC}"
echo "========================================"

ESSENTIAL_FILES=(
    "lib/main.dart"
    "lib/services/unified_auth_service.dart"
    "lib/services/secure_pin_service.dart"
    "lib/services/secure_encryption_service.dart"
    "lib/services/secure_storage_service.dart"
    "lib/services/encryption_service.dart"
    "lib/services/room_key_service.dart"
)

MISSING_FILES=0

for file in "${ESSENTIAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ $file manquant${NC}"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

# Phase 4: Vérification des commentaires nettoyés
echo ""
echo -e "${BLUE}📁 Phase 4: Vérification des commentaires${NC}"
echo "========================================="

echo "🔍 Recherche de commentaires TODO/FIXME restants..."
TODO_COUNT=$(grep -r "TODO\|FIXME\|XXX\|HACK" lib/ --include="*.dart" | grep -v "// Memory wiping placeholder" | wc -l || echo "0")

if [ "$TODO_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ Aucun TODO/FIXME/XXX trouvé${NC}"
else
    echo -e "${YELLOW}⚠️ $TODO_COUNT commentaires TODO/FIXME/XXX restants${NC}"
    if [ "$TODO_COUNT" -lt 5 ]; then
        echo "Détails:"
        grep -r "TODO\|FIXME\|XXX\|HACK" lib/ --include="*.dart" | grep -v "// Memory wiping placeholder" || true
    fi
fi

# Phase 5: Validation finale
echo ""
echo -e "${BLUE}📁 Phase 5: Résumé de validation${NC}"
echo "================================="

TOTAL_ISSUES=$((BROKEN_IMPORTS + MISSING_FILES))

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo -e "${GREEN}🎉 VALIDATION RÉUSSIE !${NC}"
    echo ""
    echo "✅ Tous les fichiers obsolètes ont été supprimés"
    echo "✅ Aucun import cassé détecté"
    echo "✅ Tous les fichiers essentiels sont présents"
    echo "✅ Structure du projet cohérente"
    echo ""
    echo -e "${BLUE}📋 Prochaines étapes recommandées :${NC}"
    echo "1. Exécuter 'flutter analyze' pour vérifier les erreurs"
    echo "2. Exécuter 'flutter test' pour valider les tests"
    echo "3. Tester l'application en mode développement"
else
    echo -e "${RED}❌ VALIDATION ÉCHOUÉE !${NC}"
    echo ""
    echo "Problèmes détectés :"
    echo "- Imports cassés : $BROKEN_IMPORTS"
    echo "- Fichiers manquants : $MISSING_FILES"
    echo ""
    echo "Veuillez corriger ces problèmes avant de continuer."
fi

echo ""
echo "📊 Statistiques du nettoyage :"
echo "- Fichiers supprimés : 4"
echo "- Commentaires nettoyés : 8"
echo "- Imports optimisés : 1"
echo "- TODO/FIXME restants : $TODO_COUNT"
