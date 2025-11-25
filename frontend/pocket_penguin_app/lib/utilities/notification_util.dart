import 'dart:io';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';
import '../constants/colors.dart';
import '../main.dart';
// import '../screens/stats_page.dart';  // Temporarily commented out for testing
import '../models/notification_model.dart' as app_notification;

class NotificationUtil {
  final AwesomeNotifications awesomeNotifications;
  static const String _notificationsKey = 'notifications_list';

  NotificationUtil({required this.awesomeNotifications});

  // Get all stored notifications
  Future<List<app_notification.NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);
    if (notificationsJson == null) return [];

    List<dynamic> notificationsList = jsonDecode(notificationsJson);
    return notificationsList
        .map((item) => app_notification.NotificationModel.fromMap(item))
        .toList();
  }

  // Store a notification
  Future<void> _storeNotification(app_notification.NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    List<app_notification.NotificationModel> notifications = await getNotifications();
    notifications.add(notification);
    
    await prefs.setString(
      _notificationsKey,
      jsonEncode(notifications.map((n) => n.toMap()).toList()),
    );
  }

  // Remove a notification
  Future<void> removeNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<app_notification.NotificationModel> notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == id);
    await prefs.setString(
      _notificationsKey,
      jsonEncode(notifications.map((n) => n.toMap()).toList()),
    );
  }

  /// Remove all notifications from storage and cancel them in the system.
  ///
  /// If [context] is provided a confirmation SnackBar will be shown.
  Future<void> removeAllNotification({BuildContext? context}) async {
    // Remove stored notification records
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);

    // Cancel scheduled notifications and all notifications that may be shown
    // Use the instance's AwesomeNotifications to ensure we affect this app's notifications
    try {
      await awesomeNotifications.cancelAllSchedules();
    } catch (_) {}
    try {
      await awesomeNotifications.cancelAll();
    } catch (_) {}

    // Optionally show feedback
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed all notifications'),
          backgroundColor: AppColor.primaryColor,
        ),
      );
    }
  }

  /// Creates a basic notification that appears immediately.
  Future<void> createBasicNotification({
    required int id,
    required String channelKey,
    required String title,
    required String body,
    String bigPicture = AppStrings.DEFAULT_ICON,
    NotificationLayout layout = NotificationLayout.BigPicture,
  }) async {
    // Create the notification
    await awesomeNotifications.createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        bigPicture: bigPicture,
        notificationLayout: layout,
      ),
    );

    // Store the notification in preferences
    await _storeNotification(
      app_notification.NotificationModel(
        id: id,
        title: title,
        body: body,
        channelKey: channelKey,
        isScheduled: false,
      ),
    );
  }

  /// Creates a scheduled notification that will appear at a specific time and can repeat.
  Future<void> createScheduledNotification({
    required int id,
    required String channelKey,
    required String title,
    required String body,
    String bigPicture = AppStrings.DEFAULT_ICON,
    NotificationLayout layout = NotificationLayout.BigPicture,
    required NotificationCalendar notificationCalendar,
  }) async {
    // Create the notification
    await awesomeNotifications.createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        bigPicture: bigPicture,
        notificationLayout: layout,
      ),
      actionButtons: [
        NotificationActionButton(
          key: AppStrings.SCHEDULED_NOTIFICATION_BUTTON1_KEY,
          label: 'Mark Done',
        ),
        NotificationActionButton(
          key: AppStrings.SCHEDULED_NOTIFICATION_BUTTON2_KEY,
          label: 'Clear',
        ),
      ],
      schedule: NotificationCalendar(
        weekday: notificationCalendar.weekday,
        hour: notificationCalendar.hour,
        minute: notificationCalendar.minute,
        repeats: true,
      ),
    );

    // Calculate the next occurrence of the notification
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      notificationCalendar.hour ?? 0,
      notificationCalendar.minute ?? 0,
    );

    // Adjust the date to the next occurrence of the specified weekday
    while (scheduledDate.weekday != (notificationCalendar.weekday ?? 1)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Store the notification in preferences
    await _storeNotification(
      app_notification.NotificationModel(
        id: id,
        title: title,
        body: body,
        channelKey: channelKey,
        scheduledDateTime: scheduledDate,
        isScheduled: true,
      ),
    );
  }

  /// Cancels all currently scheduled notifications.
  void cancelAllScheduledNotifications({required BuildContext context}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);

    // Cancel scheduled notifications and all notifications that may be shown
    // Use the instance's AwesomeNotifications to ensure we affect this app's notifications
    try {
      await awesomeNotifications.cancelAllSchedules();
    } catch (_) {}
    try {
      await awesomeNotifications.cancelAll();
    } catch (_) {}

    // Optionally show feedback
    awesomeNotifications.cancelAllSchedules().then((value) => {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cancelled all scheduled notifications'),
          backgroundColor: AppColor.primaryColor,
        ),
      )
    });
  }

  /// Requests permission from the user to send notifications. This is crucial for Android 13+ and iOS.
  void requestPermissionToSendNotifications({required BuildContext context}) {
    AwesomeNotifications().requestPermissionToSendNotifications().then((value) {
      // After requesting permission, pop the dialog that prompted the user.
      Navigator.of(context).pop();
    });
  }

  /// Static methods for handling notification lifecycle events.
  /// These methods are marked with `@pragma("vm:entry-point")` to ensure they are accessible
  /// even when the application is running in the background or killed.

  /// Use this method to detect when a new notification or a schedule is created.
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification, BuildContext context) async {
    // Show a SnackBar to indicate that a notification has been created.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification created ${receivedNotification.channelKey}',
        ),
        backgroundColor: AppColor.primaryColor,
      ),
    );
  }

  /// Use this method to detect every time that a new notification is displayed.
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code to handle a notification being displayed can go here.
    // For example, you might log the event or update a UI element.
  }

  /// Use this method to detect if the user dismissed a notification.
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code to handle a notification being dismissed can go here.
    // This is useful for tracking user interaction or cleaning up resources.
  }

  /// Use this method to detect when the user taps on a notification or an action button within it.
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Reducing icon badge count on iOS when a basic notification is tapped/acted upon.
    // This is important for maintaining accurate badge counts.
    if (receivedAction.channelKey == AppStrings.BASIC_CHANNEL_KEY &&
        Platform.isIOS) {
      AwesomeNotifications().getGlobalBadgeCounter().then((value) {
        AwesomeNotifications().setGlobalBadgeCounter(value - 1);
      });
    }
/*
    // Navigating to the StatsPage when any notification action is received.
    // The `navigatorKey` from `MyApp` is used to navigate from anywhere in the app.
    PocketPenguinApp.navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const StatsPage(),
        ),
        (route) => route.isFirst);
  }
*/

      } }