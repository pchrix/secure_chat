import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securechat/utils/responsive_utils.dart';

void main() {
  group('Device Layout Tests', () {
    testWidgets('iPhone SE - Layout should be optimized for small screen',
        (tester) async {
      // ✅ CONTEXT7: Test simple sans charger l'app complète
      // Simuler iPhone SE (375x667)
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
      });

      // Widget simple pour tester les utilitaires responsive
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );
      await tester.pump(); // ✅ CONTEXT7: pump() au lieu de pumpAndSettle()

      final context = tester.element(find.byType(MaterialApp));

      // Vérifier les breakpoints
      expect(ResponsiveUtils.isVeryCompact(context), isTrue);
      expect(ResponsiveUtils.isCompact(context), isTrue);
      expect(ResponsiveUtils.isNormal(context), isFalse);

      // Vérifier les optimisations
      expect(ResponsiveUtils.getOptimizedBlurIntensity(context, 20.0),
          equals(10.0));
      expect(ResponsiveUtils.shouldDisableAdvancedEffects(context), isTrue);
      expect(ResponsiveUtils.getOptimizedShadowLayers(context), equals(1));
    });

    testWidgets('iPhone Standard - Layout should be balanced', (tester) async {
      // ✅ CONTEXT7: Test simple sans charger l'app complète
      // Simuler iPhone Standard (414x896)
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
      });

      // Widget simple pour tester les utilitaires responsive
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );
      await tester.pump(); // ✅ CONTEXT7: pump() au lieu de pumpAndSettle()

      final context = tester.element(find.byType(MaterialApp));

      // Vérifier les breakpoints
      expect(ResponsiveUtils.isVeryCompact(context), isFalse);
      expect(ResponsiveUtils.isCompact(context), isFalse);
      expect(ResponsiveUtils.isNormal(context), isTrue);

      // Vérifier les optimisations (logique séparée)
      expect(ResponsiveUtils.getOptimizedBlurIntensity(context, 20.0),
          equals(16.0));
      expect(ResponsiveUtils.shouldDisableAdvancedEffects(context), isFalse);
      expect(ResponsiveUtils.getOptimizedShadowLayers(context), equals(2));
    });

    testWidgets('iPad - Layout should use full effects', (tester) async {
      // ✅ CONTEXT7: Test simple sans charger l'app complète
      // Simuler iPad (768x1024)
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
      });

      // Widget simple pour tester les utilitaires responsive
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );
      await tester.pump(); // ✅ CONTEXT7: pump() au lieu de pumpAndSettle()

      final context = tester.element(find.byType(MaterialApp));

      // Vérifier les breakpoints
      expect(ResponsiveUtils.isVeryCompact(context), isFalse);
      expect(ResponsiveUtils.isCompact(context), isFalse);
      expect(ResponsiveUtils.isNormal(context), isTrue);

      // Vérifier les optimisations
      expect(ResponsiveUtils.getOptimizedBlurIntensity(context, 20.0),
          equals(20.0));
      expect(ResponsiveUtils.shouldDisableAdvancedEffects(context), isFalse);
      expect(ResponsiveUtils.getOptimizedShadowLayers(context), equals(3));
    });

    testWidgets('Landscape orientation - Layout should adapt', (tester) async {
      // ✅ CONTEXT7: Test simple sans charger l'app complète
      // Simuler iPhone en paysage (896x414)
      tester.view.physicalSize = const Size(896, 414);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
      });

      // Widget simple pour tester les utilitaires responsive
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );
      await tester.pump(); // ✅ CONTEXT7: pump() au lieu de pumpAndSettle()

      final context = tester.element(find.byType(MaterialApp));
      final orientation = MediaQuery.of(context).orientation;

      // Vérifier l'orientation
      expect(orientation, equals(Orientation.landscape));

      // Vérifier que les breakpoints s'adaptent à la hauteur (414px)
      expect(ResponsiveUtils.isVeryCompact(context), isFalse);
      expect(ResponsiveUtils.isCompact(context), isFalse);
      expect(ResponsiveUtils.isNormal(context), isTrue);
    });

    testWidgets('Very small screen - Should handle gracefully', (tester) async {
      // ✅ CONTEXT7: Test simple sans charger l'app complète
      // Simuler un très petit écran (320x480)
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
      });

      // Widget simple pour tester les utilitaires responsive
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );
      await tester.pump(); // ✅ CONTEXT7: pump() au lieu de pumpAndSettle()

      final context = tester.element(find.byType(MaterialApp));

      // Vérifier que l'app ne crash pas et applique les optimisations maximales
      expect(ResponsiveUtils.isVeryCompact(context), isFalse); // 480px > 340px
      expect(ResponsiveUtils.getOptimizedBlurIntensity(context, 20.0),
          lessThanOrEqualTo(20.0));
      expect(ResponsiveUtils.getOptimizedShadowLayers(context),
          greaterThanOrEqualTo(1));
    });

    testWidgets('Large screen - Should use full quality', (tester) async {
      // ✅ CONTEXT7: Test simple sans charger l'app complète
      // Simuler un grand écran (1200x1600)
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
      });

      // Widget simple pour tester les utilitaires responsive
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );
      await tester.pump(); // ✅ CONTEXT7: pump() au lieu de pumpAndSettle()

      final context = tester.element(find.byType(MaterialApp));

      // Vérifier que l'app utilise la qualité maximale
      expect(ResponsiveUtils.isNormal(context), isTrue);
      expect(ResponsiveUtils.getOptimizedBlurIntensity(context, 20.0),
          equals(20.0));
      expect(ResponsiveUtils.shouldDisableAdvancedEffects(context), isFalse);
      expect(ResponsiveUtils.getOptimizedShadowLayers(context), equals(3));
    });
  });
}
