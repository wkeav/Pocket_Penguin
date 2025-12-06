import 'package:flutter/material.dart';
import '../services/calendar_service.dart';

// Model class for calendar event.
//Tiny box that holds one event's info.
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

// Main calendar screen.
//Page that shows calendar and events.
//Tt remembers which day you touched and what month you are looking at.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  //The day the user picked (starts as today). like pointing at a day.
  DateTime _selectedDate = DateTime.now();
  //The month we are looking at. we can flip months like pages in a book.
  DateTime _focusedDate = DateTime.now();
  //Map from a day(midnight) to a list of events on that day.
  //It's like each day it keeps its events. 
  final Map<DateTime, List<CalendarEvent>> _events = {};
  //Are we busy fetching data? if yes, show a loading idea later.
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //When this page wakes up, ask the backend for events. 
    _loadEvents();
  }

  //Load events from backend.
  //We go get the events from the server and put them in our events map.
  Future<void> _loadEvents() async {
    setState(() => isLoading = true);
    try {
      final data = await CalendarService.getEvents();
      final Map<DateTime, List<CalendarEvent>> tempEvents = {};

      for (var event in data) {
        //Turn the string times into real DateTime objects.
        final start = DateTime.parse(event['start_time']);
        final end = DateTime.parse(event['end_time']);
        final eventObj = CalendarEvent(
          id: event['id'],
          title: event['title'],
          description: event['description'],
          startDate: start,
          endDate: end,
        );
        //Make a day-only key so all events on the same day go together.
        final dayKey = DateTime(start.year, start.month, start.day);
        if (!tempEvents.containsKey(dayKey)) tempEvents[dayKey] = [];
        tempEvents[dayKey]!.add(eventObj);
      }
        //Replace our events with the new ones from the server.
      setState(() {
        _events.clear();
        _events.addAll(tempEvents);
      });
    } catch (e) {
      //If something breaks, show a little message.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load events: $e')));
    }
    setState(() => isLoading = false); //Loading is done.
  }
//Get events for a particular day.
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Add event dialog
  //This opens a small boc where we can type title and pick times.
  void _addEvent() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? startDate = _selectedDate; //Start day defaults to selected day
    TimeOfDay? startTime;
    DateTime? endDate = _selectedDate; //End day defaults too 
    TimeOfDay? endTime;

    showDialog(
      context: context,
      //StatefulBuilder lets the dialog change its own little bits 
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Title input
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                // Description input
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Start time picker
                const Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () async {
                    //Pick date for start
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
                    //Pick time for start
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
                // End time pickers
                const Text('End Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () async {
                    //Pick a date for end
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
            //Cancel button closes the dialog with no changes.
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            //Add button saves the event if everything is filled
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    startDate == null ||
                    startTime == null ||
                    endDate == null ||
                    endTime == null) {
                      //Tell the user to fill all fields.
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill everything')));
                  return;
                }

                 //Make full DateTime objects from chosen dates and times.
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
                  //Send to backedn to save the new event.
                  await CalendarService.addEvent(
                    title: titleController.text,
                    description: descriptionController.text,
                    startTime: startDateTime,
                    endTime: endDateTime,
                  );
                  //Refresh the events on the screen after adding.
                  await _loadEvents(); // Refresh after adding

                  //Close the dialog.
                  Navigator.pop(context);
                } catch (e) {
                  //Show an error if saving failed.
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
  //When the user taps delete, ask the backend to remove the event,
  //Then refresh our events list so it matches the server.
  Future<void> _deleteEvent(CalendarEvent event) async {
    try {
      await CalendarService.deleteEvent(event.id);
      await _loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')));
    }
  }

//Build a single event row shown under the calendar.
  Widget _buildEventItem(CalendarEvent event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        //Little blue card background so it looks nice.
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
                  event.title, //Big title of the event 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              //Trash button to delete the event
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEvent(event),
              ),
            ],
          ),
          const SizedBox(height: 4),
          //Show start and end time in HH:MM format.
          Text(
            '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')} - '
            '${event.endDate.hour.toString().padLeft(2, '0')}:${event.endDate.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          //Smaller gray description text.
          Text(event.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
//Tiny helper-are two datetimes the same day?
//We compare year, month, and day only. time of day doesn't matter.
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
//Format selected date like "Jan 5" for the header under events.
  String _formatSelectedDate() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
  }

//Format the month and year like "Januart 2025" for the top of the calendar.
  String _getMonthYear(DateTime date) {
    const months = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

//Build the calendar grid for the focused month.
//We make 6 rows x 7 colums and leave empty boxes for out-of-month days.
  Widget _buildCalendarGrid() {
    //Figure out how many days are in the focused month.
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    //First day of the month to know which weekday it starts on.
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    //Convert weekday 1..7 to 0..6 so Sunday is 0.
    
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        //Weekday labels row.
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
        //Make up too 6 weeks to cover the month.
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = (weekIndex * 7 + dayIndex) - firstWeekday + 1;
              //If the number is not inside this month, show an empty box.
              if (dayNumber < 1 || dayNumber > daysInMonth)
                return const Expanded(child: SizedBox(height: 40));
              final date = DateTime(_focusedDate.year, _focusedDate.month, dayNumber);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final hasEvents = _getEventsForDay(date).isNotEmpty;

              return Expanded(
                child: GestureDetector(
                  //Tap a day to select it.
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      //Special color for selected day and light color for today.
                      color: isSelected ? Colors.blue[600] : isToday ? Colors.blue[100] : null,
                      borderRadius: BorderRadius.circular(8),
                      //Orange border if there are events on this day.
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
    //Get the events for the day that the user picked. 
    final eventsForSelectedDay = _getEventsForDay(_selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          //Top row with chevrons to go to previous or next month.
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
          //Callendar itself
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          // Events list for the selected day. 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  //Header like "events for Jan 5"
                  Text('Events for ${_formatSelectedDate()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              //If no events, show a friendly empty state. 
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
              //Otherwise show each event in a little card. 
                ...eventsForSelectedDay
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildEventItem(e),
                        )),
            ],
          ),
          const SizedBox(height: 16),
          //Button to add a new event (opens the dialog above).
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

