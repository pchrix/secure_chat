/// 🔐 Enhanced Auth Page - Orchestrateur d'authentification
///
/// Page orchestrateur qui navigue vers PinPage ou PinSetupPage selon l'état
/// Conforme aux meilleures pratiques Context7 et Clean Architecture

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/pages/pin_page.dart';
import '../features/auth/presentation/pages/pin_setup_page.dart';
import '../features/auth/presentation/providers/pin_state_provider.dart';
import 'home_page.dart';

/// Page d'authentification orchestrateur
/// Navigue vers PinPage ou PinSetupPage selon l'état
class EnhancedAuthPage extends ConsumerStatefulWidget {
  const EnhancedAuthPage({super.key});

  @override
  ConsumerState<EnhancedAuthPage> createState() => _EnhancedAuthPageState();
}

class _EnhancedAuthPageState extends ConsumerState<EnhancedAuthPage> {
  @override
  void initState() {
    super.initState();
    // Le provider se charge de l'initialisation
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  void _navigateToSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PinSetupPage(
          onSetupComplete: _navigateToHome,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinStateProvider);

    // Affichage de chargement pendant l'initialisation
    if (pinState.isCheckingPassword) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Initialisation...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Navigation selon le mode
    switch (pinState.mode) {
      case PinMode.setup:
        return PinSetupPage(
          onSetupComplete: _navigateToHome,
        );
      case PinMode.authentication:
      case PinMode.change:
        return PinPage(
          onAuthenticationSuccess: _navigateToHome,
          onNavigateToSetup: _navigateToSetup,
        );
    }
  }
}
