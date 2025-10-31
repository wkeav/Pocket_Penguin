import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_penguin_app/main.dart';
import 'package:pocket_penguin_app/screens/gamebox.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('GameBox renders correctly with sky, background, and child',
      (WidgetTester tester) async {
    // Load sample images for testing (you can use placeholder images)
    final sky = Image.asset('images/backgrounds/pockp_cloud_land_theme.png', key: const Key('sky'));
    final background = Image.asset('images/skies/pockp_day_sky_bground.png', key: const Key('background'));

    // The child widget we expect to see
    const childWidget = Text('Hello Penguin');

    // Build GameBox inside a MaterialApp so it can render properly
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GameBox(
          sky: sky,
          background: background,
          child: childWidget,
        ),
      ),
    ));

    // Let Flutter settle (in case of async image loading)
    await tester.pumpAndSettle();

    // Verify the GameBox appears in the widget tree
    expect(find.byType(GameBox), findsOneWidget);

    // Verify the background layers exist
    expect(find.byKey(const Key('sky')), findsOneWidget);
    expect(find.byKey(const Key('background')), findsOneWidget);

    // Verify the child widget is displayed
    expect(find.text('Hello Penguin'), findsOneWidget);

    // Verify the penguin logo appears
    expect(find.image(const AssetImage('images/logo.png')), findsOneWidget);
  });
}