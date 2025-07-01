import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../lib/widgets/animated_background.dart';
import '../../lib/animations/micro_interactions.dart';
import '../../lib/widgets/enhanced_snackbar.dart';

/// Tests de performance UI pour valider les optimisations
void main() {
  group('UI Performance Tests', () {
    testWidgets('AnimatedBackground should not rebuild child unnecessarily', (WidgetTester tester) async {
      int childBuildCount = 0;
      
      final testChild = Builder(
        builder: (context) {
          childBuildCount++;
          return const Text('Test Child');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedBackground(
            showFloatingShapes: true,
            child: testChild,
          ),
        ),
      );

      // Attendre que les animations se stabilisent
      await tester.pump(const Duration(milliseconds: 100));
      
      final initialBuildCount = childBuildCount;
      
      // Pump plusieurs frames pour simuler l'animation
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // 60 FPS
      }

      // Le child ne devrait pas être rebuild grâce à RepaintBoundary
      expect(childBuildCount, equals(initialBuildCount));
    });

    testWidgets('PulseAnimation should use RepaintBoundary', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PulseAnimation(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Vérifier que RepaintBoundary est présent
      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('ShakeAnimation should use RepaintBoundary', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShakeAnimation(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      );

      // Vérifier que RepaintBoundary est présent
      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('BounceAnimation should use RepaintBoundary', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BounceAnimation(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.green,
            ),
          ),
        ),
      );

      // Vérifier que RepaintBoundary est présent
      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('SlideInAnimation should use RepaintBoundary', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SlideInAnimation(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.yellow,
            ),
          ),
        ),
      );

      // Vérifier que RepaintBoundary est présent
      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('LoadingDots should use RepaintBoundary', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingDots(),
        ),
      );

      // Vérifier que RepaintBoundary est présent
      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('CounterAnimation should use RepaintBoundary', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CounterAnimation(
            value: 42,
          ),
        ),
      );

      // Vérifier que RepaintBoundary est présent
      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('EnhancedSnackBar should use RepaintBoundary', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      EnhancedSnackBar(
                        message: 'Test message',
                        type: EnhancedSnackBarType.success,
                      ),
                    );
                  },
                  child: const Text('Show SnackBar'),
                );
              },
            ),
          ),
        ),
      );

      // Déclencher le SnackBar
      await tester.tap(find.text('Show SnackBar'));
      await tester.pump();

      // Vérifier que RepaintBoundary est présent
      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    group('Performance Benchmarks', () {
      testWidgets('AnimatedBackground performance with multiple shapes', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedBackground(
              showFloatingShapes: true,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.white,
              ),
            ),
          ),
        );

        // Pump plusieurs frames pour mesurer la performance
        for (int i = 0; i < 60; i++) { // 1 seconde à 60 FPS
          await tester.pump(const Duration(milliseconds: 16));
        }

        stopwatch.stop();
        
        // La performance devrait être acceptable (< 2 secondes pour 60 frames)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      testWidgets('Multiple animations performance test', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                PulseAnimation(
                  child: Container(width: 50, height: 50, color: Colors.red),
                ),
                ShakeAnimation(
                  child: Container(width: 50, height: 50, color: Colors.blue),
                ),
                BounceAnimation(
                  child: Container(width: 50, height: 50, color: Colors.green),
                ),
                const LoadingDots(),
              ],
            ),
          ),
        );

        // Pump plusieurs frames
        for (int i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        stopwatch.stop();
        
        // Même avec plusieurs animations, la performance doit rester acceptable
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
