import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:pocket_penguin_app/utilities/notification_util.dart';

/// A very small fake which overrides the specific methods used by NotificationUtil.
class FakeAwesomeNotifications extends AwesomeNotifications {
  bool cancelAllCalled = false;
  bool cancelAllSchedulesCalled = false;

  @override
  Future<bool> createNotification({
    List<NotificationActionButton>? actionButtons,
    required NotificationContent content,
    Map<String, NotificationLocalization>? localizations,
    NotificationSchedule? schedule,
  }) async {
    // Intentionally do nothing for unit tests.
    return true;
  }

  @override
  Future<bool> cancelAll() async {
    cancelAllCalled = true;
    return true;
  }

  @override
  Future<bool> cancelAllSchedules() async {
    cancelAllSchedulesCalled = true;
    return true;
  }
}

void main() {
  group('NotificationUtil storage tests', () {
    setUp(() async {
      // Start each test with empty SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('createBasicNotification stores a notification', () async {
      final fake = FakeAwesomeNotifications();
      final util = NotificationUtil(awesomeNotifications: fake);

      await util.createBasicNotification(
        id: 111,
        channelKey: 'basic',
        title: 'Test Basic',
        body: 'Body',
      );

      final list = await util.getNotifications();
      expect(list, isNotNull);
      expect(list.length, 1);
      final n = list.first;
      expect(n.id, 111);
      expect(n.title, 'Test Basic');
      expect(n.body, 'Body');
      expect(n.isScheduled, false);
    });

    test('createScheduledNotification stores scheduled notification', () async {
      final fake = FakeAwesomeNotifications();
      final util = NotificationUtil(awesomeNotifications: fake);

      final calendar = NotificationCalendar(hour: 9, minute: 30, weekday: 2);

      await util.createScheduledNotification(
        id: 222,
        channelKey: 'schedule',
        title: 'Test Scheduled',
        body: 'Scheduled body',
        notificationCalendar: calendar,
      );

      final list = await util.getNotifications();
      expect(list.length, 1);
      final n = list.first;
      expect(n.id, 222);
      expect(n.title, 'Test Scheduled');
      expect(n.isScheduled, true);
      expect(n.scheduledDateTime, isNotNull);
    });

    test('removeNotification removes the specific entry', () async {
      final fake = FakeAwesomeNotifications();
      final util = NotificationUtil(awesomeNotifications: fake);

      await util.createBasicNotification(id: 1, channelKey: 'c', title: 'A', body: 'a');
      await util.createBasicNotification(id: 2, channelKey: 'c', title: 'B', body: 'b');

      var list = await util.getNotifications();
      expect(list.length, 2);

      await util.removeNotification(1);
      list = await util.getNotifications();
      expect(list.length, 1);
      expect(list.first.id, 2);
    });

    test('removeAllNotification clears storage and cancels notifications', () async {
      final fake = FakeAwesomeNotifications();
      final util = NotificationUtil(awesomeNotifications: fake);

      await util.createBasicNotification(id: 7, channelKey: 'c', title: 'X', body: 'x');
      var list = await util.getNotifications();
      expect(list.length, 1);

      await util.removeAllNotification();

      list = await util.getNotifications();
      expect(list.length, 0);
      // check that cancelAll was invoked on the fake
      expect(fake.cancelAllCalled || fake.cancelAllSchedulesCalled, true);
    });
  });
}
