import '../screens/stats_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../utilities/custom_elevated_button.dart';
import '../utilities/custom_alert_dialog.dart';
import '../utilities/custom_rich_text.dart';
import '../constants/app_strings.dart';
import '../constants/colors.dart';
import '../utilities/create_uid.dart';
import '../utilities/notification_util.dart';
import '../models/notification_model.dart' as app_notification;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedNotificationDay = '';
  int selectedDayOfTheWeek = 0;
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isTimeSelected = false;
  late NotificationUtil notificationUtil;
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customDescriptionController =
      TextEditingController();
  Timer? _notificationCheckTimer;
  Set<int> _shownNotificationIds = {};

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM d, y HH:mm');
    return formatter.format(dateTime);
  }

  // list of notification days
  final List<String> notificationDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thur',
    'Fri',
    'Sat',
    'Sun',
  ];

  // Function to show dialog for custom notification input
  void showBasicNotificationDialog() {
    _customNameController.clear();
    _customDescriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Basic Notification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customNameController,
                decoration: const InputDecoration(
                  labelText: 'Custom Name (optional)',
                  hintText: 'e.g., Daily Reminder',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Custom Description (optional)',
                  hintText: 'e.g., Check your tasks',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              createScheduleNotification();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Function to create a basic notification
  void createBasicNotification() {
    final customName = _customNameController.text.trim().isEmpty
        ? null
        : _customNameController.text.trim();
    final customDescription = _customDescriptionController.text.trim().isEmpty
        ? null
        : _customDescriptionController.text.trim();

    notificationUtil.createBasicNotification(
      id: createUniqueId(), // Get a unique ID for this notification
      channelKey: AppStrings.BASIC_CHANNEL_KEY,
      title: '🎒✈️ Network Call',
      body:
          'Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia,molestiae quas vel sint commodi repudiandae consequuntur',
      bigPicture: 'asset://assets/imgs/rocket.png', // Display a large image
      customName: customName,
      customDescription: customDescription,
    );
  }

  // Function to trigger cancellation of all scheduled notifications
  void triggerCancelNotification() {
    notificationUtil.cancelAllScheduledNotifications(context: context);
  }

  // Function to initiate the scheduling process by showing custom input dialog first
  void triggerScheduleNotification() {
    _customNameController.clear();
    _customDescriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Scheduled Notification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customNameController,
                decoration: const InputDecoration(
                  labelText: 'Custom Name (optional)',
                  hintText: 'e.g., Exercise Habit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Custom Description (optional)',
                  hintText: 'e.g., Daily exercise reminder',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDaySelectionDialog();
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  // Function to show day selection dialog
  void showDaySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Show Notification Every'),
        content: Wrap(
          spacing: 3.0,
          runSpacing: 8.0,
          children: notificationDays
              .asMap()
              .entries
              .map(
                (day) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.secondaryColor),
                  onPressed: () {
                    int index = day.key;
                    setState(() {
                      selectedNotificationDay = day.value;
                      selectedDayOfTheWeek = index +
                          1; // Weekday is 1-indexed (Sunday is 1, Monday is 2, etc.)
                    });
                    Navigator.of(context).pop(); // Close day selection dialog
                    pickTime(); // Then, prompt for time selection
                  },
                  child: Text(
                    day.value,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // Function to create the actual scheduled notification after day and time are selected
  void createScheduleNotification() {
    final customName = _customNameController.text.trim().isEmpty
        ? null
        : _customNameController.text.trim();
    final customDescription = _customDescriptionController.text.trim().isEmpty
        ? null
        : _customDescriptionController.text.trim();

    notificationUtil.createScheduledNotification(
      id: createUniqueId(),
      channelKey: AppStrings.SCHEDULE_CHANNEL_KEY,
      title: '${Emojis.time_alarm_clock} Check your habit!',
      body: 'The Lords are enterining.',
      layout: NotificationLayout.Default,
      notificationCalendar: NotificationCalendar(
        hour: selectedTime.hour,
        minute: selectedTime.minute,
        weekday: selectedDayOfTheWeek, // Use the selected day of the week
      ),
      customName: customName,
      customDescription: customDescription,
    );
  }

  // Function to show a time picker dialog
  Future<TimeOfDay?> pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        isTimeSelected = true;
      });
      createScheduleNotification(); // Once time is picked, create the notification
    }
    return null;
  }

  // Function to request notification permissions
  void requestPermission() {
    notificationUtil.requestPermissionToSendNotifications(context: context);
  }

  // Function to check if any scheduled notifications should trigger now
  Future<void> _checkScheduledNotifications() async {
    if (!mounted) return;

    final notifications = await notificationUtil.getNotifications();
    final now = DateTime.now();

    for (var notification in notifications) {
      if (notification.isScheduled &&
          notification.scheduledDateTime != null &&
          !_shownNotificationIds.contains(notification.id)) {
        final scheduledTime = notification.scheduledDateTime!;

        // Check if current time matches scheduled time (within 1 minute tolerance)
        final timeDifference = now.difference(scheduledTime).abs();

        if (timeDifference.inMinutes < 1 &&
            now.hour == scheduledTime.hour &&
            now.minute == scheduledTime.minute) {
          _shownNotificationIds.add(notification.id);

          if (mounted) {
            customAlertDialog(
              title: 'Notification Time!',
              content: '${notification.title}\n\n${notification.body}',
              context: context,
              action: () {
                Navigator.of(context).pop();
                // Optional: Navigate to specific screen
              },
              button1Title: 'Got it!',
              button2Title: 'Dismiss',
            );
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize awesome notifications with channels
    AwesomeNotifications().initialize(
      null, // no icon for now, can be added later
      [
        NotificationChannel(
          channelKey: AppStrings.BASIC_CHANNEL_KEY,
          channelName: 'Basic Notifications',
          channelDescription: 'Channel for basic notifications',
          defaultColor: AppColor.primaryColor,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: AppStrings.SCHEDULE_CHANNEL_KEY,
          channelName: 'Scheduled Notifications',
          channelDescription: 'Channel for scheduled notifications',
          defaultColor: AppColor.primaryColor,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
    );

    // Check notification permission and prompt if not allowed
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        customAlertDialog(
          title: 'Allow notifications',
          content:
              'Rocket App needs access to notifications to send you timely updates and reminders.',
          context: context,
          action: requestPermission,
          button1Title: 'Allow',
          button2Title: 'Don\'t Allow',
        );
      }
    });

    // Start timer to check for scheduled notifications every minute
    _notificationCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkScheduledNotifications();
    });

    // Initialize NotificationUtil with an instance of AwesomeNotifications
    notificationUtil = NotificationUtil(
      awesomeNotifications: AwesomeNotifications(),
    );

    // Set up callback to show popup when notification deadline is hit
    NotificationUtil.onNotificationDisplayedCallback = (title, body) {
      print('🔔 Notification callback triggered: $title');
      if (mounted) {
        print('✅ Widget is mounted, showing dialog');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => AlertDialog(
            backgroundColor: AppColor.primaryColor,
            title: Row(
              children: [
                const Icon(Icons.alarm, color: Colors.white, size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            content: Text(
              body,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColor.secondaryColor,
                ),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // You can add navigation to the task/habit here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(color: AppColor.primaryColor),
                ),
              ),
            ],
          ),
        );
      }
    };

    // Set up listeners for various notification events
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod: (notification) async =>
          NotificationUtil.onNotificationCreatedMethod(notification, context),
      onActionReceivedMethod: NotificationUtil.onActionReceivedMethod,
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) =>
          NotificationUtil.onDismissActionReceivedMethod(receivedAction),
      onNotificationDisplayedMethod: (ReceivedNotification
              receivedNotification) =>
          NotificationUtil.onNotificationDisplayedMethod(receivedNotification),
    );
  }

  @override
  void dispose() {
    // Cancel the timer
    _notificationCheckTimer?.cancel();
    // Clear callbacks
    NotificationUtil.onNotificationDisplayedCallback = null;
    // Dispose of text controllers
    _customNameController.dispose();
    _customDescriptionController.dispose();
    // Dispose of AwesomeNotifications resources when the widget is removed
    AwesomeNotifications().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Wrap(
          spacing: 8,
          children: [
            Icon(
              CupertinoIcons.rocket,
              color: Colors.white,
            ),
            Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const StatsPage(),
              ),
            ),
            icon: const Icon(
              CupertinoIcons.chart_bar_square,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Top section with image and buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (isTimeSelected) ...[
                  CustomRichText(
                    title: 'Current Day: ',
                    content: selectedNotificationDay,
                  ),
                  const SizedBox(height: 10),
                  CustomRichText(
                    title: 'Current Time: ',
                    content: selectedTime.format(context),
                  ),
                  const SizedBox(height: 10),
                ],
                Image.asset("images/icons/pockp_awards_icon.png",
                    width: 128, height: 128),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        function:
                            triggerScheduleNotification, //showBasicNotificationDialog,
                        title: 'Basic Notification',
                        icon: Icons.notifications,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomElevatedButton(
                        function: triggerScheduleNotification,
                        title: 'Schedule',
                        icon: Icons.schedule,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: FutureBuilder<List<app_notification.NotificationModel>>(
              future: notificationUtil.getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final notification = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          notification.isScheduled
                              ? Icons.schedule
                              : Icons.notifications,
                          color: AppColor.primaryColor,
                        ),
                        title: Text(notification.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.body),
                            if (notification.scheduledDateTime != null)
                              Text(
                                'Scheduled for: ${_formatDateTime(notification.scheduledDateTime!)}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            notificationUtil
                                .removeNotification(notification.id);
                            setState(() {}); // Refresh the list
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Cancel all button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomElevatedButton(
              function: () {
                triggerCancelNotification();
                setState(() {}); // Refresh the list
              },
              title: 'Cancel All Notifications',
              icon: Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }
}
