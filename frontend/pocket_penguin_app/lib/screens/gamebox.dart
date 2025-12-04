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
  State<GameBox> createState() => _GameBoxState();
}

class _GameBoxState extends State<GameBox> {
<<<<<<< HEAD
  // penguin's outfit
  String _hat = 'none';
  String _clothes = 'none';
  String _shoes = 'none';

  // update functions
  void changeHat(String newHat) => setState(() => _hat = newHat);
  void changeClothes(String newClothes) =>
      setState(() => _clothes = newClothes);
  void changeShoes(String newShoes) => setState(() => _shoes = newShoes);
=======
  // penguin's outfit (reserved for future use)
  // String _hat = 'none';
  // String _clothes = 'none';
  // String _shoes = 'none';

  // update functions (reserved for future use)
  // void changeHat(String newHat) => setState(() => _hat = newHat);
  // void changeClothes(String newClothes) =>
  //     setState(() => _clothes = newClothes);
  // void changeShoes(String newShoes) => setState(() => _shoes = newShoes);
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95

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
<<<<<<< HEAD
=======
                      key: const Key('sky'),
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
                      fit: BoxFit.cover)), // Sky (behind everything)
              Positioned.fill(
                  child: Image(
                      image: widget.background.image,
<<<<<<< HEAD
=======
                      key: const Key('background'),
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
                      fit: BoxFit.cover)), // Background
              widget.child, // Decorations
              Image.asset('images/logo.png',
                  width: 120), // Basic penguin, can change in the future
            ])));
  }
}
