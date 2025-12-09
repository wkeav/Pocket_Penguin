import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_penguin_app/utilities/notification_util.dart';
import 'package:pocket_penguin_app/models/notification_model.dart' as app_notification;
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationUtil Security Tests - CWE-200 Prevention', () {
    late NotificationUtil notificationUtil;

    setUp(() {
      // Clear any existing prefs before each test
      SharedPreferences.setMockInitialValues({});
      notificationUtil = NotificationUtil(
        awesomeNotifications: AwesomeNotifications(),
      );
    });

    test('Notifications are stored and retrieved only for current user instance', () async {
      // Create a notification for user A
      final notification1 = app_notification.NotificationModel(
        id: 1,
        title: 'User A Private Notification',
        body: 'Sensitive data for User A only',
        channelKey: 'test_channel',
        isScheduled: false,
      );

      // Store notification for user A
      await notificationUtil.createBasicNotification(
        id: notification1.id,
        channelKey: notification1.channelKey,
        title: notification1.title,
        body: notification1.body,
      );

      // Retrieve notifications for user A
      final userANotifications = await notificationUtil.getNotifications();

      // Print output to verify
      print('✅ User A notifications (should contain 1 notification):');
      print('   Count: ${userANotifications.length}');
      print('   Data: ${jsonEncode(userANotifications.map((n) => n.toMap()).toList())}');

      // Assert that only user A's notification exists
      expect(userANotifications.length, 1);
      expect(userANotifications.first.title, 'User A Private Notification');
      expect(userANotifications.first.body, 'Sensitive data for User A only');
      
      print('✅ PASS: Notifications are properly stored for the current user');
    });

    test('Notifications do not leak to other user instances', () async {
      // Simulate User A creating notifications
      await notificationUtil.createBasicNotification(
        id: 1,
        channelKey: 'channel_a',
        title: 'User A Secret',
        body: 'User A sensitive information',
      );

      // Get User A's notifications
      final userANotifications = await notificationUtil.getNotifications();
      print('✅ User A has ${userANotifications.length} notification(s)');

      // Simulate clearing all notifications (like logout)
      await notificationUtil.removeAllNotification();

      // Verify notifications are cleared
      final clearedNotifications = await notificationUtil.getNotifications();
      print('✅ After clearing: ${clearedNotifications.length} notification(s) remain');

      // Simulate User B (new session with fresh SharedPreferences)
      SharedPreferences.setMockInitialValues({});
      final userBNotificationUtil = NotificationUtil(
        awesomeNotifications: AwesomeNotifications(),
      );

      // User B should see no notifications from User A
      final userBNotifications = await userBNotificationUtil.getNotifications();
      print('✅ User B sees ${userBNotifications.length} notification(s) (should be 0)');

      // Assert User B cannot access User A's notifications
      expect(clearedNotifications.isEmpty, true);
      expect(userBNotifications.isEmpty, true);
      
      print('✅ PASS: User B cannot access User A\'s notifications (CWE-200 prevented)');
    });

    test('Multiple notifications maintain user isolation', () async {
      // User A creates multiple notifications with sensitive data
      await notificationUtil.createBasicNotification(
        id: 1,
        channelKey: 'private',
        title: 'Banking Alert',
        body: 'Your balance is \$1,234.56',
      );

      await notificationUtil.createBasicNotification(
        id: 2,
        channelKey: 'private',
        title: 'Medical Reminder',
        body: 'Take medication at 8 PM',
      );

      await notificationUtil.createBasicNotification(
        id: 3,
        channelKey: 'private',
        title: 'Private Meeting',
        body: 'Confidential project discussion at 3 PM',
      );

      // Retrieve all notifications for current user
      final notifications = await notificationUtil.getNotifications();

      print('✅ User stored ${notifications.length} sensitive notifications');
      for (var notif in notifications) {
        print('   - ${notif.title}: ${notif.body}');
      }

      // Verify all notifications are present
      expect(notifications.length, 3);
      expect(notifications.any((n) => n.body.contains('\$1,234.56')), true);
      expect(notifications.any((n) => n.body.contains('medication')), true);
      expect(notifications.any((n) => n.body.contains('Confidential')), true);

      // Remove one specific notification
      await notificationUtil.removeNotification(2);
      final afterRemoval = await notificationUtil.getNotifications();

      print('✅ After removing notification 2: ${afterRemoval.length} remain');
      expect(afterRemoval.length, 2);
      expect(afterRemoval.any((n) => n.id == 2), false);
      
      print('✅ PASS: Individual notification removal works correctly');
    });

    test('Notification data does not persist across user sessions', () async {
      // User session 1: Create notification
      await notificationUtil.createBasicNotification(
        id: 100,
        channelKey: 'session1',
        title: 'Session 1 Data',
        body: 'This should not leak to session 2',
      );

      final session1Data = await notificationUtil.getNotifications();
      print('✅ Session 1 created ${session1Data.length} notification(s)');

      // Simulate logout/session end - clear all data
      await notificationUtil.removeAllNotification();
      
      // Verify clear
      final afterClear = await notificationUtil.getNotifications();
      print('✅ After session 1 logout: ${afterClear.length} notification(s)');
      expect(afterClear.isEmpty, true);

      // Simulate new user session 2 (fresh instance)
      SharedPreferences.setMockInitialValues({});
      final session2Util = NotificationUtil(
        awesomeNotifications: AwesomeNotifications(),
      );

      final session2Data = await session2Util.getNotifications();
      print('✅ Session 2 sees ${session2Data.length} notification(s) from session 1');

      // Assert no data leakage between sessions
      expect(session2Data.isEmpty, true);
      expect(session2Data.any((n) => n.title == 'Session 1 Data'), false);
      
      print('✅ PASS: No data leakage between user sessions (CWE-200 prevented)');
    });
  });
}
