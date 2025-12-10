import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../services/habit_service.dart';

/// HabitsScreen - Displays and manages user habits
///
/// Features:
/// 1. Load habits from API or show mock data
/// 2. Add new habits via API
/// 3. Update habit progress and sync with backend
/// 4. Delete habits
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
  List<Habit> habits = [];
  bool isLoading = false;
  bool useMockData = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeHabits();
  }

  Future<void> _initializeHabits() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try to load from API
      if (userToken != null) {
        final fetchedHabits = await HabitApi.fetchHabits(userToken!);
        if (mounted) {
          setState(() {
            habits = fetchedHabits;
            useMockData = false;
            isLoading = false;
          });
        }
      } else {
        // No alert, just show empty habits
        if (mounted) {
          setState(() {
            habits = [];
            useMockData = false;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      // Fallback to mock data only if needed, no alert
      if (mounted) {
        setState(() {
          habits = [];
          useMockData = false;
          isLoading = false;
        });
      }
    }
        // Call this after user logs in to refresh habits
        void onUserLoggedIn(String token) async {
          setState(() {
            userToken = token;
          });
          await _initializeHabits();
        }
      final fetchedHabits = await HabitApi.fetchHabits();
      if (mounted) {
        setState(() {
          habits = fetchedHabits;
          useMockData = false;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load from API: $e';
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _updateHabitProgress(String? habitId, int newValue) async {
    if (habitId == null) return;

    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = habits[habitIndex];
    final wasCompleted = habit.isCompleted;

    // Optimistic update
    setState(() {
      habits[habitIndex] = habit.copyWith(currentValue: newValue);
    });

    final isNowCompleted = habits[habitIndex].isCompleted;

    // Update fish coins locally
    if (!wasCompleted && isNowCompleted) {
      widget.onFishCoinsChanged(widget.fishCoins + habit.reward);
    } else if (wasCompleted && !isNowCompleted) {
      widget.onFishCoinsChanged(widget.fishCoins - habit.reward);
    }

    // Sync with backend only if not using mock data
    if (!useMockData) {
      try {
        final updatedHabit =
            await HabitApi.incrementProgress(habitId, newValue);
        if (mounted) {
          setState(() {
            habits[habitIndex] = updatedHabit;
          });
        }
      } catch (e) {
        // Revert on error
        setState(() {
          habits[habitIndex] = habit;
        });

        // Revert fish coins
        if (!wasCompleted && isNowCompleted) {
          widget.onFishCoinsChanged(widget.fishCoins - habit.reward);
        } else if (wasCompleted && !isNowCompleted) {
          widget.onFishCoinsChanged(widget.fishCoins + habit.reward);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: $e')),
          );
        }
      }
    }
  }

  Future<void> _createNewHabit() async {
    showDialog(
      context: context,
      builder: (context) => _CreateHabitDialog(
        onCreate: (newHabit) async {
          Navigator.of(context).pop();
          await _addHabit(newHabit);
        },
      ),
    );
  }

  Future<void> _createPresetHabit({
    required String title,
    required String description,
    required String icon,
    required int targetValue,
    required String unit,
    required int reward,
    required String category,
  }) async {
    final newHabit = Habit(
      title: title,
      description: description,
      icon: icon,
      targetValue: targetValue,
      unit: unit,
      reward: reward,
      category: category,
    );

    await _addHabit(newHabit);
  }

  Future<void> _addHabit(Habit newHabit) async {
    // Always try to create via API
    try {
      final createdHabit = await HabitApi.createHabit(newHabit);
      if (mounted) {
        setState(() {
          habits.add(createdHabit);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create habit: $e')),
        );
      }
    }
  }

  Future<void> _deleteHabit(String? habitId) async {
    if (habitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete this habit - no ID')),
      );
      return;
    }

    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit not found')),
      );
      return;
    }

    final deletedHabit = habits[habitIndex];

    // Optimistic removal
    setState(() {
      habits.removeAt(habitIndex);
    });

    if (useMockData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit deleted')),
      );
    } else {
      try {
        await HabitApi.deleteHabit(habitId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit deleted')),
          );
        }
      } catch (e) {
        // Revert on error
        setState(() {
          habits.insert(habitIndex, deletedHabit);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = habits.where((h) => h.isCompleted).length;
    final totalCount = habits.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Error Banner
          if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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

          // Loading indicator
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (habits.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No habits yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _createNewHabit,
                      icon: const Icon(Icons.add),
                      label: const Text('Create First Habit'),
                    ),
                  ],
                ),
              ),
            )
          else
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
                  onPressed: _createNewHabit,
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
                    _buildHabitTemplate(
                      'Drink Water',
                      Icons.water_drop,
                      () => _createPresetHabit(
                        title: 'Drink Water',
                        description: 'Stay hydrated throughout the day',
                        icon: 'water_drop',
                        targetValue: 8,
                        unit: 'glasses',
                        reward: 5,
                        category: 'Health',
                      ),
                    ),
                    _buildHabitTemplate(
                      'Exercise',
                      Icons.fitness_center,
                      () => _createPresetHabit(
                        title: 'Exercise',
                        description: 'Daily workout routine',
                        icon: 'fitness_center',
                        targetValue: 30,
                        unit: 'minutes',
                        reward: 10,
                        category: 'Fitness',
                      ),
                    ),
                    _buildHabitTemplate(
                      'Read',
                      Icons.menu_book,
                      () => _createPresetHabit(
                        title: 'Read',
                        description: 'Read books or articles',
                        icon: 'menu_book',
                        targetValue: 20,
                        unit: 'pages',
                        reward: 8,
                        category: 'Learning',
                      ),
                    ),
                    _buildHabitTemplate(
                      'Meditate',
                      Icons.self_improvement,
                      () => _createPresetHabit(
                        title: 'Meditate',
                        description: 'Practice mindfulness meditation',
                        icon: 'self_improvement',
                        targetValue: 10,
                        unit: 'minutes',
                        reward: 8,
                        category: 'Mindfulness',
                      ),
                    ),
                    _buildHabitTemplate(
                      'Sleep Early',
                      Icons.bedtime,
                      () => _createPresetHabit(
                        title: 'Sleep Early',
                        description: 'Go to bed before 10 PM',
                        icon: 'bedtime',
                        targetValue: 1,
                        unit: 'times',
                        reward: 7,
                        category: 'Health',
                      ),
                    ),
                    _buildHabitTemplate(
                      'Healthy Eating',
                      Icons.restaurant,
                      () => _createPresetHabit(
                        title: 'Healthy Eating',
                        description: 'Eat nutritious meals',
                        icon: 'restaurant',
                        targetValue: 3,
                        unit: 'meals',
                        reward: 10,
                        category: 'Health',
                      ),
                    ),
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
              // Delete menu
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                padding: EdgeInsets.zero,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                    onTap: () => _deleteHabit(habit.id),
                  ),
                ],
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
                  onPressed: habit.currentValue > 0
                      ? () =>
                          _updateHabitProgress(habit.id, habit.currentValue - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.grey[600],
                ),
                IconButton(
                  onPressed: habit.currentValue < habit.targetValue
                      ? () =>
                          _updateHabitProgress(habit.id, habit.currentValue + 1)
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

  Widget _buildHabitTemplate(String name, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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

class _CreateHabitDialog extends StatefulWidget {
  final Function(Habit) onCreate;

  const _CreateHabitDialog({required this.onCreate});

  @override
  State<_CreateHabitDialog> createState() => _CreateHabitDialogState();
}

class _CreateHabitDialogState extends State<_CreateHabitDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController targetValueController;
  late TextEditingController unitController;
  late TextEditingController rewardController;
  String selectedCategory = 'Health';
  String selectedIcon = 'fitness_center';
  List<bool> selectedDays = [true, true, true, true, true, true, true];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    targetValueController = TextEditingController(text: '1');
    unitController = TextEditingController(text: 'times');
    rewardController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    targetValueController.dispose();
    unitController.dispose();
    rewardController.dispose();
    super.dispose();
  }

  String _getIconNameForCategory(String categoryName) {
    final iconMap = {
      'Health': 'favorite',
      'Fitness': 'fitness_center',
      'Mindfulness': 'self_improvement',
      'Learning': 'school',
      'Productivity': 'work',
      'Social': 'people',
    };
    return iconMap[categoryName] ?? 'check_circle';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Create New Habit',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 24),

              // Habit Title Field
              const Text(
                'Habit Title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Drink Water',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 20),

              // Description Field
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'What is this habit about?',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Daily Target Field
              const Text(
                'Daily Target',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: targetValueController,
                decoration: const InputDecoration(
                  hintText: '1',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Unit Field
              const Text(
                'Unit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  hintText: 'e.g., glasses, minutes, times',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 20),

              // Reward Field
              const Text(
                'Reward (coins)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rewardController,
                decoration: const InputDecoration(
                  hintText: '5',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: HabitCategories.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat.name,
                            child: Text(cat.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value ?? 'Health';
                      // Auto-set icon based on category
                      selectedIcon = _getIconNameForCategory(selectedCategory);
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Schedule Section
              const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  final isSelected = selectedDays[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDays[index] = !selectedDays[index];
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          days[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a habit title'),
                          ),
                        );
                        return;
                      }

                      final newHabit = Habit(
                        title: titleController.text,
                        description: descriptionController.text,
                        targetValue:
                            int.tryParse(targetValueController.text) ?? 1,
                        unit: unitController.text.isEmpty
                            ? 'times'
                            : unitController.text,
                        reward: int.tryParse(rewardController.text) ?? 5,
                        category: selectedCategory,
                        icon: selectedIcon,
                        weekProgress: List<bool>.from(selectedDays),
                      );

                      widget.onCreate(newHabit);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
