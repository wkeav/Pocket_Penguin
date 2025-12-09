import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PixelBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double thickness;
  final double cornerSize;

  const PixelBorder({
    super.key,
    required this.child,
    this.color = const Color(0xFFE5E7EB),
    this.thickness = 2.0,
    this.cornerSize = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: thickness),
        borderRadius: BorderRadius.circular(cornerSize),
      ),
      child: child,
    );
  }
}

class PixelProgressIndicator extends StatelessWidget {
  final double value;
  final Color color;

  const PixelProgressIndicator({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            color: color,
            child: PixelBorder(
              child: const SizedBox.expand(),
              thickness: 1.0,
              cornerSize: 0,
              color: color.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}

class PocketPenguinIcons {
  static const String iconsPath = 'images/icons/';

  static const String awards = '${iconsPath}pockp_awards_icon.png';
  static const String calendar = '${iconsPath}pockp_calendar_icon.png';
  static const String fishcoin = '${iconsPath}pockp_fishcoin.png';
  static const String friends = '${iconsPath}pockp_friends_icon.png';
  static const String habits = '${iconsPath}pockp_habits_icon.png';
  static const String journal = '${iconsPath}pockp_journal_icon.png';
  static const String progress = '${iconsPath}pockp_progress_icon.png';
  static const String todo = '${iconsPath}pockp_todo_icon.png';
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

enum TimePeriod { weekly, monthly }

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  TimePeriod _selectedPeriod = TimePeriod.weekly;

  late AnimationController _animationController;
  late Animation<double> _animation;

  final Map<TimePeriod, Map<String, List<dynamic>>> _chartData = {
    TimePeriod.weekly: {
      'habits': <double>[0.8, 0.6, 1.0, 0.4, 0.9, 0.3, 0.7],
      'todos': <double>[0.5, 1.0, 0.7, 0.8, 0.6, 0.4, 0.9],
      'labels': <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'habitSummary': <dynamic>['21/35', 0.6],
      'todoSummary': <dynamic>['8/12', 0.67],
    },
    TimePeriod.monthly: {
      'habits': <double>[0.9, 0.7, 0.8, 0.5],
      'todos': <double>[0.6, 0.9, 0.5, 0.8],
      'labels': <String>['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
      'habitSummary': <dynamic>['89/120', 0.74],
      'todoSummary': <dynamic>['23/35', 0.66],
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animateBars();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateBars() {
    _animationController.reset();
    _animationController.forward();
  }

  void _togglePeriod(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
      _animateBars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _chartData[_selectedPeriod]!;
    final chartLabels = data['labels'] as List<String>;
    final habitData = data['habits'] as List<double>;
    final todoData = data['todos'] as List<double>;
    final habitSummary = data['habitSummary'] as List<dynamic>;
    final todoSummary = data['todoSummary'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // Weekly/Monthly Progress Overview
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeaderWithToggle(),
                const SizedBox(height: 16),
                _buildAnimatedBarChart(chartLabels, habitData, todoData),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAnimatedStatProgressBar(
                        'Habits',
                        habitSummary[0] as String,
                        habitSummary[1] as double,
                        Colors.green),
                    const SizedBox(width: 16),
                    _buildAnimatedStatProgressBar(
                        'Todos',
                        todoSummary[0] as String,
                        todoSummary[1] as double,
                        Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Habit Completion Chart
          _buildAnimatedHabitCompletionChart(),
          const SizedBox(height: 16),

          // All-Time Summary
          _buildAllTimeSummary(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBarChart(
    List<String> labels,
    List<double> habitData,
    List<double> todoData,
  ) {
    const double maxHeight = 100;
    const double barWidth = 24;

    return SizedBox(
      height: 150,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animationValue = _animation.value;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(labels.length, (index) {
              final animatedHabitHeight =
                  (habitData[index] * maxHeight) * animationValue;

              final animatedTodoHeight =
                  (todoData[index] * maxHeight) * animationValue;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: maxHeight,
                    width: barWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Habits bar
                        Container(
                          width: barWidth / 2 - 2,
                          height: animatedHabitHeight,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const PixelBorder(
                            child: SizedBox.expand(),
                            thickness: 1,
                            cornerSize: 2,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Todos bar
                        Container(
                          width: barWidth / 2 - 2,
                          height: animatedTodoHeight,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const PixelBorder(
                            child: SizedBox.expand(),
                            thickness: 1,
                            cornerSize: 2,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[index],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedStatProgressBar(
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
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return PixelProgressIndicator(
                value: progress * _animation.value,
                color: color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHabitCompletionChart() {
    final habits = [
      HabitProgress('Water', 0.8, Colors.blue),
      HabitProgress('Exercise', 0.6, Colors.green),
      HabitProgress('Meditation', 0.9, Colors.purple),
      HabitProgress('Reading', 0.4, Colors.orange),
      HabitProgress('Steps', 0.7, Colors.red),
    ];

    return ArcticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                PocketPenguinIcons.habits,
                height: 20,
                width: 20,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 8),
              const Text(
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
          Column(
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
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return PixelProgressIndicator(
                                  value: habit.progress * _animation.value,
                                  color: habit.color,
                                );
                              },
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return ArcticCard(
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
              _buildStatCard(
                '127',
                'Fish Coins',
                Colors.amber,
                PocketPenguinIcons.fishcoin,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                '7',
                'Day Streak',
                Colors.orange,
                PocketPenguinIcons.calendar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, Color color, String iconPath) {
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
            Image.asset(
              iconPath,
              height: 32,
              width: 32,
              filterQuality: FilterQuality.none,
            ),
            const SizedBox(height: 8),
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

  Widget _buildProgressHeaderWithToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Image.asset(
                PocketPenguinIcons.progress,
                height: 20,
                width: 20,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _selectedPeriod == TimePeriod.weekly
                      ? 'Weekly Progress'
                      : 'Monthly Progress',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildToggleItem(TimePeriod.weekly, 'Weekly'),
              _buildToggleItem(TimePeriod.monthly, 'Monthly'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(TimePeriod period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => _togglePeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.blue[800] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildAllTimeSummary() {
    return ArcticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'All-Time Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  _buildSummaryItem(
                    'Total Habits',
                    '890',
                    PocketPenguinIcons.habits,
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryItem(
                    'Total Todos',
                    '230',
                    PocketPenguinIcons.todo,
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSummaryItem(
                    'Journal Entries',
                    '120',
                    PocketPenguinIcons.journal,
                    Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryItem(
                    'Fish Coins Earned',
                    '3400',
                    PocketPenguinIcons.fishcoin,
                    Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, String iconPath, Color color) {
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
            Image.asset(
              iconPath,
              height: 24,
              width: 24,
              filterQuality: FilterQuality.none,
            ),
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
}

class HabitProgress {
  final String name;
  final double progress;
  final Color color;

  HabitProgress(this.name, this.progress, this.color);
}