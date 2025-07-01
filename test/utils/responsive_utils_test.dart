import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securechat/utils/responsive_utils.dart';

void main() {
  group('ResponsiveUtils Tests', () {
    late Widget testApp;

    setUp(() {
      testApp = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Container(),
          ),
        ),
      );
    });

    group('Breakpoints de hauteur', () {
      testWidgets('iPhone SE - isVeryCompact should be true',
          (WidgetTester tester) async {
        // iPhone SE dimensions (logiques : 375x667 / 2.0 = 375x333.5)
        tester.view.physicalSize = const Size(750, 1334);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        expect(ResponsiveUtils.isVeryCompact(context), isTrue);
        expect(ResponsiveUtils.isCompact(context), isTrue);
        expect(ResponsiveUtils.isNormal(context), isFalse);
      });

      testWidgets('iPhone Standard - isNormal should be true (896px > 800px)',
          (WidgetTester tester) async {
        // iPhone 14 dimensions (logiques : 414x896 / 1.0 = 414x896)
        tester.view.physicalSize = const Size(414, 896);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        expect(ResponsiveUtils.isVeryCompact(context), isFalse);
        expect(ResponsiveUtils.isCompact(context), isFalse); // 896 > 800
        expect(ResponsiveUtils.isNormal(context), isTrue); // 896 >= 800
      });

      testWidgets('iPad - isNormal should be true',
          (WidgetTester tester) async {
        // iPad dimensions (logiques : 768x1024 / 1.0 = 768x1024)
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        expect(ResponsiveUtils.isVeryCompact(context), isFalse);
        expect(ResponsiveUtils.isCompact(context), isFalse);
        expect(ResponsiveUtils.isNormal(context), isTrue);
      });
    });

    group('Optimisations Glassmorphism', () {
      testWidgets('iPhone SE - Blur intensity should be reduced by 50%',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(750, 1334);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        final optimizedBlur =
            ResponsiveUtils.getOptimizedBlurIntensity(context, 20.0);
        expect(optimizedBlur, equals(10.0)); // 50% réduction
      });

      testWidgets(
          'iPhone Standard - Blur intensity should be reduced by mobile factor',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(414, 896);
        tester.view.devicePixelRatio = 3.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        final optimizedBlur =
            ResponsiveUtils.getOptimizedBlurIntensity(context, 20.0);
        expect(optimizedBlur, equals(16.0)); // 20% réduction (mobile factor)
      });

      testWidgets('iPad - Blur intensity should remain full',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        final optimizedBlur =
            ResponsiveUtils.getOptimizedBlurIntensity(context, 20.0);
        expect(optimizedBlur, equals(20.0)); // Aucune réduction
      });

      testWidgets('Shadow layers optimization', (WidgetTester tester) async {
        // iPhone SE - 1 couche
        tester.view.physicalSize = const Size(375, 667);
        await tester.pumpWidget(testApp);
        var context = tester.element(find.byType(Container));
        expect(ResponsiveUtils.getOptimizedShadowLayers(context), equals(1));

        // iPhone Standard - 3 couches (896px > 800px = normal)
        tester.view.physicalSize = const Size(414, 896);
        await tester.pumpWidget(testApp);
        context = tester.element(find.byType(Container));
        expect(ResponsiveUtils.getOptimizedShadowLayers(context), equals(3));

        // iPad - 3 couches
        tester.view.physicalSize = const Size(768, 1024);
        await tester.pumpWidget(testApp);
        context = tester.element(find.byType(Container));
        expect(ResponsiveUtils.getOptimizedShadowLayers(context), equals(3));
      });

      testWidgets('Advanced effects should be disabled on iPhone SE',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        expect(ResponsiveUtils.shouldDisableAdvancedEffects(context), isTrue);
      });

      testWidgets('Advanced effects should be enabled on larger screens',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        expect(ResponsiveUtils.shouldDisableAdvancedEffects(context), isFalse);
      });
    });

    group('GlassConfig Integration', () {
      testWidgets('iPhone SE - GlassConfig should be optimized',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        final config = ResponsiveUtils.getOptimizedGlassConfig(
          context,
          baseBlur: 20.0,
          baseOpacity: 0.16,
          enableAdvancedEffects: true,
        );

        expect(config.blurIntensity, equals(10.0)); // 50% réduction
        expect(config.opacity, equals(0.192)); // +20% pour compenser
        expect(
            config.enableAdvancedEffects, isFalse); // Désactivés sur iPhone SE
        expect(config.enablePerformanceMode, isTrue);
        expect(config.shadowLayers, equals(1));
      });

      testWidgets('iPad - GlassConfig should be full quality',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Container));

        final config = ResponsiveUtils.getOptimizedGlassConfig(
          context,
          baseBlur: 20.0,
          baseOpacity: 0.16,
          enableAdvancedEffects: true,
        );

        expect(
            config.blurIntensity, equals(20.0)); // Aucune réduction (tablette)
        expect(config.opacity, equals(0.16)); // Opacité normale
        expect(config.enableAdvancedEffects, isTrue); // Activés
        expect(config.enablePerformanceMode, isTrue);
        expect(config.shadowLayers, equals(3));
      });
    });

    group('Keyboard Height Optimization', () {
      testWidgets('Keyboard height should be optimized per screen size',
          (WidgetTester tester) async {
        // iPhone SE
        tester.view.physicalSize = const Size(375, 667);
        await tester.pumpWidget(testApp);
        var context = tester.element(find.byType(Container));
        expect(
            ResponsiveUtils.getOptimizedKeyboardHeight(context), equals(160.0));

        // iPhone Standard (896px > 800px = normal)
        tester.view.physicalSize = const Size(414, 896);
        await tester.pumpWidget(testApp);
        context = tester.element(find.byType(Container));
        expect(
            ResponsiveUtils.getOptimizedKeyboardHeight(context), equals(240.0));

        // iPad
        tester.view.physicalSize = const Size(768, 1024);
        await tester.pumpWidget(testApp);
        context = tester.element(find.byType(Container));
        expect(
            ResponsiveUtils.getOptimizedKeyboardHeight(context), equals(240.0));
      });
    });

    group('Ultra Adaptive Spacing', () {
      testWidgets('Spacing should be ultra-reduced on compact screens',
          (WidgetTester tester) async {
        // iPhone SE
        tester.view.physicalSize = const Size(375, 667);
        await tester.pumpWidget(testApp);
        var context = tester.element(find.byType(Container));

        final padding = ResponsiveUtils.getUltraAdaptivePadding(context);
        expect(padding, equals(const EdgeInsets.all(12.0)));

        final spacing = ResponsiveUtils.getUltraAdaptiveSpacing(context);
        expect(spacing, equals(8.0));

        // iPad
        tester.view.physicalSize = const Size(768, 1024);
        await tester.pumpWidget(testApp);
        context = tester.element(find.byType(Container));

        final normalPadding = ResponsiveUtils.getUltraAdaptivePadding(context);
        expect(normalPadding, equals(const EdgeInsets.all(24.0)));

        final normalSpacing = ResponsiveUtils.getUltraAdaptiveSpacing(context);
        expect(normalSpacing, equals(24.0));
      });
    });
  });
}
