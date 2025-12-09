import 'package:flutter/material.dart';
import '../utilities/stats_container.dart';
import '../constants/colors.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Wrap(
          spacing: 8,
          children: [
            Icon(
              Icons.analytics,
              color: Colors.white,
            ),
            Text(
              'Stats',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatsContainer(
                icon: Icons.notifications,
                stat: '10', // Dummy data for demonstration
              ),
              const SizedBox(height: 20),
              StatsContainer(
                icon: Icons.schedule,
                stat: '5', // Dummy data for demonstration
              ),
              const SizedBox(height: 20),
              StatsContainer(
                icon: Icons.cancel,
                stat: '2', // Dummy data for demonstration
              ),
            ],
          ),
        ),
      ),
    );
  }
}
