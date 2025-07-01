import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securechat/pages/tutorial_page.dart';

void main() {
  group('Tutorial Responsive Tests', () {
    testWidgets('iPhone SE - Tutorial should be optimized for small screen',
        (WidgetTester tester) async {
      // Simuler iPhone SE (375x667)
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: TutorialPage(),
        ),
      );

      // Vérifier que le widget se charge sans erreur
      expect(find.byType(TutorialPage), findsOneWidget);

      // Vérifier qu'il n'y a pas de débordement (RenderFlex overflow)
      expect(tester.takeException(), isNull);

      // Vérifier la présence des éléments principaux
      expect(find.text('Bienvenue dans SecureChat'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
      expect(find.text('Suivant'), findsOneWidget);
    });

    testWidgets('iPhone Standard - Tutorial should adapt to medium screen',
        (WidgetTester tester) async {
      // Simuler iPhone Standard (414x896)
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        MaterialApp(
          home: TutorialPage(),
        ),
      );

      // Vérifier que le widget se charge sans erreur
      expect(find.byType(TutorialPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Vérifier la présence des éléments
      expect(find.text('Bienvenue dans SecureChat'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('iPad - Tutorial should use full layout on large screen',
        (WidgetTester tester) async {
      // Simuler iPad (1024x1366)
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: TutorialPage(),
        ),
      );

      // Vérifier que le widget se charge sans erreur
      expect(find.byType(TutorialPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Vérifier la présence des éléments
      expect(find.text('Bienvenue dans SecureChat'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('Navigation buttons should be responsive',
        (WidgetTester tester) async {
      // Simuler iPhone SE pour tester les boutons compacts
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: TutorialPage(),
        ),
      );

      // Vérifier la présence du bouton Suivant
      expect(find.text('Suivant'), findsOneWidget);

      // Tester la navigation
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();

      // Vérifier qu'on est passé à la page suivante
      expect(find.text('Sécurité Maximale'), findsOneWidget);

      // Vérifier la présence des boutons Précédent et Suivant
      expect(find.text('Précédent'), findsOneWidget);
      expect(find.text('Suivant'), findsOneWidget);
    });

    testWidgets('All tutorial pages should load without overflow',
        (WidgetTester tester) async {
      // Simuler iPhone SE (cas le plus contraignant)
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: TutorialPage(),
        ),
      );

      // Naviguer à travers toutes les pages
      final pages = [
        'Bienvenue dans SecureChat',
        'Sécurité Maximale',
        'Salons Temporaires',
        'Comment ça marche',
        'Vous êtes prêt !'
      ];

      for (int i = 0; i < pages.length; i++) {
        // Vérifier que la page actuelle se charge sans erreur
        expect(tester.takeException(), isNull);
        expect(find.text(pages[i]), findsOneWidget);

        // Passer à la page suivante (sauf pour la dernière)
        if (i < pages.length - 1) {
          await tester.tap(find.text('Suivant'));
          await tester.pumpAndSettle();
        }
      }

      // Vérifier le bouton final "Commencer"
      expect(find.text('Commencer'), findsOneWidget);
    });

    testWidgets('Feature lists should be responsive',
        (WidgetTester tester) async {
      // Simuler iPhone SE
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: TutorialPage(),
        ),
      );

      // Naviguer vers la page de sécurité qui contient une liste de fonctionnalités
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();

      // Vérifier la présence des éléments de la liste
      expect(find.text('Chiffrement AES-256'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsWidgets);

      // Vérifier qu'il n'y a pas de débordement
      expect(tester.takeException(), isNull);
    });
  });
}
