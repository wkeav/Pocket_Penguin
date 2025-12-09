import 'dart:io';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';
import '../constants/colors.dart';
import '../models/notification_model.dart' as app_notification;

class NotificationUtil {
  final AwesomeNotifications awesomeNotifications;
  static const String _notificationsKey = 'notifications_list';
  static VoidCallback? onNotificationListChanged;
  static Function(String title, String body)? onNotificationDisplayedCallback;

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
  Future<void> _storeNotification(
      app_notification.NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    List<app_notification.NotificationModel> notifications =
        await getNotifications();
    notifications.add(notification);

    await prefs.setString(
      _notificationsKey,
      jsonEncode(notifications.map((n) => n.toMap()).toList()),
    );

    // Trigger UI update callback if set
    onNotificationListChanged?.call();
  }

  // Remove a notification
  Future<void> removeNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<app_notification.NotificationModel> notifications =
        await getNotifications();
    notifications.removeWhere((n) => n.id == id);
    await prefs.setString(
      _notificationsKey,
      jsonEncode(notifications.map((n) => n.toMap()).toList()),
    );

    // Trigger UI update callback if set
    onNotificationListChanged?.call();
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
  /// [customName] and [customDescription] can be used to override the stored notification's display name/description
  Future<void> createBasicNotification({
    required int id,
    required String channelKey,
    required String title,
    required String body,
    String bigPicture = AppStrings.DEFAULT_ICON,
    NotificationLayout layout = NotificationLayout.BigPicture,
    String? customName,
    String? customDescription,
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
        title: customName ?? title,
        body: customDescription ?? body,
        channelKey: channelKey,
        isScheduled: false,
      ),
    );
  }

  /// Creates a scheduled notification that will appear at a specific time and can repeat.
  /// [customName] and [customDescription] can be used to override the stored notification's display name/description
  Future<void> createScheduledNotification({
    required int id,
    required String channelKey,
    required String title,
    required String body,
    String bigPicture = AppStrings.DEFAULT_ICON,
    NotificationLayout layout = NotificationLayout.BigPicture,
    required NotificationCalendar notificationCalendar,
    String? customName,
    String? customDescription,
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
        title: customName ?? title,
        body: customDescription ?? body,
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
    // Store the displayed notification to ensure it appears in the list
    // This is especially important for basic notifications that are shown immediately
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    List<app_notification.NotificationModel> notifications = [];
    if (notificationsJson != null) {
      List<dynamic> notificationsList = jsonDecode(notificationsJson);
      notifications = notificationsList
          .map((item) => app_notification.NotificationModel.fromMap(item))
          .toList();
    }

    // Check if this notification is already stored
    bool alreadyStored =
        notifications.any((n) => n.id == receivedNotification.id);

    // If not already stored (shouldn't happen for properly created notifications, but ensures visibility)
    if (!alreadyStored) {
      notifications.add(
        app_notification.NotificationModel(
          id: receivedNotification.id ?? 0,
          title: receivedNotification.title ?? 'Notification',
          body: receivedNotification.body ?? '',
          channelKey:
              receivedNotification.channelKey ?? AppStrings.BASIC_CHANNEL_KEY,
          isScheduled: false,
        ),
      );

      await prefs.setString(
        _notificationsKey,
        jsonEncode(notifications.map((n) => n.toMap()).toList()),
      );

      // Trigger UI update callback if set
      onNotificationListChanged?.call();
    }

    // Trigger popup callback for scheduled notifications hitting their deadline
    // Note: This only works if the app is in the foreground
    if (receivedNotification.channelKey == AppStrings.SCHEDULE_CHANNEL_KEY) {
      // Use a short delay to ensure the callback is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        onNotificationDisplayedCallback?.call(
          receivedNotification.title ?? 'Notification',
          receivedNotification.body ?? '',
        );
      });
    }
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
    // Ensure the notification is stored when it's clicked
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    List<app_notification.NotificationModel> notifications = [];
    if (notificationsJson != null) {
      List<dynamic> notificationsList = jsonDecode(notificationsJson);
      notifications = notificationsList
          .map((item) => app_notification.NotificationModel.fromMap(item))
          .toList();
    }

    // Check if this notification is already stored
    bool alreadyStored = notifications.any((n) => n.id == receivedAction.id);

    // If not already stored, add it to ensure it's visible
    if (!alreadyStored) {
      notifications.add(
        app_notification.NotificationModel(
          id: receivedAction.id ?? 0,
          title: receivedAction.title ?? 'Notification',
          body: receivedAction.body ?? '',
          channelKey: receivedAction.channelKey ?? AppStrings.BASIC_CHANNEL_KEY,
          isScheduled: false,
        ),
      );

      await prefs.setString(
        _notificationsKey,
        jsonEncode(notifications.map((n) => n.toMap()).toList()),
      );

      // Trigger UI update callback if set
      onNotificationListChanged?.call();
    }

    // Trigger popup for scheduled notifications when clicked
    if (receivedAction.channelKey == AppStrings.SCHEDULE_CHANNEL_KEY) {
      onNotificationDisplayedCallback?.call(
        receivedAction.title ?? 'Reminder',
        receivedAction.body ?? '',
      );
    }

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
  }
}
