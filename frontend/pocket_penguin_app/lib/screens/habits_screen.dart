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

    try {
      // Try to load from API
      final fetchedHabits = await HabitApi.fetchHabits();
      if (mounted) {
        setState(() {
          habits = fetchedHabits;
          useMockData = false;
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to mock data
      if (mounted) {
        setState(() {
          habits = SampleHabits.habits;
          useMockData = true;
          errorMessage = 'Using mock data. API error: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadHabitsFromAPI() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
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
        final updatedHabit = await HabitApi.incrementProgress(habitId, newValue);
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

  /// Mark habit as completed for today and award coins
  Future<void> _completeHabitForToday(String? habitId) async {
    if (habitId == null || useMockData) return;

    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = habits[habitIndex];

    try {
      // Call the completion endpoint
      final response = await HabitApi.completeHabitEndpoint(habitId);
      
      if (mounted) {
        // Update habit with server response
        setState(() {
          habits[habitIndex] = response['habit'];
        });

        // Award coins if this was a new completion
        if (response['new_completion'] == true) {
          final coinsEarned = (response['coins_earned'] as int?) ?? habit.reward;
          widget.onFishCoinsChanged(widget.fishCoins + coinsEarned);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Completed! Earned +$coinsEarned coins'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete: $e')),
        );
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

  Future<void> _addHabit(Habit newHabit) async {
    if (useMockData) {
      // Add to mock data
      setState(() {
        habits.add(newHabit);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit added to mock data')),
      );
    } else {
      // Create via API
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
  }

  Future<void> _deleteHabit(String? habitId) async {
    if (habitId == null) return;

    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final deletedHabit = habits[habitIndex];

    // Optimistic removal
    setState(() {
      habits.removeAt(habitIndex);
    });

    if (useMockData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit deleted from mock data')),
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

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Data Source Banner
              if (useMockData)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Using mock data',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _loadHabitsFromAPI,
                        icon: const Icon(Icons.cloud_download, size: 16),
                        label: const Text('Load API'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (errorMessage != null)
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
                      'Daily Habits Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount / $totalCount Completed',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard('Active', totalCount.toString(), Colors.blue),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          'Completed',
                          completedCount.toString(),
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Habits List
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
                ...habits.map((habit) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHabitCard(habit),
                    )),

              const SizedBox(height: 16),

              // Add New Habit Button
              ArcticCard(
                child: Column(
                  children: [
                    const Text(
                      'Add New Habit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _createNewHabit,
                      icon: const Icon(Icons.add),
                      label: const Text('New Habit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
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
                      'Popular Templates',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHabitTemplate('Water', Icons.water_drop),
                        _buildHabitTemplate('Exercise', Icons.fitness_center),
                        _buildHabitTemplate('Read', Icons.menu_book),
                        _buildHabitTemplate('Meditate', Icons.self_improvement),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  habit.iconData,
                  color: Colors.blue[600],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      habit.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PenguinBadge(
                text: '${habit.reward} coins',
                backgroundColor: Colors.amber[50],
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
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(habit.progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: habit.progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          habit.isCompleted ? Colors.green : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (!habit.isCompleted)
                ElevatedButton.icon(
                  onPressed: () => _updateHabitProgress(
                    habit.id,
                    habit.targetValue,
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
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
                text: '🔥 ${habit.streak}',
                backgroundColor: Colors.orange[50],
                textColor: Colors.orange[800],
              ),
              const Spacer(),
              if (habit.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              const SizedBox(width: 8),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () => _deleteHabit(habit.id),
                  ),
                ],
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        isCompleted ? Colors.green[300]! : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? Colors.green[700] : Colors.grey[600],
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
        final template = Habit(
          title: name,
          description: '$name daily',
          icon: name.toLowerCase(),
          targetValue: 1,
          unit: 'time',
          reward: 5,
          category: 'Health',
        );
        _addHabit(template);
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Habit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Habit Title',
                hintText: 'e.g., Drink Water',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What is this habit about?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetValueController,
              decoration: const InputDecoration(
                labelText: 'Daily Target',
                hintText: '1',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'e.g., glasses, minutes',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rewardController,
              decoration: const InputDecoration(
                labelText: 'Reward (coins)',
                hintText: '5',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: HabitCategories.categories
                  .map((cat) => DropdownMenuItem(
                        value: cat.name,
                        child: Text(cat.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value ?? 'Health';
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a habit title')),
              );
              return;
            }

            final newHabit = Habit(
              title: titleController.text,
              description: descriptionController.text,
              targetValue: int.tryParse(targetValueController.text) ?? 1,
              unit: unitController.text.isEmpty ? 'times' : unitController.text,
              reward: int.tryParse(rewardController.text) ?? 5,
              category: selectedCategory,
              icon: selectedIcon,
            );

            widget.onCreate(newHabit);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
