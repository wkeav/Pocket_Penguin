import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final int fishCoins;
  final Function(int) onFishCoinsChanged;

  const HomeScreen({
    super.key,
    required this.fishCoins,
    required this.onFishCoinsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          ArcticCard(
            gradientColors: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 30,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          Text(
                            'Waddles is excited to see you!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Level', '5', Icons.trending_up, Colors.blue),
                    const SizedBox(width: 12),
                    _buildStatCard('Streak', '7 days', Icons.local_fire_department, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Today's Progress
          ArcticCard(
            gradientColors: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.today, color: Color(0xFF1D4ED8), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Today\'s Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildProgressCard('Habits', '3/5', 0.6, Colors.green),
                    const SizedBox(width: 12),
                    _buildProgressCard('Todos', '1/4', 0.25, Colors.blue),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.catching_pokemon, color: Color(0xFFF59E0B), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Earned 23 fish coins today!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildActionButton('Add Habit', Icons.add_circle, Colors.green),
                    const SizedBox(width: 8),
                    _buildActionButton('Add Todo', Icons.add_task, Colors.blue),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildActionButton('Journal Entry', Icons.book, Colors.purple),
                    const SizedBox(width: 8),
                    _buildActionButton('View Progress', Icons.bar_chart, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Waddles' Home
          ArcticCard(
            gradientColors: const [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.home, color: Color(0xFF0284C7), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Waddles\' Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 40, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'Waddles is relaxing at home',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.shopping_cart, size: 16),
                        label: const Text('Shop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.palette, size: 16),
                        label: const Text('Decorate'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue[600]!),
                          foregroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent Achievements
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Recent Achievements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAchievementItem(
                  'First Steps',
                  'Complete your first habit',
                  Icons.star,
                  true,
                ),
                const SizedBox(height: 8),
                _buildAchievementItem(
                  'Water Master',
                  'Drink 8 glasses of water',
                  Icons.water_drop,
                  false,
                ),
                const SizedBox(height: 8),
                _buildAchievementItem(
                  'Meditation Beginner',
                  'Meditate for 3 days in a row',
                  Icons.self_improvement,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String label, String progress, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              progress,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(String title, String description, IconData icon, bool completed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: completed ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: completed ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: completed ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 16,
              color: completed ? Colors.green[600] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: completed ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: completed ? Colors.green[600] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 20,
            ),
        ],
      ),
    );
  }
}