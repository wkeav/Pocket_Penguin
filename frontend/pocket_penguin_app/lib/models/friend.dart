import 'package:flutter/material.dart';

class Friend {
  final int id;
  final String name;
  final String penguinName;
  final int level;
  final int streak;
  final int fishCoins;
  final String lastActive;
  final String avatar;
  final String recentActivity;
  final IconData moodIcon;
  final bool isUser;

  Friend({
    required this.id,
    required this.name,
    required this.penguinName,
    required this.level,
    required this.streak,
    required this.fishCoins,
    required this.lastActive,
    required this.avatar,
    required this.recentActivity,
    required this.moodIcon,
    this.isUser = false,
  });
}

class ActivityItem {
  final String user;
  final String action;
  final String time;
  final ActivityType type;

  ActivityItem({
    required this.user,
    required this.action,
    required this.time,
    required this.type,
  });
}

enum ActivityType { achievement, purchase, levelUp, milestone }

extension ActivityTypeExtension on ActivityType {
  IconData get icon {
    switch (this) {
      case ActivityType.achievement:
        return Icons.emoji_events;
      case ActivityType.purchase:
        return Icons.shopping_bag;
      case ActivityType.levelUp:
        return Icons.trending_up;
      case ActivityType.milestone:
        return Icons.flag;
    }
  }
}

class Challenge {
  final String title;
  final String description;
  final int participants;
  final int daysLeft;
  final String reward;

  Challenge({
    required this.title,
    required this.description,
    required this.participants,
    required this.daysLeft,
    required this.reward,
  });
}

// Sample data
class SampleSocialData {
  static List<Friend> get friends => [
    Friend(
      id: 1,
      name: 'Ejeehi',
      penguinName: 'Frost',
      level: 12,
      streak: 23,
      fishCoins: 567,
      lastActive: '1 hour ago',
      avatar: 'E',
      recentActivity: 'Completed all daily habits!',
      moodIcon: Icons.sentiment_satisfied,
    ),
    Friend(
      id: 2,
      name: 'Sneha',
      penguinName: 'Sparkle',
      level: 10,
      streak: 18,
      fishCoins: 489,
      lastActive: '30 minutes ago',
      avatar: 'S',
      recentActivity: 'Bought a new scarf for Sparkle',
      moodIcon: Icons.star,
    ),
    Friend(
      id: 3,
      name: 'Thien',
      penguinName: 'Thunder',
      level: 9,
      streak: 15,
      fishCoins: 456,
      lastActive: '2 hours ago',
      avatar: 'T',
      recentActivity: 'Achieved \'Meditation Master\' badge',
      moodIcon: Icons.favorite,
    ),
    Friend(
      id: 4,
      name: 'Astra',
      penguinName: 'Cosmos',
      level: 8,
      streak: 12,
      fishCoins: 398,
      lastActive: '45 minutes ago',
      avatar: 'A',
      recentActivity: 'Started journaling daily',
      moodIcon: Icons.sentiment_satisfied,
    ),
    Friend(
      id: 5,
      name: 'Jack',
      penguinName: 'Blizzard',
      level: 7,
      streak: 9,
      fishCoins: 324,
      lastActive: '3 hours ago',
      avatar: 'J',
      recentActivity: 'Completed exercise streak',
      moodIcon: Icons.flash_on,
    ),
    Friend(
      id: 6,
      name: 'Kaitlyn',
      penguinName: 'Luna',
      level: 6,
      streak: 7,
      fishCoins: 298,
      lastActive: '4 hours ago',
      avatar: 'K',
      recentActivity: 'Decorated her home with new items',
      moodIcon: Icons.auto_awesome,
    ),
  ];

  static Friend get brandon => Friend(
    id: 999,
    name: 'Brandon',
    penguinName: 'Waddles',
    level: 5,
    streak: 7,
    fishCoins: 127,
    lastActive: 'Now',
    avatar: 'B',
    recentActivity: 'Building the perfect habit tracker!',
    moodIcon: Icons.sentiment_satisfied,
    isUser: true,
  );

  static List<ActivityItem> get recentActivities => [
    ActivityItem(
      user: 'Ejeehi',
      action: 'completed their meditation streak of 23 days!',
      time: '1 hour ago',
      type: ActivityType.achievement,
    ),
    ActivityItem(
      user: 'Sneha',
      action: 'decorated their home with a new fish sculpture',
      time: '2 hours ago',
      type: ActivityType.purchase,
    ),
    ActivityItem(
      user: 'Thien',
      action: 'reached level 9 with Thunder!',
      time: '3 hours ago',
      type: ActivityType.levelUp,
    ),
    ActivityItem(
      user: 'Astra',
      action: 'wrote their first journal entry',
      time: '4 hours ago',
      type: ActivityType.milestone,
    ),
  ];

  static List<Challenge> get challenges => [
    Challenge(
      title: 'Winter Wellness Week',
      description: 'Complete all daily habits for 7 days',
      participants: 12,
      daysLeft: 3,
      reward: '50 bonus fish coins',
    ),
    Challenge(
      title: 'Step Challenge',
      description: 'Reach 10,000 steps daily as a group',
      participants: 8,
      daysLeft: 5,
      reward: 'Exclusive home decoration',
    ),
  ];
}