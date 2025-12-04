import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/social_screen.dart';
import 'screens/achievements_screen.dart';
import 'theme/app_theme.dart';
import 'screens/gamebox.dart';
import 'screens/wardrobe_screen.dart';
<<<<<<< HEAD
=======
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95

void main() {
  runApp(const PocketPenguinApp());
}

class PocketPenguinApp extends StatelessWidget {
  const PocketPenguinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Penguin',
      theme: AppTheme.lightTheme,
      home: const MainScreen(), // Always show main screen with mock data
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeTab = 2;
  int _fishCoins = 127;

  final List<TabItem> _tabs = [
    TabItem(
        id: 'habits',
        label: 'Habits',
        icon: Image.asset("images/icons/pockp_habits_icon.png",
            width: 32, height: 32)),
    TabItem(
        id: 'wardrobe',
        label: 'Wardrobe',
        icon: Icon(Icons.door_sliding, size: 32)),
    TabItem(
        id: 'home',
        label: 'Home',
        icon: Image.asset("images/pockpo_house.png", width: 32, height: 32)),
    TabItem(
        id: 'todo',
        label: 'Todo',
        icon: Image.asset("images/icons/pockp_todo_icon.png",
            width: 32, height: 32)),
    TabItem(
        id: 'journal',
        label: 'Journal',
        icon: Image.asset("images/icons/pockp_journal_icon.png",
            width: 32, height: 32)),
    TabItem(
        id: 'calendar',
        label: 'Calendar',
        icon: Image.asset("images/icons/pockp_calendar_icon.png",
            width: 32, height: 32)),
    TabItem(
        id: 'progress',
        label: 'Progress',
        icon: Image.asset("images/icons/pockp_progress_icon.png",
            width: 32, height: 32)),
    TabItem(
        id: 'social',
        label: 'Friends',
        icon: Image.asset("images/icons/pockp_friends_icon.png",
            width: 32, height: 32)),
    TabItem(
        id: 'achievements',
        label: 'Awards',
        icon: Image.asset("images/icons/pockp_awards_icon.png",
            width: 32, height: 32)),
  ];

  void _updateFishCoins(int newAmount) {
    setState(() {
      _fishCoins = newAmount;
    });
  }

  Widget _renderContent() {
    switch (_activeTab) {
      case 2:
        return Column(children: [
<<<<<<< HEAD
          GameBox(background: Image.asset('images/backgrounds/pockp_cloud_land_theme.png'), sky: Image.asset('images/skies/pockp_day_sky_bground.png'),child: const SizedBox()), // TODO: Dynamically change sky according to time
          Expanded(child: HomeScreen(fishCoins: _fishCoins, onFishCoinsChanged: _updateFishCoins))
        ]);
      case 1:
        return Column(children: [
          GameBox(background: Image.asset('images/backgrounds/pockp_cloud_land_theme.png'), sky: Image.asset('images/skies/pockp_day_sky_bground.png'),child: const SizedBox()), // TODO: Dynamically change sky according to time
=======
          GameBox(
              background:
                  Image.asset('images/backgrounds/pockp_cloud_land_theme.png'),
              sky: Image.asset('images/skies/pockp_day_sky_bground.png'),
              child:
                  const SizedBox()), // TODO: Dynamically change sky according to time
          Expanded(
              child: HomeScreen(
                  fishCoins: _fishCoins, onFishCoinsChanged: _updateFishCoins))
        ]);
      case 1:
        return Column(children: [
          GameBox(
              background:
                  Image.asset('images/backgrounds/pockp_cloud_land_theme.png'),
              sky: Image.asset('images/skies/pockp_day_sky_bground.png'),
              child:
                  const SizedBox()), // TODO: Dynamically change sky according to time
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
          const Expanded(child: WardrobeScreen())
        ]);
      case 0:
        return HabitsScreen(
            fishCoins: _fishCoins, onFishCoinsChanged: _updateFishCoins);
      case 3:
        return TodoScreen(
            fishCoins: _fishCoins, onFishCoinsChanged: _updateFishCoins);
      case 4:
        return const JournalScreen();
      case 5:
        return const CalendarScreen();
      case 6:
        return const ProgressScreen();
      case 7:
        return const SocialScreen();
      case 8:
        return const AchievementsScreen();
      default:
        return HomeScreen(
            fishCoins: _fishCoins, onFishCoinsChanged: _updateFishCoins);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 375, // iPhone width
          height: 800,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.grey[800]!, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Column(
              children: [
                // Phone Notch
                Container(
                  width: 128,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(color: Colors.blue[100]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
<<<<<<< HEAD
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset("images/logo.png", width: 32, height: 32),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Pocket Penguin',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
=======
                      GestureDetector(
                        onTap: () async {
                          // Create auth service instance & if user is logged in
                          final authService = AuthService();
                          final isLoggedIn = await authService.isLoggedIn();
                          if (mounted) {
                            if (isLoggedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AuthScreen(),
                                ),
                              );
                            }
                          }
                        },
                        child: Row(
                          children: [
                            // Penguin logo and text
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.asset("images/logo.png",
                                  width: 32, height: 32),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Pocket Penguin',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.catching_pokemon,
                                size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              '$_fishCoins coins',
                              style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _renderContent(),
                ),
                // Bottom Navigation
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: _tabs.map((tab) {
                    final index = _tabs.indexOf(tab);
                    final isActive = _activeTab == index;
                    return GestureDetector(
                      onTap: () => setState(() => _activeTab = index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
<<<<<<< HEAD
                          color: isActive ? Colors.blue[100] : Colors.transparent,
=======
                          color:
                              isActive ? Colors.blue[100] : Colors.transparent,
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconTheme(
                              data: IconThemeData(
<<<<<<< HEAD
                                color: isActive ? Colors.blue[600] : Colors.grey[500],
=======
                                color: isActive
                                    ? Colors.blue[600]
                                    : Colors.grey[500],
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
                                size: 20,
                              ),
                              child: tab.icon,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 12,
<<<<<<< HEAD
                                color: isActive ? Colors.blue[600] : Colors.grey[500],
=======
                                color: isActive
                                    ? Colors.blue[600]
                                    : Colors.grey[500],
>>>>>>> f8d3d03644b52cdfc75cccf6a0cf19a75e8a8c95
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )

                // Container(
                //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     border: Border(
                //       top: BorderSide(color: Colors.blue[100]!),
                //     ),
                //   ),
                //   child: Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       // First row of tabs (0-4)
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                //         children: _tabs.take(5).map((tab) {
                //           final index = _tabs.indexOf(tab);
                //           final isActive = _activeTab == index;
                //           return GestureDetector(
                //             onTap: () => setState(() => _activeTab = index),
                //             child: Container(
                //               padding: const EdgeInsets.all(8),
                //               decoration: BoxDecoration(
                //                 color: isActive
                //                     ? Colors.blue[100]
                //                     : Colors.transparent,
                //                 borderRadius: BorderRadius.circular(8),
                //               ),
                //               child: Column(
                //                 mainAxisSize: MainAxisSize.min,
                //                 children: [
                //                   IconTheme(
                //                     data: IconThemeData(
                //                       color: isActive ? Colors.blue[600] : Colors.grey[500],
                //                       size: 20,
                //                     ),
                //                     child: tab.icon,
                //                   ),
                //                   const SizedBox(height: 4),
                //                   Text(
                //                     tab.label,
                //                     style: TextStyle(
                //                       fontSize: 12,
                //                       color: isActive
                //                           ? Colors.blue[600]
                //                           : Colors.grey[500],
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           );
                //         }).toList(),
                //       ),
                //       const SizedBox(height: 4),
                //       // Second row of tabs (5-7)
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                //         children: [
                //           const SizedBox(width: 60), // Spacer for alignment
                //           ..._tabs.skip(5).map((tab) {
                //             final index = _tabs.indexOf(tab);
                //             final isActive = _activeTab == index;
                //             return GestureDetector(
                //               onTap: () => setState(() => _activeTab = index),
                //               child: Container(
                //                 padding: const EdgeInsets.all(8),
                //                 decoration: BoxDecoration(
                //                   color: isActive
                //                       ? Colors.blue[100]
                //                       : Colors.transparent,
                //                   borderRadius: BorderRadius.circular(8),
                //                 ),
                //                 child: Column(
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: [
                //                     IconTheme(
                //                       data: IconThemeData(
                //                         color: isActive ? Colors.blue[600] : Colors.grey[500],
                //                         size: 20,
                //                       ),
                //                       child: tab.icon,
                //                     ),
                //                     const SizedBox(height: 4),
                //                     Text(
                //                       tab.label,
                //                       style: TextStyle(
                //                         fontSize: 12,
                //                         color: isActive
                //                             ? Colors.blue[600]
                //                             : Colors.grey[500],
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             );
                //           }).toList(),
                //           const SizedBox(width: 60), // Spacer for alignment
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabItem {
  final String id;
  final String label;
  final Widget icon;

  TabItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}
