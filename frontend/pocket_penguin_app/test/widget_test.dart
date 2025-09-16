// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_penguin_app/main.dart';

void main() {
  testWidgets('Pocket Penguin app loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketPenguinApp());

    // Verify that the app loads without crashing
    expect(find.byType(PocketPenguinApp), findsOneWidget);
  });

  testWidgets('App title is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketPenguinApp());

    // Verify that the app title is displayed
    expect(find.text('Pocket Penguin'), findsOneWidget);
  });

  testWidgets('Fish coins counter is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketPenguinApp());

    // Verify that fish coins are displayed 
    expect(find.text('127 coins'), findsOneWidget);
  });
}
