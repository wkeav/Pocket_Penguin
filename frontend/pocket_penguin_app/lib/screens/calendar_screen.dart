import 'package:flutter/material.dart';
import '../services/calendar_service.dart';
import '../models/calendar_event.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Currently selected date (highlighted in blue)
  DateTime _selectedDate = DateTime.now();
  // Currently displayed month/year in calendar
  DateTime _focusedDate = DateTime.now();
  // Map of dates to their events (day only, no time)
  final Map<DateTime, List<CalendarEvent>> _events = {};
  // Loading state while fetching events from backend
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Load all events from backend and organize them by date
  // Events are grouped by day (ignoring time) for calendar display
  Future<void> _loadEvents() async {
    setState(() => isLoading = true);
    try {
      final events = await CalendarService.getEvents();
      final Map<DateTime, List<CalendarEvent>> tempEvents = {};

      // Group events by date (midnight timestamp) for easy lookup
      for (var event in events) {
        final dayKey = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        if (!tempEvents.containsKey(dayKey)) {
          tempEvents[dayKey] = [];
        }
        tempEvents[dayKey]!.add(event);
      }

      setState(() {
        _events.clear();
        _events.addAll(tempEvents);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  // Get all events for a specific day
  // Returns empty list if no events exist for that day
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return _events[dayKey] ?? [];
  }

  // Show dialog to add a new calendar event
  // User must provide title, description, start/end date and time
  void _addEvent() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    // Default dates to currently selected date
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setDialogState(() => startDate = date);
                          }
                        },
                        child: Text(startDate == null
                            ? 'Start Date'
                            : '${startDate!.month}/${startDate!.day}/${startDate!.year}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() => startTime = time);
                          }
                        },
                        child: Text(startTime == null
                            ? 'Start Time'
                            : startTime!.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setDialogState(() => endDate = date);
                          }
                        },
                        child: Text(endDate == null
                            ? 'End Date'
                            : '${endDate!.month}/${endDate!.day}/${endDate!.year}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() => endTime = time);
                          }
                        },
                        child: Text(endTime == null
                            ? 'End Time'
                            : endTime!.format(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    startDate == null ||
                    startTime == null ||
                    endDate == null ||
                    endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                // Combine date and time into a single DateTime object
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
                  await _loadEvents();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add event: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // Delete a calendar event without confirmation
  // Reloads all events after successful deletion
  Future<void> _deleteEvent(CalendarEvent event) async {
    try {
      await CalendarService.deleteEvent(event.id);
      await _loadEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addEvent,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(),
                const Divider(),
                Expanded(
                  child: selectedEvents.isEmpty
                      ? const Center(child: Text('No events for this day'))
                      : ListView.builder(
                          itemCount: selectedEvents.length,
                          itemBuilder: (context, index) {
                            final event = selectedEvents[index];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                title: Text(event.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.description),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteEvent(event),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(
                      _focusedDate.year,
                      _focusedDate.month - 1,
                    );
                  });
                },
              ),
              Text(
                '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(
                      _focusedDate.year,
                      _focusedDate.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        _buildDaysGrid(),
      ],
    );
  }

  // Build the calendar grid showing all days of the month
  // Calculates offset for first day of week and total days in month
  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    // Calculate which day of week the month starts (0=Sunday, 6=Saturday)
    final startWeekday = firstDayOfMonth.weekday % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth + startWeekday,
      itemBuilder: (context, index) {
        if (index < startWeekday) {
          return const SizedBox();
        }

        final day = index - startWeekday + 1;
        final date = DateTime(_focusedDate.year, _focusedDate.month, day);
        final isSelected = _selectedDate.year == date.year &&
            _selectedDate.month == date.month &&
            _selectedDate.day == date.day;
        final hasEvents = _getEventsForDay(date).isNotEmpty;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border:
                  hasEvents ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: hasEvents ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  // Format DateTime to 12-hour time string (e.g., "2:30 PM")
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
