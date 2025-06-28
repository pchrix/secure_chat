# Configuration Context7 MCP pour DreamFlow

## Qu'est-ce que Context7 ?

Context7 est un serveur MCP (Model Context Protocol) qui fournit une documentation à jour et des exemples de code pour les bibliothèques et frameworks. Il permet d'obtenir des informations précises et actuelles directement dans vos prompts.

## ✅ Installation et Configuration (Terminée)

### 1. Configuration automatique
- ✅ Context7 installé localement via npm
- ✅ Configuration MCP créée dans `.cursor/mcp.json`
- ✅ Auto-approbation activée pour les outils Context7
- ✅ Scripts npm configurés pour la gestion

### 2. Redémarrage requis
**Important** : Redémarrez Cursor pour que les changements MCP prennent effet.

### 3. Vérification
Testez avec : `npm run test-context7` ou utilisez directement dans un prompt.

## Utilisation avec Flutter/Dart

### Commandes disponibles

1. **resolve-library-id** : Résout un nom de bibliothèque en ID compatible Context7
2. **get-library-docs** : Récupère la documentation pour une bibliothèque

### Exemples d'utilisation dans vos prompts

#### Pour Flutter
```
Comment créer une animation fluide avec Flutter ? use context7
```

#### Pour des packages spécifiques
```
Comment utiliser le package encrypt pour AES-256 en Flutter ? use context7
```

#### Pour Dart
```
Comment implémenter PBKDF2 en Dart pour la dérivation de clés ? use context7
```

#### Pour les packages de votre projet
```
Comment utiliser shared_preferences de manière sécurisée ? use context7
```

### Bibliothèques pertinentes pour votre projet

- **Flutter** : Documentation du framework principal
- **Dart** : Documentation du langage
- **encrypt** : Package de chiffrement que vous utilisez
- **crypto** : Package cryptographique Dart
- **shared_preferences** : Stockage local
- **provider** : Gestion d'état
- **pointycastle** : Cryptographie avancée

## Avantages pour DreamFlow

1. **Documentation à jour** : Évite les API obsolètes ou inexistantes
2. **Exemples précis** : Code fonctionnel basé sur les versions actuelles
3. **Sécurité renforcée** : Bonnes pratiques cryptographiques actuelles
4. **PWA Flutter** : Documentation spécifique pour le déploiement web

## Conseils d'utilisation

1. **Ajoutez "use context7"** à la fin de vos prompts pour activer la récupération de documentation
2. **Soyez spécifique** : Mentionnez les packages exacts que vous utilisez
3. **Contexte du projet** : Précisez que c'est pour une application de chiffrement Flutter/PWA

## Exemples de prompts optimisés pour votre projet

### Sécurité
```
Comment implémenter un effacement sécurisé de la mémoire en Dart pour une application de chiffrement ? use context7
```

### UI/UX
```
Comment créer des animations fluides entre les modes calculatrice et chiffrement en Flutter ? use context7
```

### PWA
```
Comment configurer un service worker pour une PWA Flutter avec fonctionnalités hors ligne ? use context7
```

### Tests
```
Comment écrire des tests unitaires pour les services de chiffrement en Flutter ? use context7
```

## Dépannage

Si Context7 ne fonctionne pas :

1. Vérifiez que Node.js >= v18 est installé
2. Redémarrez Cursor complètement
3. Essayez avec `bunx` au lieu de `npx` dans la configuration
4. Vérifiez les logs de Cursor pour les erreurs MCP

## Configuration alternative (si problèmes)

Si vous rencontrez des problèmes avec npx, utilisez cette configuration alternative :

```json
{
  "mcpServers": {
    "context7": {
      "command": "bunx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {
        "DEFAULT_MINIMUM_TOKENS": "15000"
      }
    }
  }
}
```
