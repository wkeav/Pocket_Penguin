import 'package:flutter/material.dart';
import 'gamebox_security_validator.dart';

// Game box
class GameBox extends StatefulWidget {
  final Widget child; // additional layers
  final Image sky; // sky
  final Image background;

  const GameBox(
      {super.key,
      required this.child,
      required this.sky,
      required this.background});

  @override
  State<GameBox> createState() => GameBoxState();
}

class GameBoxState extends State<GameBox> {
  // penguin's outfit
  String _hat = 'none';
  String _clothes = 'none';
  String _shoes = 'none';
  // empty string means "no background chosen" (show only sky)
  String _background = '';

  // update functions
  /// CWE-20 Mitigation: Validate input before updating state
  void changeHat(String newHat) {
    try {
      final validatedHat = GameBoxSecurityValidator.validateHat(newHat);
      setState(() => _hat = validatedHat);
    } catch (e) {
      debugPrint('Invalid hat input: $e');
      // Optionally show error to user or silently reject
    }
  }

  void changeClothes(String newClothes) {
    try {
      final validatedClothes =
          GameBoxSecurityValidator.validateClothes(newClothes);
      setState(() => _clothes = validatedClothes);
    } catch (e) {
      debugPrint('Invalid clothes input: $e');
    }
  }

  void changeShoes(String newShoes) {
    try {
      final validatedShoes = GameBoxSecurityValidator.validateShoes(newShoes);
      setState(() => _shoes = validatedShoes);
    } catch (e) {
      debugPrint('Invalid shoes input: $e');
    }
  }

  void changeBackground(String newBackground) {
    try {
      final validatedBackground =
          GameBoxSecurityValidator.validateBackground(newBackground);
      setState(() => _background = validatedBackground);
    } catch (e) {
      debugPrint('Invalid background input: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 12.0),
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(alignment: Alignment.center, children: [
              // Sky: choose day/night based on device time (fallback to widget.sky)
              Positioned.fill(child: Builder(builder: (context) {
                final hour = DateTime.now().hour;
                final bool isDay = hour >= 6 && hour < 18;
                final ImageProvider skyImage = isDay
                    ? const AssetImage('images/skies/pockp_day_sky_bground.png')
                    : const AssetImage(
                        'images/skies/pockp_night_sky_bground.png');
                return Image(
                  image: skyImage,
                  key: const Key('sky'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  isAntiAlias: false,
                );
              })), // Sky (day/night)

              // Background: only render when a background has been selected
              if (_background.isNotEmpty)
                Positioned.fill(
                  child: Image(
                    image: AssetImage('images/backgrounds/$_background.png'),
                    key: const Key('background'),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                  ),
                ),
              widget.child, // Decorations
              // Penguin base and outfit layers
              Transform.scale(
                  scale: 3.5,
                  child: Image.asset(
                    'images/penguin.png',
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                  )),
              // Outfit layers
              if (_hat != 'none')
                Transform.scale(
                    scale: 3.5,
                    child: Image.asset('images/hats/$_hat.png',
                        isAntiAlias: false, filterQuality: FilterQuality.none)),
              if (_clothes != 'none')
                Transform.scale(
                    scale: 3.5,
                    child: Image.asset('images/clothes/$_clothes.png',
                        isAntiAlias: false, filterQuality: FilterQuality.none)),
              if (_shoes != 'none')
                Transform.scale(
                    scale: 3.5,
                    child: Image.asset('images/shoes/$_shoes.png',
                        isAntiAlias: false, filterQuality: FilterQuality.none)),
            ])));
  }
}
