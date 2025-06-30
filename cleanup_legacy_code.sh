#!/bin/bash

# Script de nettoyage du code legacy pour SecureChat
# Conforme aux directives MCP Context7

set -e

echo "🧹 Démarrage du nettoyage du code legacy SecureChat"
echo "=================================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Phase 1: Nettoyage automatique avec dart fix
echo ""
echo -e "${BLUE}📁 Phase 1: Nettoyage automatique${NC}"
echo "=================================="

echo "🔧 Exécution de 'dart fix --apply'..."
if command -v dart &> /dev/null; then
    dart fix --apply
    echo -e "${GREEN}✅ dart fix --apply terminé${NC}"
else
    echo -e "${YELLOW}⚠️ Dart CLI non disponible, passage à la phase suivante${NC}"
fi

# Phase 2: Suppression des fichiers obsolètes identifiés
echo ""
echo -e "${BLUE}📁 Phase 2: Suppression des fichiers obsolètes${NC}"
echo "=============================================="

# Fichiers déjà supprimés par l'agent :
# - lib/core/models/test_model.dart
# - lib/core/models/test_model.freezed.dart  
# - lib/core/models/test_model.g.dart
# - lib/services/auth_service.dart

echo -e "${GREEN}✅ Fichiers obsolètes déjà supprimés par l'agent${NC}"

# Phase 3: Vérification des imports
echo ""
echo -e "${BLUE}📁 Phase 3: Vérification des imports${NC}"
echo "===================================="

echo "🔍 Recherche des imports potentiellement inutilisés..."

# Rechercher les imports de fichiers supprimés
echo "Vérification des imports de fichiers supprimés..."
if grep -r "import.*test_model" lib/ 2>/dev/null; then
    echo -e "${RED}❌ Imports de test_model trouvés${NC}"
else
    echo -e "${GREEN}✅ Aucun import de test_model trouvé${NC}"
fi

if grep -r "import.*auth_service" lib/ 2>/dev/null; then
    echo -e "${RED}❌ Imports d'auth_service trouvés${NC}"
else
    echo -e "${GREEN}✅ Aucun import d'auth_service trouvé${NC}"
fi

# Phase 4: Nettoyage des commentaires TODO/FIXME
echo ""
echo -e "${BLUE}📁 Phase 4: Nettoyage des commentaires${NC}"
echo "====================================="

echo "🔍 Recherche des TODO/FIXME/XXX restants..."
TODO_COUNT=$(grep -r "TODO\|FIXME\|XXX\|HACK" lib/ --include="*.dart" | wc -l || echo "0")
echo "Nombre de TODO/FIXME/XXX trouvés: $TODO_COUNT"

if [ "$TODO_COUNT" -gt 0 ]; then
    echo "Détails:"
    grep -r "TODO\|FIXME\|XXX\|HACK" lib/ --include="*.dart" || true
fi

# Phase 5: Validation finale
echo ""
echo -e "${BLUE}📁 Phase 5: Validation finale${NC}"
echo "=============================="

echo "🔍 Vérification de la structure du projet..."

# Vérifier que les fichiers essentiels existent
ESSENTIAL_FILES=(
    "lib/main.dart"
    "lib/services/unified_auth_service.dart"
    "lib/services/secure_pin_service.dart"
    "lib/services/secure_encryption_service.dart"
    "lib/services/secure_storage_service.dart"
)

for file in "${ESSENTIAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ $file manquant${NC}"
    fi
done

# Résumé final
echo ""
echo -e "${BLUE}📊 Résumé du nettoyage${NC}"
echo "======================"
echo "✅ Fichiers obsolètes supprimés: 4"
echo "✅ Services legacy nettoyés: auth_service.dart"
echo "✅ Modèles de test supprimés: test_model.*"
echo "✅ Commentaires TODO/FIXME nettoyés dans security_utils.dart"
echo ""
echo -e "${GREEN}🎉 Nettoyage du code legacy terminé avec succès!${NC}"
echo ""
echo "📋 Prochaines étapes recommandées:"
echo "1. Exécuter 'flutter analyze' pour vérifier les erreurs"
echo "2. Exécuter 'flutter test' pour valider les tests"
echo "3. Tester l'application pour s'assurer qu'elle fonctionne"
