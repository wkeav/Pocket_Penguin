import 'package:flutter/material.dart';

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

  // update functions
  void changeHat(String newHat) => setState(() => _hat = newHat);
  void changeClothes(String newClothes) =>
      setState(() => _clothes = newClothes);
  void changeShoes(String newShoes) => setState(() => _shoes = newShoes);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 12.0),
        width: double.infinity,
        height: 120,
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
              Positioned.fill(
                  child: Image(
                      image: widget.sky.image,
                      key: const Key('sky'),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                      isAntiAlias: false,)), // Sky (behind everything)
              Positioned.fill(
                  child: Image(
                      image: widget.background.image,
                      key: const Key('background'),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                      isAntiAlias: false,)), // Background
              widget.child, // Decorations
              // Penguin base and outfit layers
              Transform.scale(
                scale: 3.5,
                child: Image.asset('images/penguin.png', filterQuality: FilterQuality.none, isAntiAlias: false,)
              ),
              // Outfit layers
              if (_hat != 'none')
                Transform.scale(
                  scale: 3.5,
                  child: Image.asset('images/hats/$_hat.png', isAntiAlias: false, filterQuality: FilterQuality.none)
                ),
              if (_clothes != 'none')
                Transform.scale(
                  scale: 3.5,
                  child: Image.asset('images/clothes/$_hat.png', isAntiAlias: false, filterQuality: FilterQuality.none)
                ),
              if (_shoes != 'none')
                Transform.scale(
                  scale: 3.5,
                  child: Image.asset('images/shoes/$_hat.png', isAntiAlias: false, filterQuality: FilterQuality.none)
                ),
            ])));
  }
}
