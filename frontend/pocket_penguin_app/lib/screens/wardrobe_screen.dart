import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WardrobeScreen extends StatelessWidget {
  final void Function(String category, String name) onItemSelected;

  const WardrobeScreen({
    super.key,
    required this.onItemSelected,
  });

  // Future: fetch items from backend with specific user's owned items
  // For now, all items are hardcoded.
  List<WardrobeItem> _itemsForCategory(String category) {
    switch (category) {
      case 'Hat':
        return [
          WardrobeItem(
            name: 'Bumpy Helmet',
            category: 'Hat',
            fileName: 'pockp_bumpy_helm',
            imagePath: 'images/hats/pockp_bumpy_helm.png',
          ),
          WardrobeItem(
            name: 'Coco Hat',
            category: 'Hat',
            fileName: 'pockp_coco_hat',
            imagePath: 'images/hats/pockp_coco_hat.png',
          ),
          WardrobeItem(
            name: 'Orange Eyebrows',
            category: 'Hat',
            fileName: 'pockp_eyebrows_orange',
            imagePath: 'images/hats/pockp_eyebrows_orange.png',
          ),
          WardrobeItem(
            name: 'Pink Headbow',
            category: 'Hat',
            fileName: 'pockp_headbow_pink',
            imagePath: 'images/hats/pockp_headbow_pink.png',
          ),
          WardrobeItem(
            name: 'Straw Hat',
            category: 'Hat',
            fileName: 'pockp_straw_hat',
            imagePath: 'images/hats/pockp_straw_hat.png',
          ),
        ];
      case 'Clothes':
        return [
          WardrobeItem(
            name: 'Blue Striped Shirt',
            category: 'Clothes',
            fileName: 'pockp_blue_striped_shirt',
            imagePath: 'images/clothes/pockp_blue_striped_shirt.png',
          ),
          WardrobeItem(
            name: 'Red Overalls',
            category: 'Clothes',
            fileName: 'pockp_red_overalls',
            imagePath: 'images/clothes/pockp_red_overalls.png',
          )
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.snowWhite,
        body: Column(
          children: [
            Container(
              color: AppTheme.primaryBlue,
              child: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabAlignment: TabAlignment.center,
                isScrollable: true,
                tabs: [
                  Tab(text: 'Hat'),
                  Tab(text: 'Clothes'),
                  Tab(text: 'Shoes'),
                  Tab(text: 'Background'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ItemGrid(
                    category: 'Hat',
                    items: _itemsForCategory('Hat'),
                    onItemSelected: onItemSelected,
                  ),
                  _ItemGrid(
                    category: 'Clothes',
                    items: _itemsForCategory('Clothes'),
                    onItemSelected: onItemSelected,
                  ),
                  _ItemGrid(
                    category: 'Shoes',
                    items: _itemsForCategory('Shoes'),
                    onItemSelected: onItemSelected,
                  ),
                  _ItemGrid(
                    category: 'Background',
                    items: _itemsForCategory('Background'),
                    onItemSelected: onItemSelected,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WardrobeItem {
  final String name;
  final String category;
  final String fileName;
  final String imagePath;

  WardrobeItem(
      {required this.name, required this.category, required this.fileName, required this.imagePath});
}

class _ItemGrid extends StatelessWidget {
  final String category;
  final List<WardrobeItem> items;
  final void Function(String category, String name) onItemSelected;

  const _ItemGrid({
    required this.category,
    required this.items,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final item = items[index];

          return GestureDetector(
            onTap: () => onItemSelected(category, item.fileName),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppTheme.lightBlue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(0, 32),
                        child: Transform.scale(
                          scale: 2,
                          child: Image.asset(
                          item.imagePath,
                          fit: BoxFit.contain,
                          isAntiAlias: false,
                          filterQuality: FilterQuality.none,
                          ),
                        ),
                      )
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
