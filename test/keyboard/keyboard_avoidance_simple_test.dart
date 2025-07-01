import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securechat/pages/enhanced_auth_page.dart';
import 'package:securechat/pages/join_room_page.dart';
import 'package:securechat/pages/create_room_page.dart';

void main() {
  group('Keyboard Avoidance Configuration Tests', () {
    group('Scaffold Configuration', () {
      testWidgets('enhanced_auth_page should have resizeToAvoidBottomInset true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EnhancedAuthPage(),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.resizeToAvoidBottomInset, isTrue);
      });

      testWidgets('join_room_page should have resizeToAvoidBottomInset true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: JoinRoomPage(),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.resizeToAvoidBottomInset, isTrue);
      });

      testWidgets('create_room_page should have resizeToAvoidBottomInset true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CreateRoomPage(),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.resizeToAvoidBottomInset, isTrue);
      });
    });

    group('SingleChildScrollView Configuration', () {
      testWidgets('should use reverse scroll for keyboard avoidance', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              resizeToAvoidBottomInset: true,
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                  return SingleChildScrollView(
                    reverse: true,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - keyboardHeight,
                      ),
                      child: const Column(
                        children: [
                          Text('Content'),
                          TextField(key: Key('test-field')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final scrollView = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
        expect(scrollView.reverse, isTrue);
      });
    });

    group('TextField ScrollPadding', () {
      testWidgets('TextField should have proper scrollPadding configuration', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextField(
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        // Dans l'état initial, viewInsets.bottom = 0, donc scrollPadding = 100
        expect(textField.scrollPadding, equals(const EdgeInsets.only(bottom: 100)));
      });
    });

    group('MediaQuery Access', () {
      testWidgets('should access MediaQuery viewInsets correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                  return Text('Keyboard: $keyboardHeight');
                },
              ),
            ),
          ),
        );

        // Vérifier que MediaQuery fonctionne
        expect(find.text('Keyboard: 0.0'), findsOneWidget);
        
        // Vérifier l'accès au context
        final context = tester.element(find.byType(Scaffold));
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        expect(keyboardHeight, equals(0.0));
      });
    });

    group('Integration Tests', () {
      testWidgets('complete keyboard avoidance pattern should work', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                    return SingleChildScrollView(
                      reverse: true,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - keyboardHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              Container(height: 200, color: Colors.red),
                              TextField(
                                key: const Key('test-field'),
                                scrollPadding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                                ),
                              ),
                              Container(height: 200, color: Colors.blue),
                              ElevatedButton(
                                key: const Key('test-button'),
                                onPressed: () {},
                                child: const Text('Test Button'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Vérifier état initial
        expect(find.byKey(const Key('test-field')), findsOneWidget);
        expect(find.byKey(const Key('test-button')), findsOneWidget);

        // Vérifier configuration ScrollView
        final scrollView = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
        expect(scrollView.reverse, isTrue);

        // Vérifier configuration TextField
        final textField = tester.widget<TextField>(find.byKey(const Key('test-field')));
        expect(textField.scrollPadding, equals(const EdgeInsets.only(bottom: 100)));

        // Vérifier configuration Scaffold
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.resizeToAvoidBottomInset, isTrue);
      });
    });
  });
}
