import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securechat/widgets/glass_components.dart';
import 'package:securechat/utils/responsive_utils.dart';

void main() {
  group('Glass Components Tests', () {
    group('UnifiedGlassContainer', () {
      testWidgets('should optimize effects on iPhone SE',
          (WidgetTester tester) async {
        // iPhone SE dimensions
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassContainer(
                blurIntensity: 20.0,
                opacity: 0.16,
                enableDepthEffect: true,
                enableInnerShadow: true,
                enableBorderGlow: true,
                child: const Text('Test'),
              ),
            ),
          ),
        );

        // Vérifier que le widget est rendu
        expect(find.byType(UnifiedGlassContainer), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);

        // Vérifier que BackdropFilter est présent avec blur optimisé
        expect(find.byType(BackdropFilter), findsOneWidget);

        // Vérifier que RepaintBoundary est utilisé pour la performance
        expect(find.byType(RepaintBoundary), findsOneWidget);
      });

      testWidgets('should use full effects on iPad',
          (WidgetTester tester) async {
        // iPad dimensions
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassContainer(
                blurIntensity: 20.0,
                opacity: 0.16,
                enableDepthEffect: true,
                enableInnerShadow: true,
                enableBorderGlow: true,
                child: const Text('Test'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassContainer), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(find.byType(Stack), findsOneWidget); // Effets avancés activés
      });

      testWidgets('simple constructor should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassContainer.simple(
                child: const Text('Simple Test'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassContainer), findsOneWidget);
        expect(find.text('Simple Test'), findsOneWidget);
      });

      testWidgets('enhanced constructor should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassContainer.enhanced(
                child: const Text('Enhanced Test'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassContainer), findsOneWidget);
        expect(find.text('Enhanced Test'), findsOneWidget);
      });
    });

    group('UnifiedGlassButton', () {
      testWidgets('should handle tap events', (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassButton(
                onTap: () => tapped = true,
                child: const Text('Tap Me'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassButton), findsOneWidget);
        expect(find.text('Tap Me'), findsOneWidget);

        await tester.tap(find.byType(UnifiedGlassButton));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('should use responsive width when adaptiveSize is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassButton(
                adaptiveSize: true,
                mobileWidth: 200,
                tabletWidth: 300,
                desktopWidth: 400,
                child: const Text('Responsive Button'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassButton), findsOneWidget);
      });

      testWidgets('simple constructor should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassButton.simple(
                child: const Text('Simple Button'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassButton), findsOneWidget);
        expect(find.text('Simple Button'), findsOneWidget);
      });
    });

    group('UnifiedGlassCard', () {
      testWidgets('should handle tap events', (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassCard(
                onTap: () => tapped = true,
                child: const Text('Card Content'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassCard), findsOneWidget);
        expect(find.text('Card Content'), findsOneWidget);

        await tester.tap(find.byType(UnifiedGlassCard));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('should show advanced effects when enabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassCard(
                enableAdvancedEffects: true,
                enableHoverEffect: true,
                child: const Text('Advanced Card'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassCard), findsOneWidget);
        expect(find.byType(MouseRegion), findsOneWidget); // Hover effect
      });

      testWidgets('simple constructor should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassCard.simple(
                child: const Text('Simple Card'),
              ),
            ),
          ),
        );

        expect(find.byType(UnifiedGlassCard), findsOneWidget);
        expect(find.text('Simple Card'), findsOneWidget);
      });
    });

    group('Alias Compatibility', () {
      testWidgets('GlassContainer alias should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassContainer(
                child: const Text('Alias Test'),
              ),
            ),
          ),
        );

        expect(find.text('Alias Test'), findsOneWidget);
      });

      testWidgets('EnhancedGlassContainer alias should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedGlassContainer(
                child: const Text('Enhanced Alias Test'),
              ),
            ),
          ),
        );

        expect(find.text('Enhanced Alias Test'), findsOneWidget);
      });

      testWidgets('GlassButton alias should work', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassButton(
                child: const Text('Button Alias Test'),
              ),
            ),
          ),
        );

        expect(find.text('Button Alias Test'), findsOneWidget);
      });

      testWidgets('GlassCard alias should work', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassCard(
                child: const Text('Card Alias Test'),
              ),
            ),
          ),
        );

        expect(find.text('Card Alias Test'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should use RepaintBoundary when performance mode is enabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassContainer(
                enablePerformanceMode: true,
                child: const Text('Performance Test'),
              ),
            ),
          ),
        );

        expect(find.byType(RepaintBoundary), findsOneWidget);
      });

      testWidgets('should optimize shadows based on screen size',
          (WidgetTester tester) async {
        // iPhone SE - should have minimal shadows
        tester.view.physicalSize = const Size(375, 667);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnifiedGlassContainer(
                enableDepthEffect: true,
                enableBorderGlow: true,
                child: const Text('Shadow Test'),
              ),
            ),
          ),
        );

        // Vérifier que le container est rendu
        expect(find.byType(UnifiedGlassContainer), findsOneWidget);

        // Sur iPhone SE, les effets avancés devraient être réduits
        final context = tester.element(find.byType(UnifiedGlassContainer));
        expect(ResponsiveUtils.getOptimizedShadowLayers(context), equals(1));
      });
    });
  });
}
