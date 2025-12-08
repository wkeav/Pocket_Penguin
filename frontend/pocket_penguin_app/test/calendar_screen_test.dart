import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_penguin_app/screens/calendar_screen.dart';

void main() {
  testWidgets('CalendarScreen opens and has a clickable button',
      (WidgetTester tester) async {
    // Wrap CalendarScreen in MaterialApp + Scaffold
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarScreen(),
        ),
      ),
    );

    // Wait for any async build
    await tester.pumpAndSettle();

    // Check that CalendarScreen shows up
    expect(find.byType(CalendarScreen), findsOneWidget);

    // Find a clickable widget (InkWell, ElevatedButton, IconButton, etc.)
    final clickable = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell || widget is ElevatedButton || widget is IconButton,
    );

    // Make sure there is at least one clickable widget
    expect(clickable, findsWidgets);

    // Tap the first one
    await tester.tap(clickable.first);
    await tester.pump();
  });
}
