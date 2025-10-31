import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          ArcticCard(
            gradientColors: const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
            child: Column(
              children: [
                const Text(
                  'Progress & Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your journey with Waddles',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('127', 'Fish Coins', Colors.amber),
                    const SizedBox(width: 16),
                    _buildStatCard('7', 'Day Streak', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Weekly Overview
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_view_week,
                        color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'This Week\'s Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWeeklyChart(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildWeekStat('Habits', '21/35', 0.6, Colors.green),
                    const SizedBox(width: 16),
                    _buildWeekStat('Todos', '8/12', 0.67, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Habit Completion Chart
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.show_chart, color: Colors.purple, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Habit Completion Rate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHabitProgressChart(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monthly Summary
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Monthly Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMonthlySummaryGrid(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Achievements Progress
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Achievement Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAchievementProgress('First Steps',
                    'Complete your first habit', 1.0, Icons.star),
                const SizedBox(height: 8),
                _buildAchievementProgress('Water Master',
                    'Drink 8 glasses daily for 3 days', 0.6, Icons.water_drop),
                const SizedBox(height: 8),
                _buildAchievementProgress(
                    'Meditation Streak',
                    'Meditate for 7 days in a row',
                    0.4,
                    Icons.self_improvement),
                const SizedBox(height: 8),
                _buildAchievementProgress('Social Butterfly',
                    'Visit 5 friends\' homes', 0.2, Icons.people),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
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

  Widget _buildWeeklyChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final habitData = [0.8, 0.6, 1.0, 0.4, 0.9, 0.3, 0.7];
    final todoData = [0.5, 1.0, 0.7, 0.8, 0.6, 0.4, 0.9];

    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 16,
                height: habitData[index] * 60,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 16,
                height: todoData[index] * 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildWeekStat(
      String label, String value, double progress, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitProgressChart() {
    final habits = [
      HabitProgress('Water', 0.8, Colors.blue),
      HabitProgress('Exercise', 0.6, Colors.green),
      HabitProgress('Meditation', 0.9, Colors.purple),
      HabitProgress('Reading', 0.4, Colors.orange),
      HabitProgress('Steps', 0.7, Colors.red),
    ];

    return Column(
      children: habits
          .map((habit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        habit.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: habit.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${(habit.progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildMonthlySummaryGrid() {
    return Column(
      children: [
        Row(
          children: [
            _buildSummaryItem(
                'Total Habits',
                '89',
                'assets/PocketPenguinIcons/pockp_calendar_icon.png',
                Colors.green),
            const SizedBox(width: 12),
            _buildSummaryItem('Total Todos', '23',
                'assets/PocketPenguinIcons/pockp_habits_icon.png', Colors.teal),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSummaryItem(
                'Journal Entries',
                '12',
                'assets/PocketPenguinIcons/pockp_journal_icon.png',
                Colors.purple),
            const SizedBox(width: 12),
            _buildSummaryItem(
                'Fish Coins',
                '340',
                'assets/PocketPenguinIcons/pockp_fishcoin.png',
                const Color.fromARGB(255, 225, 180, 19)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
      String label, String value, dynamic icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            icon is IconData
                ? Icon(icon, color: color, size: 24)
                : Image.asset(icon, width: 28, height: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementProgress(
      String title, String description, double progress, IconData icon) {
    final isCompleted = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isCompleted ? Colors.green[600] : Colors.grey[600],
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
                    color: isCompleted ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? Colors.green[600] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isCompleted)
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

class HabitProgress {
  final String name;
  final double progress;
  final Color color;

  HabitProgress(this.name, this.progress, this.color);
}
