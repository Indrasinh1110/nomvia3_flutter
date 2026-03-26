// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nomvia/main.dart';

void main() {
  testWidgets('Prompts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NomviaApp()));

    // Verify that the splash screen shows "NOMVIA".
    expect(find.text('NOMVIA'), findsOneWidget);
    
    // Note: Since the Splash screen auto-navigates, comprehensive testing needs pumping for time.
    // For this basic smoke test, just verifying initial render is enough.
  });
}
