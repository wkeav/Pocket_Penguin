import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Main screen for the calendar
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Currently selected date in the calendar
  DateTime _selectedDate = DateTime.now();
  // Month being displayed in the calendar
  DateTime _focusedDate = DateTime.now();

  // Sample events data (mock data)
  final Map<DateTime, List<CalendarEvent>> _events = {
    DateTime(2024, DateTime.now().month, DateTime.now().day): [
      CalendarEvent('Complete daily habits', '9:00 AM'),
      CalendarEvent('Grocery shopping', '2:00 PM'),
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 1): [
      CalendarEvent('Dentist appointment', '10:00 AM'),
      CalendarEvent('Meditation session', '7:00 PM'),
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 2): [
      CalendarEvent('Weekend trip planning', 'All day'),
    ],
  };

  // Get events for a specific day
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventsForSelectedDay = _getEventsForDay(_selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with title, subtitle, and stats
          ArcticCard(
            gradientColors: const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
            child: Column(
              children: [
                const Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your schedule and progress',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0369A1),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                        '${_getTotalEvents()}', 'Events', Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatCard(
                        '${_getCompletedToday()}', 'Completed', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Calendar widget with month navigation
          ArcticCard(
            child: Column(
              children: [
                // Month navigation row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedDate = DateTime(
                              _focusedDate.year, _focusedDate.month - 1);
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      _getMonthYear(_focusedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedDate = DateTime(
                              _focusedDate.year, _focusedDate.month + 1);
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calendar grid showing days
                _buildCalendarGrid(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Selected day events section
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Events for ${_formatSelectedDate()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Show message if no events
                if (eventsForSelectedDay.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No events for this day',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                // Show list of events
                else
                  ...eventsForSelectedDay.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildEventItem(event),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions row (only Add Event now)
          ArcticCard(
            child: Row(
              children: [
                _buildActionButton(
                  'Add Event',
                  Icons.add_circle,
                  Colors.blue,
                  onTap: _addEvent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Small card for displaying stats
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

  // Build calendar grid
  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Column(
      children: [
        // Week days header
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Generate 6 weeks of rows
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = (weekIndex * 7 + dayIndex) - firstWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final date =
                  DateTime(_focusedDate.year, _focusedDate.month, dayNumber);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final hasEvents = _getEventsForDay(date).isNotEmpty;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue[600]
                          : isToday
                              ? Colors.blue[100]
                              : null,
                      borderRadius: BorderRadius.circular(8),
                      border: hasEvents
                          ? Border.all(color: Colors.orange, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? Colors.blue[600]
                                  : Colors.black,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  // Build single event item
  Widget _buildEventItem(CalendarEvent event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  event.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Delete button for event
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _events[DateTime(_selectedDate.year,
                        _selectedDate.month, _selectedDate.day)]
                    ?.remove(event);
              });
            },
          ),
        ],
      ),
    );
  }

  // Action button widget (e.g., Add Event)
  Widget _buildActionButton(String label, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog to add a new event
  void _addEvent() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final time = timeController.text.trim();
              if (title.isNotEmpty && time.isNotEmpty) {
                setState(() {
                  final dayKey = DateTime(
                      _selectedDate.year, _selectedDate.month, _selectedDate.day);
                  if (_events[dayKey] == null) _events[dayKey] = [];
                  _events[dayKey]!.add(CalendarEvent(title, time));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Helper: check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Format month/year for header
  String _getMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Format selected date for events section
  String _formatSelectedDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
  }

  // Total number of events
  int _getTotalEvents() {
    return _events.values.fold(0, (total, events) => total + events.length);
  }

  // Completed events today (mocked)
  int _getCompletedToday() {
    return 3;
  }
}

// Model class for an event
class CalendarEvent {
  final String title;
  final String time;

  CalendarEvent(this.title, this.time);
}
