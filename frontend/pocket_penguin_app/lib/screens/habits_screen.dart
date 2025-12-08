import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
// import '../services/habit_service.dart'; // Uncomment when ready to use API

/// HabitsScreen - Displays and manages user habits
/// 
/// TODO: Replace SampleHabits with API calls:
/// 1. Load habits: habits = await HabitApi.fetchHabits();
/// 2. Create habit: await HabitApi.createHabit(newHabit);
/// 3. Update progress: await HabitApi.incrementProgress(habitId, newValue);
/// 4. Delete habit: await HabitApi.deleteHabit(habitId);
class HabitsScreen extends StatefulWidget {
  final int fishCoins;
  final Function(int) onFishCoinsChanged;

  const HabitsScreen({
    super.key,
    required this.fishCoins,
    required this.onFishCoinsChanged,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Habit> habits = SampleHabits.habits;

  void _updateHabitProgress(String habitId, int newValue) {
    setState(() {
      final habitIndex = habits.indexWhere((h) => h.id == habitId);
      if (habitIndex != -1) {
        final habit = habits[habitIndex];
        final wasCompleted = habit.isCompleted;

        habits[habitIndex] = habit.copyWith(
          currentValue: newValue,
        );

        final isNowCompleted = habits[habitIndex].isCompleted;

        // Award fish coins if completing for the first time
        if (!wasCompleted && isNowCompleted) {
          widget.onFishCoinsChanged(widget.fishCoins + habit.reward);
        } else if (wasCompleted && !isNowCompleted) {
          // Remove coins if uncompleting
          widget.onFishCoinsChanged(widget.fishCoins - habit.reward);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = habits.where((h) => h.isCompleted).length;
    final totalCount = habits.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Stats
          ArcticCard(
            gradientColors: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
            child: Column(
              children: [
                const Text(
                  'Daily Habits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedCount/$totalCount habits completed',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3730A3),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Remaining',
                        '${totalCount - completedCount}', Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatCard(
                        'Completed', '$completedCount', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Habits List
          ...habits.map((habit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHabitCard(habit),
              )),

          const SizedBox(height: 16),

          // Add New Habit Button
          ArcticCard(
            child: Column(
              children: [
                const Icon(Icons.add_circle_outline,
                    size: 40, color: Colors.blue),
                const SizedBox(height: 8),
                const Text(
                  'Add New Habit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Build healthy routines with Waddles',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement add habit functionality
                  },
                  child: const Text('Add Habit'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Habit Templates
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Popular Habits',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHabitTemplate('Drink Water', Icons.water_drop),
                    _buildHabitTemplate('Exercise', Icons.fitness_center),
                    _buildHabitTemplate('Read', Icons.menu_book),
                    _buildHabitTemplate('Meditate', Icons.self_improvement),
                    _buildHabitTemplate('Sleep Early', Icons.bedtime),
                    _buildHabitTemplate('Healthy Eating', Icons.restaurant),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
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

  Widget _buildHabitCard(Habit habit) {
    return ArcticCard(
      backgroundColor: habit.isCompleted ? Colors.grey[50] : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      habit.isCompleted ? Colors.green[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  habit.iconData,
                  color:
                      habit.isCompleted ? Colors.green[600] : Colors.blue[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: habit.isCompleted
                            ? Colors.grey[600]
                            : Colors.grey[900],
                        decoration: habit.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      habit.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PenguinBadge(
                text: '${habit.reward}',
                icon: Icons.catching_pokemon,
                backgroundColor: Colors.amber[100],
                textColor: Colors.amber[800],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${habit.currentValue}/${habit.targetValue} ${habit.unit}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(habit.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: habit.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        habit.isCompleted ? Colors.green : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (!habit.isCompleted) ...[
                IconButton(
                  onPressed: habit.currentValue > 0 && habit.id != null
                      ? () =>
                          _updateHabitProgress(habit.id!, habit.currentValue - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.grey[600],
                ),
                IconButton(
                  onPressed: habit.currentValue < habit.targetValue && habit.id != null
                      ? () =>
                          _updateHabitProgress(habit.id!, habit.currentValue + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.blue[600],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Tags and streak
          Row(
            children: [
              PenguinBadge(
                text: habit.category,
                backgroundColor: Colors.grey[100],
              ),
              const SizedBox(width: 8),
              PenguinBadge(
                text: '${habit.streak} day streak',
                icon: Icons.local_fire_department,
                backgroundColor: Colors.orange[100],
                textColor: Colors.orange[800],
              ),
              const Spacer(),
              if (habit.isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Week progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              final isCompleted = habit.weekProgress[index];
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitTemplate(String name, IconData icon) {
    return InkWell(
      onTap: () {
        // TODO: Implement habit template selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.blue[600]),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
