import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double progress;
  final int requirement;
  final String category;
  final int reward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.progress = 0.0,
    required this.requirement,
    required this.category,
    required this.reward,
  });
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalRewards = achievements.where((a) => a.isUnlocked).fold(0, (sum, a) => sum + a.reward);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          ArcticCard(
            gradientColors: const [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            child: Column(
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unlock badges and earn rewards',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA16207),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('$unlockedCount/${achievements.length}', 'Unlocked', Colors.amber),
                    const SizedBox(width: 16),
                    _buildStatCard('$totalRewards', 'Fish Coins', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Achievement Categories
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
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
                    _buildCategoryChip('All', true),
                    _buildCategoryChip('Habits', false),
                    _buildCategoryChip('Social', false),
                    _buildCategoryChip('Progress', false),
                    _buildCategoryChip('Special', false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recently Unlocked
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.new_releases, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Recently Unlocked',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...achievements
                    .where((a) => a.isUnlocked)
                    .take(3)
                    .map((achievement) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildRecentAchievementItem(achievement),
                        )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // All Achievements
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Achievements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 16),
                ...achievements.map((achievement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAchievementCard(achievement),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Special Challenges
          ArcticCard(
            gradientColors: const [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Special Challenges',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSpecialChallenge(
                  'Perfect Week',
                  'Complete all habits for 7 days straight',
                  'Limited Time: 3 days left',
                  100,
                  Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _buildSpecialChallenge(
                  'Social Butterfly',
                  'Visit 10 friends\' homes this month',
                  'Monthly Challenge',
                  75,
                  Icons.people,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Achievement Store
          ArcticCard(
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.store, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Achievement Store',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Spend your earned fish coins on exclusive items!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart, size: 16),
                  label: const Text('Visit Store'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[100] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.blue[700] : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildRecentAchievementItem(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          PenguinBadge(
            text: '+${achievement.reward}',
            icon: Icons.catching_pokemon,
            backgroundColor: Colors.amber[100],
            textColor: Colors.amber[800],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked ? achievement.color.withOpacity(0.3) : Colors.grey[200]!,
        ),
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: achievement.color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color.withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.isUnlocked ? achievement.color : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: achievement.isUnlocked ? Colors.black : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (achievement.isUnlocked)
                          Icon(
                            Icons.check_circle,
                            color: achievement.color,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: achievement.isUnlocked ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PenguinBadge(
                          text: achievement.category,
                          backgroundColor: Colors.grey[100],
                          textColor: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        PenguinBadge(
                          text: '${achievement.reward}',
                          icon: Icons.catching_pokemon,
                          backgroundColor: Colors.amber[100],
                          textColor: Colors.amber[800],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!achievement.isUnlocked) ...[
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${(achievement.progress * achievement.requirement).toInt()}/${achievement.requirement}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: achievement.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialChallenge(String title, String description, String timeLimit, int reward, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PenguinBadge(
                text: '$reward',
                icon: Icons.catching_pokemon,
                backgroundColor: Colors.amber[100],
                textColor: Colors.amber[800],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeLimit,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.purple[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Achievement> _getAchievements() {
    return [
      Achievement(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Complete your first habit',
        icon: Icons.star,
        color: Colors.blue,
        isUnlocked: true,
        requirement: 1,
        category: 'Habits',
        reward: 10,
      ),
      Achievement(
        id: 'water_master',
        title: 'Water Master',
        description: 'Drink 8 glasses of water in a day',
        icon: Icons.water_drop,
        color: Colors.blue,
        progress: 0.6,
        requirement: 8,
        category: 'Habits',
        reward: 15,
      ),
      Achievement(
        id: 'meditation_guru',
        title: 'Meditation Guru',
        description: 'Meditate for 7 days in a row',
        icon: Icons.self_improvement,
        color: Colors.purple,
        progress: 0.4,
        requirement: 7,
        category: 'Habits',
        reward: 25,
      ),
      Achievement(
        id: 'social_starter',
        title: 'Social Starter',
        description: 'Add your first friend',
        icon: Icons.people,
        color: Colors.green,
        isUnlocked: true,
        requirement: 1,
        category: 'Social',
        reward: 10,
      ),
      Achievement(
        id: 'home_decorator',
        title: 'Home Decorator',
        description: 'Buy your first decoration',
        icon: Icons.home,
        color: Colors.orange,
        progress: 0.0,
        requirement: 1,
        category: 'Progress',
        reward: 20,
      ),
      Achievement(
        id: 'streak_keeper',
        title: 'Streak Keeper',
        description: 'Maintain a 14-day streak',
        icon: Icons.local_fire_department,
        color: Colors.red,
        progress: 0.5,
        requirement: 14,
        category: 'Progress',
        reward: 50,
      ),
      Achievement(
        id: 'journal_writer',
        title: 'Journal Writer',
        description: 'Write 10 journal entries',
        icon: Icons.book,
        color: Colors.indigo,
        progress: 0.3,
        requirement: 10,
        category: 'Progress',
        reward: 30,
      ),
      Achievement(
        id: 'coin_collector',
        title: 'Coin Collector',
        description: 'Earn 500 fish coins',
        icon: Icons.catching_pokemon,
        color: Colors.amber,
        progress: 0.25,
        requirement: 500,
        category: 'Progress',
        reward: 100,
      ),
    ];
  }
}