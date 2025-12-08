// Example: How to integrate HabitApi into HabitsScreen
// Replace the current StatefulWidget implementation with this pattern

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../theme/app_theme.dart';

class HabitsScreenWithApi extends StatefulWidget {
  final int fishCoins;
  final Function(int) onFishCoinsChanged;

  const HabitsScreenWithApi({
    super.key,
    required this.fishCoins,
    required this.onFishCoinsChanged,
  });

  @override
  State<HabitsScreenWithApi> createState() => _HabitsScreenWithApiState();
}

class _HabitsScreenWithApiState extends State<HabitsScreenWithApi> {
  List<Habit> habits = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  // Load habits from API
  Future<void> _loadHabits() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedHabits = await HabitApi.fetchHabits();
      setState(() {
        habits = fetchedHabits;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load habits: $e';
        isLoading = false;
      });
    }
  }

  // Update habit progress and sync with backend
  Future<void> _updateHabitProgress(String habitId, int newValue) async {
    // Find the habit locally
    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = habits[habitIndex];
    final wasCompleted = habit.isCompleted;

    // Optimistic update (update UI immediately)
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

    // Sync with backend
    try {
      final updatedHabit = await HabitApi.incrementProgress(habitId, newValue);
      
      // Update with server response (for streak, last_completed, etc.)
      setState(() {
        habits[habitIndex] = updatedHabit;
      });
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update habit: $e')),
      );
    }
  }

  // Create a new habit
  Future<void> _createHabit(Habit newHabit) async {
    try {
      final createdHabit = await HabitApi.createHabit(newHabit);
      setState(() {
        habits.add(createdHabit);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create habit: $e')),
      );
    }
  }

  // Delete a habit
  Future<void> _deleteHabit(String habitId) async {
    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final deletedHabit = habits[habitIndex];

    // Optimistic removal
    setState(() {
      habits.removeAt(habitIndex);
    });

    try {
      await HabitApi.deleteHabit(habitId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit deleted')),
      );
    } catch (e) {
      // Revert on error
      setState(() {
        habits.insert(habitIndex, deletedHabit);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete habit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHabits,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show your existing UI
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Your existing habit list UI here
          // Use habits list from state instead of SampleHabits
          Text('${habits.length} habits loaded from API'),
        ],
      ),
    );
  }
}
