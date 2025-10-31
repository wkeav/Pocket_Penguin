import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // Sample events data
  final Map<DateTime, List<CalendarEvent>> _events = {
    DateTime(2024, DateTime.now().month, DateTime.now().day): [
      CalendarEvent('Complete daily habits', EventType.habit, '9:00 AM'),
      CalendarEvent('Grocery shopping', EventType.todo, '2:00 PM'),
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 1): [
      CalendarEvent('Dentist appointment', EventType.todo, '10:00 AM'),
      CalendarEvent('Meditation session', EventType.habit, '7:00 PM'),
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 2): [
      CalendarEvent('Weekend trip planning', EventType.todo, 'All day'),
    ],
  };

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
          // Header
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

          // Calendar Widget
          ArcticCard(
            child: Column(
              children: [
                // Month navigation
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

                // Calendar grid
                _buildCalendarGrid(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Selected Day Events
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
                else
                  ...eventsForSelectedDay.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildEventItem(event),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          ArcticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildActionButton(
                        'Add Event', Icons.add_circle, Colors.blue),
                    const SizedBox(width: 8),
                    _buildActionButton(
                        'View Week', Icons.view_week, Colors.green),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildActionButton(
                        'Sync Calendar', Icons.sync, Colors.purple),
                    const SizedBox(width: 8),
                    _buildActionButton(
                        'Set Reminder', Icons.notifications, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monthly Summary
          ArcticCard(
            gradientColors: const [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart, color: Color(0xFFF59E0B), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'This Month\'s Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildProgressItem(
                        'Habits Completed', '89', '95%', Colors.green),
                    const SizedBox(width: 16),
                    _buildProgressItem('Tasks Done', '23', '87%', Colors.blue),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildProgressItem(
                        'Journal Entries', '12', '40%', Colors.purple),
                    const SizedBox(width: 16),
                    _buildProgressItem(
                        'Fish Coins Earned', '340', '+15%', Colors.amber),
                  ],
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

        // Calendar days
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

  Widget _buildEventItem(CalendarEvent event) {
    final color = event.type == EventType.habit ? Colors.green : Colors.blue;
    final icon =
        event.type == EventType.habit ? Icons.check_circle : Icons.task;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
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
          PenguinBadge(
            text: event.type.name,
            backgroundColor: color.withOpacity(0.2),
            textColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {},
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

  Widget _buildProgressItem(
      String label, String value, String change, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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

  int _getTotalEvents() {
    return _events.values.fold(0, (total, events) => total + events.length);
  }

  int _getCompletedToday() {
    // Mock data - in real app, this would track completed events
    return 3;
  }
}

class CalendarEvent {
  final String title;
  final EventType type;
  final String time;

  CalendarEvent(this.title, this.type, this.time);
}

enum EventType { habit, todo }

extension EventTypeExtension on EventType {
  String get name {
    switch (this) {
      case EventType.habit:
        return 'Habit';
      case EventType.todo:
        return 'Todo';
    }
  }
}
// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';

// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({super.key});

//   @override
//   State<CalendarScreen> createState() => _CalendarScreenState();
// }

// class _CalendarScreenState extends State<CalendarScreen> {
//   DateTime _selectedDate = DateTime.now();
//   DateTime _focusedDate = DateTime.now();

//   // Sample events data
//   final Map<DateTime, List<CalendarEvent>> _events = {
//     DateTime(2024, DateTime.now().month, DateTime.now().day): [
//       CalendarEvent('Complete daily habits', EventType.habit, '9:00 AM'),
//       CalendarEvent('Grocery shopping', EventType.todo, '2:00 PM'),
//     ],
//     DateTime(2024, DateTime.now().month, DateTime.now().day + 1): [
//       CalendarEvent('Dentist appointment', EventType.todo, '10:00 AM'),
//       CalendarEvent('Meditation session', EventType.habit, '7:00 PM'),
//     ],
//     DateTime(2024, DateTime.now().month, DateTime.now().day + 2): [
//       CalendarEvent('Weekend trip planning', EventType.todo, 'All day'),
//     ],
//   };

//   DateTime _normalize(DateTime date) {
//     return DateTime(date.year, date.month, date.day);
//   }

//   List<CalendarEvent> _getEventsForDay(DateTime day) {
//     return _events[_normalize(day)] ?? [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final eventsForSelectedDay = _getEventsForDay(_selectedDate);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Calendar'),
//         backgroundColor: const Color(0xFF0284C7),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Header
//             ArcticCard(
//               gradientColors: const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
//               child: Column(
//                 children: [
//                   const Text(
//                     'Calendar',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF0284C7),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Track your schedule and progress',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF0369A1),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       _buildStatCard(
//                           '${_getTotalEvents()}', 'Events', Colors.blue),
//                       const SizedBox(width: 16),
//                       _buildStatCard(
//                           '${_getCompletedToday()}', 'Completed', Colors.green),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Calendar Widget
//             ArcticCard(
//               child: Column(
//                 children: [
//                   // Month navigation
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           setState(() {
//                             _focusedDate = DateTime(
//                                 _focusedDate.year,
//                                 _focusedDate.month - 1,
//                                 1); // fix invalid month
//                           });
//                         },
//                         icon: const Icon(Icons.chevron_left),
//                       ),
//                       Text(
//                         _getMonthYear(_focusedDate),
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           setState(() {
//                             _focusedDate = DateTime(
//                                 _focusedDate.year,
//                                 _focusedDate.month + 1,
//                                 1); // fix invalid month
//                           });
//                         },
//                         icon: const Icon(Icons.chevron_right),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // Calendar grid
//                   _buildCalendarGrid(),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Selected Day Events
//             ArcticCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.event, color: Colors.blue, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Events for ${_formatSelectedDate()}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF374151),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   if (eventsForSelectedDay.isEmpty)
//                     const Center(
//                       child: Column(
//                         children: [
//                           Icon(Icons.calendar_today,
//                               size: 40, color: Colors.grey),
//                           SizedBox(height: 8),
//                           Text(
//                             'No events for this day',
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   else
//                     ...eventsForSelectedDay.map((event) => Padding(
//                           padding: const EdgeInsets.only(bottom: 8),
//                           child: _buildEventItem(event),
//                         )),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Quick Actions
//             ArcticCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Quick Actions',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF374151),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       _buildActionButton(
//                           'Add Event', Icons.add_circle, Colors.blue),
//                       const SizedBox(width: 8),
//                       _buildActionButton(
//                           'View Week', Icons.view_week, Colors.green),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       _buildActionButton(
//                           'Sync Calendar', Icons.sync, Colors.purple),
//                       const SizedBox(width: 8),
//                       _buildActionButton(
//                           'Set Reminder', Icons.notifications, Colors.orange),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Monthly Summary
//             ArcticCard(
//               gradientColors: const [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Row(
//                     children: [
//                       Icon(Icons.bar_chart, color: Color(0xFFF59E0B), size: 20),
//                       SizedBox(width: 8),
//                       Text(
//                         'This Month\'s Progress',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF92400E),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       _buildProgressItem(
//                           'Habits Completed', '89', '95%', Colors.green),
//                       const SizedBox(width: 16),
//                       _buildProgressItem('Tasks Done', '23', '87%', Colors.blue),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       _buildProgressItem(
//                           'Journal Entries', '12', '40%', Colors.purple),
//                       const SizedBox(width: 16),
//                       _buildProgressItem(
//                           'Fish Coins Earned', '340', '+15%', Colors.amber),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddEventDialog();
//         },
//         child: const Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   void _showAddEventDialog() {
//     final titleController = TextEditingController();
//     final timeController = TextEditingController();
//     EventType selectedType = EventType.todo;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           title: const Text('Add Event'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: titleController,
//                 decoration: const InputDecoration(labelText: 'Event Title'),
//               ),
//               TextField(
//                 controller: timeController,
//                 decoration: const InputDecoration(labelText: 'Time'),
//               ),
//               DropdownButton<EventType>(
//                 value: selectedType,
//                 onChanged: (newType) {
//                   if (newType != null) {
//                     setState(() {
//                       selectedType = newType;
//                     });
//                   }
//                 },
//                 items: EventType.values
//                     .map((type) => DropdownMenuItem(
//                           value: type,
//                           child: Text(type.name),
//                         ))
//                     .toList(),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final newEvent = CalendarEvent(
//                   titleController.text,
//                   selectedType,
//                   timeController.text,
//                 );
//                 setState(() {
//                   final dayKey = _normalize(_selectedDate);
//                   if (_events.containsKey(dayKey)) {
//                     _events[dayKey]!.add(newEvent);
//                   } else {
//                     _events[dayKey] = [newEvent];
//                   }
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // All helper widgets remain unchanged
//   Widget _buildStatCard(String value, String label, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendarGrid() {
//     final daysInMonth =
//         DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
//     final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
//     final firstWeekday = firstDayOfMonth.weekday % 7;

//     return Column(
//       children: [
//         Row(
//           children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
//               .map((day) => Expanded(
//                     child: Center(
//                       child: Text(
//                         day,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ))
//               .toList(),
//         ),
//         const SizedBox(height: 8),
//         ...List.generate(6, (weekIndex) {
//           return Row(
//             children: List.generate(7, (dayIndex) {
//               final dayNumber = (weekIndex * 7 + dayIndex) - firstWeekday + 1;

//               if (dayNumber < 1 || dayNumber > daysInMonth) {
//                 return const Expanded(child: SizedBox(height: 40));
//               }

//               final date =
//                   DateTime(_focusedDate.year, _focusedDate.month, dayNumber);
//               final isSelected = _isSameDay(date, _selectedDate);
//               final isToday = _isSameDay(date, DateTime.now());
//               final hasEvents = _getEventsForDay(date).isNotEmpty;

//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _selectedDate = date;
//                     });
//                   },
//                   child: Container(
//                     height: 40,
//                     margin: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? Colors.blue[600]
//                           : isToday
//                               ? Colors.blue[100]
//                               : null,
//                       borderRadius: BorderRadius.circular(8),
//                       border: hasEvents
//                           ? Border.all(color: Colors.orange, width: 2)
//                           : null,
//                     ),
//                     child: Center(
//                       child: Text(
//                         dayNumber.toString(),
//                         style: TextStyle(
//                           color: isSelected
//                               ? Colors.white
//                               : isToday
//                                   ? Colors.blue[600]
//                                   : Colors.black,
//                           fontWeight: isSelected || isToday
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildEventItem(CalendarEvent event) {
//     final color = event.type == EventType.habit ? Colors.green : Colors.blue;
//     final icon =
//         event.type == EventType.habit ? Icons.check_circle : Icons.task;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   event.title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   event.time,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           PenguinBadge(
//             text: event.type.name,
//             backgroundColor: color.withOpacity(0.2),
//             textColor: color,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(String label, IconData icon, Color color) {
//     return Expanded(
//       child: InkWell(
//         onTap: () {
//           if (label == 'Add Event') {
//             _showAddEventDialog();
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: color, size: 20),
//               const SizedBox(height: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: color,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProgressItem(
//       String label, String value, String change, Color color) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 change,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: color,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   bool _isSameDay(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   String _getMonthYear(DateTime date) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December'
//     ];
//     return '${months[date.month - 1]} ${date.year}';
//   }

//   String _formatSelectedDate() {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
//   }

//   int _getTotalEvents() {
//     return _events.values.fold(0, (total, events) => total + events.length);
//   }

//   int _getCompletedToday() {
//     return 3;
//   }
// }

// class CalendarEvent {
//   final String title;
//   final EventType type;
//   final String time;

//   CalendarEvent(this.title, this.type, this.time);
// }

// enum EventType { habit, todo }

// extension EventTypeExtension on EventType {
//   String get name {
//     switch (this) {
//       case EventType.habit:
//         return 'Habit';
//       case EventType.todo:
//         return 'Todo';
//     }
//   }
// }
