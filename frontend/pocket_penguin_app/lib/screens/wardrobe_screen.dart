import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

<<<<<<< HEAD
class WardrobeScreen extends StatelessWidget{

=======
class WardrobeScreen extends StatelessWidget {
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return DefaultTabController(length: 4, child: Scaffold(
      backgroundColor: AppTheme.snowWhite,
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryBlue,
            child: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Hat'),
                Tab(text: 'Clothes'),
                Tab(text: 'Shoes'),
                Tab(text: 'Background')
              ]
            )
          ),
          const Expanded(
            child: TabBarView(children: [
              _ItemGrid(category: 'Hat'),
              _ItemGrid(category: 'Clothes'),
              _ItemGrid(category: 'Shoes'),
              _ItemGrid(category: 'Background')
            ],)
          )
        ],
      )
    ));
    
=======
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
                        tabs: [
                          Tab(text: 'Hat'),
                          Tab(text: 'Clothes'),
                          Tab(text: 'Shoes'),
                          Tab(text: 'Background')
                        ])),
                const Expanded(
                    child: TabBarView(
                  children: [
                    _ItemGrid(category: 'Hat'),
                    _ItemGrid(category: 'Clothes'),
                    _ItemGrid(category: 'Shoes'),
                    _ItemGrid(category: 'Background')
                  ],
                ))
              ],
            )));
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
  }
}

class _ItemGrid extends StatelessWidget {
<<<<<<< HEAD
    final String category;

    const _ItemGrid({required this.category});

    @override
    Widget build(BuildContext context) {
        // Placeholder item list
        final items = List.generate(8, (i) => '$category ${i + 1}');

        return Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppTheme.lightBlue,
                    child: Center(
                    child: Text(
                        items[index],
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    ),
                );
                },
            ),
        );
    }
}
=======
  final String category;

  const _ItemGrid({required this.category});

  @override
  Widget build(BuildContext context) {
    // Placeholder item list
    final items = List.generate(8, (i) => '$category ${i + 1}');

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppTheme.lightBlue,
            child: Center(
              child: Text(
                items[index],
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
