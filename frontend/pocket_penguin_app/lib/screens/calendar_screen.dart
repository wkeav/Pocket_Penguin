import 'package:flutter/material.dart';
import '../services/calendar_service.dart';

// Model class for calendar event
class CalendarEvent {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}

// Main calendar screen
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final Map<DateTime, List<CalendarEvent>> _events = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Load events from backend
  Future<void> _loadEvents() async {
    setState(() => isLoading = true);
    try {
      final data = await CalendarService.getEvents();
      final Map<DateTime, List<CalendarEvent>> tempEvents = {};

      for (var event in data) {
        final start = DateTime.parse(event['start_time']);
        final end = DateTime.parse(event['end_time']);
        final eventObj = CalendarEvent(
          id: event['id'],
          title: event['title'],
          description: event['description'],
          startDate: start,
          endDate: end,
        );

        final dayKey = DateTime(start.year, start.month, start.day);
        if (!tempEvents.containsKey(dayKey)) tempEvents[dayKey] = [];
        tempEvents[dayKey]!.add(eventObj);
      }

      setState(() {
        _events.clear();
        _events.addAll(tempEvents);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load events: $e')));
    }
    setState(() => isLoading = false);
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Add event dialog
  void _addEvent() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? startDate = _selectedDate;
    TimeOfDay? startTime;
    DateTime? endDate = _selectedDate;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: startDate!,
                    );
                    if (date != null) setDialogState(() => startDate = date);
                  },
                  child: Text(startDate == null
                      ? 'Pick Start Date'
                      : '${startDate!.month}/${startDate!.day}/${startDate!.year}'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) setDialogState(() => startTime = time);
                  },
                  child: Text(startTime == null
                      ? 'Pick Start Time'
                      : startTime!.format(context)),
                ),
                const SizedBox(height: 16),
                const Text('End Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: endDate!,
                    );
                    if (date != null) setDialogState(() => endDate = date);
                  },
                  child: Text(endDate == null
                      ? 'Pick End Date'
                      : '${endDate!.month}/${endDate!.day}/${endDate!.year}'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) setDialogState(() => endTime = time);
                  },
                  child: Text(endTime == null
                      ? 'Pick End Time'
                      : endTime!.format(context)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    startDate == null ||
                    startTime == null ||
                    endDate == null ||
                    endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill everything')));
                  return;
                }

                final startDateTime = DateTime(
                  startDate!.year,
                  startDate!.month,
                  startDate!.day,
                  startTime!.hour,
                  startTime!.minute,
                );

                final endDateTime = DateTime(
                  endDate!.year,
                  endDate!.month,
                  endDate!.day,
                  endTime!.hour,
                  endTime!.minute,
                );

                try {
                  await CalendarService.addEvent(
                    title: titleController.text,
                    description: descriptionController.text,
                    startTime: startDateTime,
                    endTime: endDateTime,
                  );

                  await _loadEvents(); // Refresh after adding

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add event: $e')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // Delete event
  Future<void> _deleteEvent(CalendarEvent event) async {
    try {
      await CalendarService.deleteEvent(event.id);
      await _loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')));
    }
  }

  Widget _buildEventItem(CalendarEvent event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEvent(event),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')} - '
            '${event.endDate.hour.toString().padLeft(2, '0')}:${event.endDate.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(event.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatSelectedDate() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
  }

  String _getMonthYear(DateTime date) {
    const months = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        Row(
          children: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
              .map((day) => Expanded(
                    child: Center(
                        child: Text(day,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                fontSize: 12))),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = (weekIndex * 7 + dayIndex) - firstWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth)
                return const Expanded(child: SizedBox(height: 40));
              final date = DateTime(_focusedDate.year, _focusedDate.month, dayNumber);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final hasEvents = _getEventsForDay(date).isNotEmpty;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[600] : isToday ? Colors.blue[100] : null,
                      borderRadius: BorderRadius.circular(8),
                      border: hasEvents ? Border.all(color: Colors.orange, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(dayNumber.toString(),
                          style: TextStyle(
                              color: isSelected ? Colors.white : isToday ? Colors.blue[600] : Colors.black,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal)),
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

  @override
  Widget build(BuildContext context) {
    final eventsForSelectedDay = _getEventsForDay(_selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => setState(() => _focusedDate =
                      DateTime(_focusedDate.year, _focusedDate.month - 1)),
                  icon: const Icon(Icons.chevron_left)),
              Text(_getMonthYear(_focusedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(
                  onPressed: () => setState(() => _focusedDate =
                      DateTime(_focusedDate.year, _focusedDate.month + 1)),
                  icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text('Events for ${_formatSelectedDate()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              if (eventsForSelectedDay.isEmpty)
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No events for this day', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                )
              else
                ...eventsForSelectedDay
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildEventItem(e),
                        )),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addEvent,
            icon: const Icon(Icons.add),
            label: const Text('Add Event'),
          ),
        ],
      ),
    );
  }
}
