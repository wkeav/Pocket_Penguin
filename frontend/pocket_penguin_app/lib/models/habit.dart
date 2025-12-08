import 'package:flutter/material.dart';

class Habit {
  final String? id; // UUID from backend (null for new habits)
  final String title;
  final String description;
  final String? icon; // Icon name as string
  final int targetValue;
  final String unit;
  final int currentValue;
  final int reward;
  final String category;
  final String? emoji;
  final String? color;
  final String schedule;
  final String? lastCompleted; // ISO date string
  final int streak;
  final List<bool> weekProgress; // 7 days
  final bool isActive;
  final bool isArchived;
  final String? createdAt; // ISO datetime string
  final String? updatedAt; // ISO datetime string
  final String? startDate; // ISO date string

  Habit({
    this.id,
    required this.title,
    required this.description,
    this.icon,
    required this.targetValue,
    required this.unit,
    this.currentValue = 0,
    required this.reward,
    required this.category,
    this.emoji,
    this.color,
    this.schedule = 'DAILY',
    this.lastCompleted,
    this.streak = 0,
    List<bool>? weekProgress,
    this.isActive = true,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
    this.startDate,
  }) : weekProgress = weekProgress ?? List.filled(7, false);

  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentValue >= targetValue;

  // Convert icon name string to IconData
  IconData get iconData {
    final iconMap = {
      'water_drop': Icons.water_drop,
      'fitness_center': Icons.fitness_center,
      'directions_walk': Icons.directions_walk,
      'self_improvement': Icons.self_improvement,
      'menu_book': Icons.menu_book,
      'restaurant': Icons.restaurant,
      'bedtime': Icons.bedtime,
      'favorite': Icons.favorite,
      'work': Icons.work,
      'school': Icons.school,
      'people': Icons.people,
      'catching_pokemon': Icons.catching_pokemon,
    };
    return iconMap[icon] ?? Icons.check_circle;
  }

  // Create Habit from JSON (API response)
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String?,
      targetValue: json['targetValue'] as int,
      unit: json['unit'] as String? ?? 'times',
      currentValue: json['currentValue'] as int? ?? 0,
      reward: json['reward'] as int? ?? 5,
      category: json['category'] as String? ?? 'General',
      emoji: json['emoji'] as String?,
      color: json['color'] as String?,
      schedule: json['schedule'] as String? ?? 'DAILY',
      lastCompleted: json['last_completed'] as String?,
      streak: json['streak'] as int? ?? 0,
      weekProgress: (json['weekProgress'] as List?)
              ?.map((e) => e as bool)
              .toList() ??
          List.filled(7, false),
      isActive: json['is_active'] as bool? ?? true,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      startDate: json['start_date'] as String?,
    );
  }

  // Convert Habit to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      if (icon != null) 'icon': icon,
      'targetValue': targetValue,
      'unit': unit,
      'currentValue': currentValue,
      'reward': reward,
      'category': category,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      'schedule': schedule,
      if (lastCompleted != null) 'last_completed': lastCompleted,
      'streak': streak,
      // Don't send readonly fields
      // 'weekProgress', 'is_active', 'is_archived', timestamps handled by backend
    };
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? targetValue,
    String? unit,
    int? currentValue,
    int? reward,
    String? category,
    String? emoji,
    String? color,
    String? schedule,
    String? lastCompleted,
    int? streak,
    List<bool>? weekProgress,
    bool? isActive,
    bool? isArchived,
    String? createdAt,
    String? updatedAt,
    String? startDate,
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
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      schedule: schedule ?? this.schedule,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      streak: streak ?? this.streak,
      weekProgress: weekProgress ?? this.weekProgress,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
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
    HabitCategory(
        name: 'Health', icon: Icons.favorite, color: const Color(0xFFEF4444)),
    HabitCategory(
        name: 'Fitness',
        icon: Icons.fitness_center,
        color: const Color(0xFF10B981)),
    HabitCategory(
        name: 'Mindfulness',
        icon: Icons.self_improvement,
        color: const Color(0xFF8B5CF6)),
    HabitCategory(
        name: 'Learning', icon: Icons.school, color: const Color(0xFF3B82F6)),
    HabitCategory(
        name: 'Productivity', icon: Icons.work, color: const Color(0xFFF59E0B)),
    HabitCategory(
        name: 'Social', icon: Icons.people, color: const Color(0xFF06B6D4)),
  ];
}

// Sample habits for initial data 
class SampleHabits {
  static List<Habit> get habits => [
        Habit(
          id: 'sample-1',
          title: 'Drink Water',
          description: 'Stay hydrated throughout the day',
          icon: 'water_drop',
          targetValue: 8,
          unit: 'glasses',
          currentValue: 3,
          reward: 5,
          category: 'Health',
          emoji: '💧',
          weekProgress: [true, true, false, true, false, false, false],
          streak: 3,
        ),
        Habit(
          id: 'sample-2',
          title: 'Daily Steps',
          description: 'Walk 10,000 steps every day',
          icon: 'directions_walk',
          targetValue: 10000,
          unit: 'steps',
          currentValue: 6432,
          reward: 10,
          category: 'Fitness',
          emoji: '🚶',
          weekProgress: [true, false, true, true, false, false, false],
          streak: 2,
        ),
        Habit(
          id: 'sample-3',
          title: 'Meditation',
          description: 'Practice mindfulness meditation',
          icon: 'self_improvement',
          targetValue: 10,
          unit: 'minutes',
          currentValue: 10,
          reward: 8,
          category: 'Mindfulness',
          emoji: '🧘',
          weekProgress: [true, true, true, true, false, false, false],
          streak: 4,
        ),
        Habit(
          id: 'sample-4',
          title: 'Read Books',
          description: 'Read for personal development',
          icon: 'menu_book',
          targetValue: 30,
          unit: 'minutes',
          currentValue: 15,
          reward: 12,
          category: 'Learning',
          emoji: '📚',
          weekProgress: [false, true, true, false, false, false, false],
          streak: 1,
        ),
        Habit(
          id: 'sample-5',
          title: 'Exercise',
          description: 'Complete a workout session',
          icon: 'fitness_center',
          targetValue: 1,
          unit: 'session',
          currentValue: 0,
          reward: 15,
          category: 'Fitness',
          emoji: '💪',
          weekProgress: [true, false, false, true, false, false, false],
          streak: 0,
        ),
      ];
}
