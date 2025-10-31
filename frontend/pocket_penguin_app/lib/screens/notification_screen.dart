import '../screens/stats_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Function to create a basic notification
  void createBasicNotification() {
    notificationUtil.createBasicNotification(
      id: createUniqueId(), // Get a unique ID for this notification
      channelKey: AppStrings.BASIC_CHANNEL_KEY,
      title: '🎒✈️ Network Call',
      body:
          'Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia,molestiae quas vel sint commodi repudiandae consequuntur',
      bigPicture: 'asset://assets/imgs/rocket.png', // Display a large image
    );
  }

  // Function to trigger cancellation of all scheduled notifications
  void triggerCancelNotification() {
    notificationUtil.cancelAllScheduledNotifications(context: context);
  }

  // Function to initiate the scheduling process by showing a day selection dialog
  void triggerScheduleNotification() {
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
                      selectedDayOfTheWeek = index + 1; // Weekday is 1-indexed (Sunday is 1, Monday is 2, etc.)
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
    notificationUtil.createScheduledNotification(
      id: createUniqueId(),
      channelKey: AppStrings.SCHEDULE_CHANNEL_KEY,
      title: '${Emojis.time_alarm_clock} Check your habit!',
      body:
          'The Lords are enterining.',
      layout: NotificationLayout.Default,
      notificationCalendar: NotificationCalendar(
        hour: selectedTime.hour,
        minute: selectedTime.minute,
        weekday: selectedDayOfTheWeek, // Use the selected day of the week
      ),
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
          content: 'Rocket App needs access to notifications to send you timely updates and reminders.',
          context: context,
          action: requestPermission,
          button1Title: 'Allow',
          button2Title: 'Don\'t Allow',
        );
      }
    });

    // Initialize NotificationUtil with an instance of AwesomeNotifications
    notificationUtil = NotificationUtil(
      awesomeNotifications: AwesomeNotifications(),
    );

    // Set up listeners for various notification events
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod: (notification) async =>
          NotificationUtil.onNotificationCreatedMethod(notification, context),
      onActionReceivedMethod: NotificationUtil.onActionReceivedMethod,
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) =>
          NotificationUtil.onDismissActionReceivedMethod(receivedAction),
      onNotificationDisplayedMethod: (ReceivedNotification receivedNotification) =>
          NotificationUtil.onNotificationDisplayedMethod(receivedNotification),
    );
  }

  @override
  void dispose() {
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
              'Rockets',
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
                    title: 'Selected Day: ',
                    content: selectedNotificationDay,
                  ),
                  const SizedBox(height: 10),
                  CustomRichText(
                    title: 'Selected Time: ',
                    content: selectedTime.format(context),
                  ),
                  const SizedBox(height: 10),
                ],
                Image.asset("images/icons/pockp_awards_icon.png", width: 128, height: 128),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        function: createBasicNotification,
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
                            notificationUtil.removeNotification(notification.id);
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