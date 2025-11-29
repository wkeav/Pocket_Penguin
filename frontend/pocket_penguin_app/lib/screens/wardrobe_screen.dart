import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

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
  }
}

class _ItemGrid extends StatelessWidget {
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
