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
            name: 'Red Bib',
            category: 'Clothes',
            fileName: 'pockp_bib_red',
            imagePath: 'images/clothes/pockp_bib_red.png',
          ),
          WardrobeItem(
            name: 'Red Bowtie',
            category: 'Clothes',
            fileName: 'pockp_bowtie_red',
            imagePath: 'images/clothes/pockp_bowtie_red.png',
          ),
          WardrobeItem(
            name: 'Red Shirt',
            category: 'Clothes',
            fileName: 'pockp_shirt_red',
            imagePath: 'images/clothes/pockp_shirt_red.png',
          ),
          WardrobeItem(
            name: 'Striped Red Shirt',
            category: 'Clothes',
            fileName: 'pockp_striped_shirt_red',
            imagePath: 'images/clothes/pockp_striped_shirt_red.png',
          )
        ];
      case 'Shoes':
        return [
          WardrobeItem(
            name: 'Purple Gold Drip',
            category: 'Shoes',
            fileName: 'pockp_drip_purple_gold',
            imagePath: 'images/shoes/pockp_drip_purple_gold.png',
          ),
          WardrobeItem(
            name: 'Red Drip',
            category: 'Shoes',
            fileName: 'pockp_drip_red',
            imagePath: 'images/shoes/pockp_drip_red.png',
          )
        ];
      case 'Background':
        return [
          WardrobeItem(
            name: 'Cloud Land',
            category: 'Background',
            fileName: 'pockp_cloud_land_theme',
            imagePath: 'images/backgrounds/pockp_cloud_land_theme.png',
          ),
          WardrobeItem(
            name: 'Forest Land',
            category: 'Background',
            fileName: 'pockp_forest_land_theme',
            imagePath: 'images/backgrounds/pockp_forest_land_theme.png',
          ),
          WardrobeItem(
            name: 'Ice Land',
            category: 'Background',
            fileName: 'pockp_ice_land_theme',
            imagePath: 'images/backgrounds/pockp_ice_land_theme.png',
          ),
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
      {required this.name,
      required this.category,
      required this.fileName,
      required this.imagePath});
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
          final offset = category == 'Hat'
              ? const Offset(0, 32)
              : category == 'Clothes'
                  ? const Offset(0, 0)
                  : category == 'Shoes'
                      ? const Offset(0, -16)
                      : Offset.zero;
          return GestureDetector(
            onTap: () => onItemSelected(item.category, item.fileName),
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
                      child: item.category == 'Background'
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.imagePath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                isAntiAlias: false,
                                filterQuality: FilterQuality.none,
                              ),
                            )
                          : Transform.translate(
                              offset: offset,
                              child: Transform.scale(
                                scale: 2,
                                child: Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.contain,
                                  isAntiAlias: false,
                                  filterQuality: FilterQuality.none,
                                ),
                              ),
                            ),
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
