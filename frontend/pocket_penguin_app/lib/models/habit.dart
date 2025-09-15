import 'package:flutter/material.dart';

class Habit {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final int targetValue;
  final String unit;
  final int currentValue;
  final int reward;
  final String category;
  final bool isCompleted;
  final List<bool> weekProgress; // 7 days
  final int streak;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.unit,
    this.currentValue = 0,
    required this.reward,
    required this.category,
    this.isCompleted = false,
    List<bool>? weekProgress,
    this.streak = 0,
  }) : weekProgress = weekProgress ?? List.filled(7, false);

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  Habit copyWith({
    int? id,
    String? title,
    String? description,
    IconData? icon,
    int? targetValue,
    String? unit,
    int? currentValue,
    int? reward,
    String? category,
    bool? isCompleted,
    List<bool>? weekProgress,
    int? streak,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      currentValue: currentValue ?? this.currentValue,
      reward: reward ?? this.reward,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      weekProgress: weekProgress ?? this.weekProgress,
      streak: streak ?? this.streak,
    );
  }
}

class HabitCategory {
  final String name;
  final IconData icon;
  final Color color;

  HabitCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Predefined habit categories
class HabitCategories {
  static final List<HabitCategory> categories = [
    HabitCategory(name: 'Health', icon: Icons.favorite, color: const Color(0xFFEF4444)),
    HabitCategory(name: 'Fitness', icon: Icons.fitness_center, color: const Color(0xFF10B981)),
    HabitCategory(name: 'Mindfulness', icon: Icons.self_improvement, color: const Color(0xFF8B5CF6)),
    HabitCategory(name: 'Learning', icon: Icons.school, color: const Color(0xFF3B82F6)),
    HabitCategory(name: 'Productivity', icon: Icons.work, color: const Color(0xFFF59E0B)),
    HabitCategory(name: 'Social', icon: Icons.people, color: const Color(0xFF06B6D4)),
  ];
}

// Sample habits for initial data
class SampleHabits {
  static List<Habit> get habits => [
    Habit(
      id: 1,
      title: 'Drink Water',
      description: 'Stay hydrated throughout the day',
      icon: Icons.water_drop,
      targetValue: 8,
      unit: 'glasses',
      currentValue: 3,
      reward: 5,
      category: 'Health',
      weekProgress: [true, true, false, true, false, false, false],
      streak: 3,
    ),
    Habit(
      id: 2,
      title: 'Daily Steps',
      description: 'Walk 10,000 steps every day',
      icon: Icons.directions_walk,
      targetValue: 10000,
      unit: 'steps',
      currentValue: 6432,
      reward: 10,
      category: 'Fitness',
      weekProgress: [true, false, true, true, false, false, false],
      streak: 2,
    ),
    Habit(
      id: 3,
      title: 'Meditation',
      description: 'Practice mindfulness meditation',
      icon: Icons.self_improvement,
      targetValue: 10,
      unit: 'minutes',
      currentValue: 10,
      reward: 8,
      category: 'Mindfulness',
      isCompleted: true,
      weekProgress: [true, true, true, true, false, false, false],
      streak: 4,
    ),
    Habit(
      id: 4,
      title: 'Read Books',
      description: 'Read for personal development',
      icon: Icons.menu_book,
      targetValue: 30,
      unit: 'minutes',
      currentValue: 15,
      reward: 12,
      category: 'Learning',
      weekProgress: [false, true, true, false, false, false, false],
      streak: 1,
    ),
    Habit(
      id: 5,
      title: 'Exercise',
      description: 'Complete a workout session',
      icon: Icons.fitness_center,
      targetValue: 1,
      unit: 'session',
      currentValue: 0,
      reward: 15,
      category: 'Fitness',
      weekProgress: [true, false, false, true, false, false, false],
      streak: 0,
    ),
  ];
}