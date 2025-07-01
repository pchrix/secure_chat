# 🧹 PLAN DE NETTOYAGE - FICHIERS .MD

## 🎯 OBJECTIF
Réduire de 15 à 5 fichiers .md essentiels et éliminer la confusion sur l'état du projet.

## 📋 FICHIERS À CONSERVER (5)

### 1. **README.md** (Principal - À Mettre à Jour)
**Contenu :** Vue d'ensemble, installation, utilisation de base
**Action :** Mettre à jour avec l'état RÉEL du projet

### 2. **ARCHITECTURE.md** (Technique)
**Contenu :** Architecture, stack technique, services
**Action :** Fusionner `ARCHITECTURE_ANALYSIS.md` + parties techniques des autres

### 3. **SECURITY.md** (Sécurité)
**Contenu :** Audit sécurité, corrections appliquées, bugs restants
**Action :** Fusionner `AUDIT_SECURITE_COMPLET.md` + `SECURITY_FIXES.md`

### 4. **DEPLOYMENT.md** (Déploiement)
**Contenu :** Guide de déploiement, configuration production
**Action :** Extraire les infos de déploiement des différents fichiers

### 5. **CHANGELOG.md** (Historique - Garder tel quel)
**Contenu :** Historique des versions et modifications
**Action :** Conserver inchangé

## 📁 FICHIERS À SUPPRIMER (10)

### Duplicatas et Obsolètes
- [ ] `ARCHITECTURE_ANALYSIS.md` → Fusionner dans ARCHITECTURE.md
- [ ] `AUDIT_FINAL_REPORT.md` → Fusionner dans SECURITY.md  
- [ ] `AUDIT_SECURITE_COMPLET.md` → Fusionner dans SECURITY.md
- [ ] `INTEGRATION_SUPABASE_REPORT.md` → Fusionner dans ARCHITECTURE.md
- [ ] `MVP_GUIDE.md` → Fusionner dans README.md
- [ ] `PROJECT_COMPLETION_SUMMARY.md` → Fusionner dans README.md
- [ ] `SECURECHAT_FINAL_DOCUMENTATION.md` → Fusionner dans README.md
- [ ] `SECURITY_FIXES.md` → Fusionner dans SECURITY.md
- [ ] `VISUAL_IMPROVEMENTS_GUIDE.md` → Archive ou supprimer
- [ ] `ui_correct.md` → Archive ou supprimer

### Fichiers Spécifiques (À Conserver Séparément)
- [ ] `CONTEXT7_INTEGRATION.md` → Déplacer vers `docs/dev/`
- [ ] `ROADMAP_PHASE_1.md` → Déplacer vers `docs/planning/`

## ⚡ ACTIONS RECOMMANDÉES

### ÉTAPE 1 : Créer le dossier docs/ structuré
```bash
mkdir -p docs/{dev,planning,archive}
```

### ÉTAPE 2 : Déplacer les fichiers spécifiques
```bash
mv CONTEXT7_INTEGRATION.md docs/dev/
mv ROADMAP_PHASE_1.md docs/planning/
mv VISUAL_IMPROVEMENTS_GUIDE.md docs/archive/
mv ui_correct.md docs/archive/
```

### ÉTAPE 3 : Fusionner les contenus essentiels
- Créer les 4 nouveaux fichiers consolidés
- Copier le contenu pertinent depuis les anciens
- Supprimer les doublons et incohérences

### ÉTAPE 4 : Supprimer les fichiers obsolètes
- Vérifier qu'aucune info unique n'est perdue
- Supprimer les 10 fichiers redondants

## 🎯 RÉSULTAT ATTENDU

**AVANT :** 15 fichiers .md confus avec duplicatas
**APRÈS :** 5 fichiers .md clairs et structurés

```
/
├── README.md (État réel + Installation + Usage)
├── ARCHITECTURE.md (Technique complet)
├── SECURITY.md (Audit + Corrections + Bugs)
├── DEPLOYMENT.md (Production + Config)
├── CHANGELOG.md (Historique)
└── docs/
    ├── dev/CONTEXT7_INTEGRATION.md
    ├── planning/ROADMAP_PHASE_1.md
    └── archive/*.md
```

## ⚠️ ATTENTION : ÉTAT RÉEL DU PROJET

Avant de nettoyer, **CLARIFIER L'ÉTAT RÉEL** :
- Le projet est-il vraiment terminé ?
- Quels bugs sont réellement présents ?
- L'application fonctionne-t-elle en production ?

**Recommandation :** Faire un test complet de l'application avant de finaliser la documentation.
