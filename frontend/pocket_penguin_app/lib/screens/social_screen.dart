import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../theme/app_theme.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = SampleSocialData.friends;
    final brandon = SampleSocialData.brandon;
    final allLeaderboardEntries = [...friends, brandon];
    final leaderboard = allLeaderboardEntries..sort((a, b) => b.fishCoins.compareTo(a.fishCoins));
    final recentActivities = SampleSocialData.recentActivities;
    final challenges = SampleSocialData.challenges;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          ArcticCard(
            gradientColors: const [Color(0xFFECFEFF), Color(0xFFE0F2FE)],
            child: Column(
              children: [
                const Text(
                  'Friends & Community',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0891B2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect with fellow penguin keepers',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0E7490),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('${friends.length}', 'Friends', Colors.cyan),
                    const SizedBox(width: 16),
                    _buildStatCard('7th', 'Leaderboard', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Leaderboard
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Weekly Leaderboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...leaderboard.take(7).map((friend) {
                  final index = leaderboard.indexOf(friend);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildLeaderboardItem(friend, index),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Friends List
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.people, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Your Friends',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Friend'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...friends.map((friend) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFriendItem(friend),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent Activity Feed
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 16),
                ...recentActivities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityItem(activity),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Visit Homes Feature
          ArcticCard(
            gradientColors: const [Color(0xFFEFF6FF), Color(0xFFE0F2FE)],
            child: Column(
              children: [
                const Icon(Icons.home, size: 48, color: Colors.blue),
                const SizedBox(height: 12),
                const Text(
                  'Visit Friends\' Homes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore your friends\' decorated homes and get inspiration for your own!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3730A3),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Explore Homes'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Group Challenges
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.ac_unit, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Group Challenges',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...challenges.map((challenge) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildChallengeItem(challenge),
                )),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Join Challenge'),
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

  Widget _buildLeaderboardItem(Friend friend, int index) {
    Color? backgroundColor;
    Color? borderColor;
    Color rankColor = Colors.blue;

    if (friend.isUser) {
      backgroundColor = Colors.blue[50];
      borderColor = Colors.blue[300];
    } else if (index == 0) {
      backgroundColor = Colors.yellow[50];
      borderColor = Colors.yellow[200];
      rankColor = Colors.yellow[700]!;
    } else if (index == 1) {
      backgroundColor = Colors.grey[50];
      borderColor = Colors.grey[200];
      rankColor = Colors.grey[600]!;
    } else if (index == 2) {
      backgroundColor = Colors.orange[50];
      borderColor = Colors.orange[200];
      rankColor = Colors.orange[600]!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Text(
              friend.avatar,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${friend.name}${friend.isUser ? ' (You)' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: friend.isUser ? Colors.blue[700] : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PenguinBadge(
                      text: 'Lv. ${friend.level}',
                      backgroundColor: Colors.grey[100],
                    ),
                  ],
                ),
                Text(
                  friend.penguinName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.catching_pokemon, size: 12, color: Colors.blue),
                  const SizedBox(width: 2),
                  Text(
                    '${friend.fishCoins}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.ac_unit, size: 12, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(
                    '${friend.streak}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(Friend friend) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Text(
              friend.avatar,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      friend.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(friend.moodIcon, size: 16, color: Colors.blue),
                  ],
                ),
                Text(
                  '${friend.penguinName} • Level ${friend.level}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  friend.recentActivity,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.message, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(activity.type.icon, size: 16, color: Colors.blue[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                      text: activity.user,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(text: ' ${activity.action}'),
                  ],
                ),
              ),
              Text(
                activity.time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, size: 12),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildChallengeItem(Challenge challenge) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                challenge.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              PenguinBadge(
                text: '${challenge.daysLeft} days left',
                backgroundColor: Colors.grey[100],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.participants} participants',
                style: const TextStyle(fontSize: 12),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 12, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    challenge.reward,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}