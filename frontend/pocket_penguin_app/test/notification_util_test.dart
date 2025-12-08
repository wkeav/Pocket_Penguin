import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_penguin_app/utilities/notification_util.dart';
import 'package:pocket_penguin_app/constants/app_strings.dart';

void main() {
  late NotificationUtil notificationUtil;
  late AwesomeNotifications mockAwesomeNotifications;

  // Reset state before each test to ensure isolation
  setUp(() {
    // Initialize mock shared preferences with empty state
    SharedPreferences.setMockInitialValues({});
    
    // Create instances for testing
    mockAwesomeNotifications = AwesomeNotifications();
    notificationUtil = NotificationUtil(
      awesomeNotifications: mockAwesomeNotifications,
    );
    
    // Reset static callbacks to null to prevent cross-test interference
    NotificationUtil.onNotificationListChanged = null;
    NotificationUtil.onNotificationDisplayedCallback = null;
  });

  group('NotificationUtil - Core Functionality', () {
    test('creates and retrieves basic notification', () async {
      // Create a basic notification with id 1
      await notificationUtil.createBasicNotification(
        id: 1,
        channelKey: AppStrings.BASIC_CHANNEL_KEY,
        title: 'Test',
        body: 'Body',
      );

      // Retrieve all notifications from storage
      final notifications = await notificationUtil.getNotifications();
      
      // Verify the notification was stored correctly
      expect(notifications.length, 1);
      expect(notifications[0].id, 1);
      expect(notifications[0].isScheduled, false);
    });

    test('creates notification with custom name', () async {
      // Create a notification with custom name/description that overrides defaults
      await notificationUtil.createBasicNotification(
        id: 2,
        channelKey: AppStrings.BASIC_CHANNEL_KEY,
        title: 'Default',
        body: 'Body',
        customName: 'Custom',
        customDescription: 'Custom Body',
      );

      // Retrieve notifications from storage
      final notifications = await notificationUtil.getNotifications();
      
      // Verify the custom values were stored instead of default values
      expect(notifications[0].title, 'Custom');
      expect(notifications[0].body, 'Custom Body');
    });

    test('removes notification by id', () async {
      // Create a notification to be removed
      await notificationUtil.createBasicNotification(
        id: 10,
        channelKey: AppStrings.BASIC_CHANNEL_KEY,
        title: 'Test',
        body: 'Body',
      );

      // Remove the notification by its id
      await notificationUtil.removeNotification(10);
      
      // Verify the notification list is now empty
      final notifications = await notificationUtil.getNotifications();
      expect(notifications, isEmpty);
    });

    test('callback is triggered on notification creation', () async {
      // Set up a callback that sets a flag when triggered
      bool triggered = false;
      NotificationUtil.onNotificationListChanged = () => triggered = true;

      // Create a notification which should trigger the callback
      await notificationUtil.createBasicNotification(
        id: 100,
        channelKey: AppStrings.BASIC_CHANNEL_KEY,
        title: 'Test',
        body: 'Body',
      );

      // Verify the callback was triggered
      expect(triggered, true);
    });
  });
}
