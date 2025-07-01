import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_sizes.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'config/app_config.dart';
import 'services/supabase_service.dart';
import 'services/migration_service.dart';
import 'services/secure_storage_service.dart';
import 'utils/storage_migration.dart';
import 'animations/animation_manager.dart';
import 'pages/enhanced_auth_page.dart';
import 'pages/tutorial_page.dart';
import 'utils/debug_helper.dart';

// Hot reload trigger

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la configuration (variables d'environnement)
  await AppConfig.initialize();

  // Initialiser le stockage sécurisé
  await SecureStorageService.initialize();

  // Exécuter la migration des données si nécessaire
  final migrationResult =
      await StorageMigrationService.executeMigrationIfNeeded();
  if (migrationResult.success && migrationResult.migratedKeys.isNotEmpty) {
    // Nettoyer les anciennes données après migration réussie
    await StorageMigrationService.cleanupOldData();
  }

  // Initialiser Supabase
  await SupabaseService.initialize();

  // Créer un container Riverpod pour l'initialisation des services
  final container = ProviderContainer();
  
  // Initialiser DebugHelper avec le container
  DebugHelper.initialize(container);

  // Diagnostic complet pour identifier les problèmes
  await DebugHelper.printFullDiagnosis();

  // Exécuter les migrations
  await MigrationService.runMigrations();

  // Initialiser le gestionnaire d'animations
  AnimationManager.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(ProviderScope(child: const MyApp(), overrides: []));

  // Activer automatiquement l'accessibilité pour Flutter Web
  SemanticsBinding.instance.ensureSemantics();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureChat',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const StartupPage(),
    );
  }
}

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time') ?? true;

    // Force l'affichage du tutoriel pour les tests (décommentez la ligne suivante)
    await prefs.setBool('first_time', true);

    if (mounted) {
      if (isFirstTime) {
        // Marquer comme pas première fois
        await prefs.setBool('first_time', false);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TutorialPage()),
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const EnhancedAuthPage()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
