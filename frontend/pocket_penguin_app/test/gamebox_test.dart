import 'package:flutter_test/flutter_test.dart';
<<<<<<< HEAD
import 'package:pocket_penguin_app/main.dart';
=======
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
import 'package:pocket_penguin_app/screens/gamebox.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('GameBox renders correctly with sky, background, and child',
      (WidgetTester tester) async {
    // Load sample images for testing (you can use placeholder images)
<<<<<<< HEAD
    final sky = Image.asset('images/sky.png');
    final background = Image.asset('images/background.png');
=======
    final sky = Image.asset('images/backgrounds/pockp_cloud_land_theme.png',
        key: const Key('sky'));
    final background = Image.asset('images/skies/pockp_day_sky_bground.png',
        key: const Key('background'));
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95

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
<<<<<<< HEAD
    expect(find.byWidget(sky), findsOneWidget);
    expect(find.byWidget(background), findsOneWidget);
=======
    expect(find.byKey(const Key('sky')), findsOneWidget);
    expect(find.byKey(const Key('background')), findsOneWidget);
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95

    // Verify the child widget is displayed
    expect(find.text('Hello Penguin'), findsOneWidget);

    // Verify the penguin logo appears
    expect(find.image(const AssetImage('images/logo.png')), findsOneWidget);
  });
<<<<<<< HEAD
}
=======
}
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
