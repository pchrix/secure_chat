import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securechat/animations/enhanced_micro_interactions.dart';
import 'package:securechat/animations/micro_interactions.dart';

void main() {
  group('Timer Cleanup Tests', () {
    testWidgets('WaveSlideAnimation should cleanup timers properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WaveSlideAnimation(
              index: 2, // Délai de 200ms
              child: Text('Test Wave Animation'),
            ),
          ),
        ),
      );

      // Vérifier que le widget est créé
      expect(find.text('Test Wave Animation'), findsOneWidget);

      // Disposer le widget avant que le timer ne se déclenche
      await tester.pumpWidget(Container());

      // Attendre plus longtemps que le délai du timer
      await tester.pump(Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Vérifier qu'aucun timer n'est en attente
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('SlideInAnimation should cleanup timers properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlideInAnimation(
              delay: Duration(milliseconds: 150),
              child: Text('Test Slide Animation'),
            ),
          ),
        ),
      );

      // Vérifier que le widget est créé
      expect(find.text('Test Slide Animation'), findsOneWidget);

      // Disposer le widget avant que le timer ne se déclenche
      await tester.pumpWidget(Container());

      // Attendre plus longtemps que le délai du timer
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Vérifier qu'aucun timer n'est en attente
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('LoadingDots should cleanup all timers properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingDots(),
          ),
        ),
      );

      // Vérifier que le widget est créé
      expect(find.byType(LoadingDots), findsOneWidget);

      // Disposer le widget avant que tous les timers ne se déclenchent
      await tester.pumpWidget(Container());

      // Attendre plus longtemps que tous les délais des timers (3 dots * 200ms = 600ms)
      await tester.pump(Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Vérifier qu'aucun timer n'est en attente
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('Multiple WaveSlideAnimations should cleanup all timers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WaveSlideAnimation(
                  index: 0,
                  child: Text('Animation 1'),
                ),
                WaveSlideAnimation(
                  index: 1,
                  child: Text('Animation 2'),
                ),
                WaveSlideAnimation(
                  index: 2,
                  child: Text('Animation 3'),
                ),
              ],
            ),
          ),
        ),
      );

      // Vérifier que tous les widgets sont créés
      expect(find.text('Animation 1'), findsOneWidget);
      expect(find.text('Animation 2'), findsOneWidget);
      expect(find.text('Animation 3'), findsOneWidget);

      // Disposer tous les widgets
      await tester.pumpWidget(Container());

      // Attendre plus longtemps que tous les délais
      await tester.pump(Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Vérifier qu'aucun timer n'est en attente
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('Timer cleanup should work even with rapid widget disposal', (WidgetTester tester) async {
      // Test de stress : créer et disposer rapidement des widgets avec timers
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WaveSlideAnimation(
                index: i,
                child: Text('Rapid Test $i'),
              ),
            ),
          ),
        );

        // Disposer immédiatement
        await tester.pumpWidget(Container());
        await tester.pump(Duration(milliseconds: 10));
      }

      // Attendre que tous les timers potentiels soient nettoyés
      await tester.pump(Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Vérifier qu'aucun timer n'est en attente
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    group('Performance Tests', () {
      testWidgets('Timer cleanup should not affect performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        // Créer plusieurs animations avec timers
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: List.generate(10, (index) => 
                  WaveSlideAnimation(
                    index: index,
                    child: Text('Performance Test $index'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Disposer tous les widgets
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Le cleanup ne devrait pas prendre plus de 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));

        // Vérifier qu'aucun timer n'est en attente
        expect(tester.binding.hasScheduledFrame, isFalse);
      });

      testWidgets('Memory usage should be stable after timer cleanup', (WidgetTester tester) async {
        // Test de stabilité mémoire
        for (int cycle = 0; cycle < 3; cycle++) {
          // Créer des animations
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: List.generate(5, (index) => 
                    WaveSlideAnimation(
                      index: index,
                      child: Text('Memory Test $cycle-$index'),
                    ),
                  ),
                ),
              ),
            ),
          );

          // Laisser quelques animations se déclencher
          await tester.pump(Duration(milliseconds: 50));

          // Disposer
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();

          // Vérifier qu'aucun timer n'est en attente
          expect(tester.binding.hasScheduledFrame, isFalse);
        }
      });
    });

    group('Edge Cases', () {
      testWidgets('Timer cleanup should work with zero delay', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WaveSlideAnimation(
                index: 0, // Délai de 0ms
                child: Text('Zero Delay Test'),
              ),
            ),
          ),
        );

        // Disposer immédiatement
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        // Vérifier qu'aucun timer n'est en attente
        expect(tester.binding.hasScheduledFrame, isFalse);
      });

      testWidgets('Timer cleanup should work with very long delays', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WaveSlideAnimation(
                index: 100, // Délai de 10 secondes
                delay: Duration(milliseconds: 100),
                child: Text('Long Delay Test'),
              ),
            ),
          ),
        );

        // Disposer avant que le timer ne se déclenche
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        // Vérifier qu'aucun timer n'est en attente
        expect(tester.binding.hasScheduledFrame, isFalse);
      });
    });
  });
}
