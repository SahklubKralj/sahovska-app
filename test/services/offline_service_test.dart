import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahovska_app/services/offline_service.dart';
import 'package:sahovska_app/models/notification_model.dart';

void main() {
  group('OfflineService', () {
    late OfflineService offlineService;

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      offlineService = OfflineService();
      await offlineService.initialize();
    });

    tearDown(() async {
      await offlineService.clearAllOfflineData();
    });

    test('should save and retrieve notifications offline', () async {
      final notifications = [
        NotificationModel(
          id: 'test1',
          title: 'Test 1',
          content: 'Content 1',
          type: NotificationType.general,
          createdAt: DateTime(2023, 1, 1),
          createdBy: 'user1',
        ),
        NotificationModel(
          id: 'test2',
          title: 'Test 2',
          content: 'Content 2',
          type: NotificationType.tournament,
          createdAt: DateTime(2023, 1, 2),
          createdBy: 'user2',
        ),
      ];

      await offlineService.saveNotificationsOffline(notifications);

      final retrievedNotifications = await offlineService.getOfflineNotifications();

      expect(retrievedNotifications.length, 2);
      expect(retrievedNotifications[0].id, 'test1');
      expect(retrievedNotifications[0].title, 'Test 1');
      expect(retrievedNotifications[1].id, 'test2');
      expect(retrievedNotifications[1].title, 'Test 2');
    });

    test('should return empty list when no offline data exists', () async {
      final notifications = await offlineService.getOfflineNotifications();
      expect(notifications, isEmpty);
    });

    test('should check if offline data exists', () async {
      expect(await offlineService.hasOfflineData(), false);

      final notifications = [
        NotificationModel(
          id: 'test',
          title: 'Test',
          content: 'Content',
          type: NotificationType.general,
          createdAt: DateTime.now(),
          createdBy: 'user',
        ),
      ];

      await offlineService.saveNotificationsOffline(notifications);
      expect(await offlineService.hasOfflineData(), true);
    });

    test('should clear offline notifications', () async {
      final notifications = [
        NotificationModel(
          id: 'test',
          title: 'Test',
          content: 'Content',
          type: NotificationType.general,
          createdAt: DateTime.now(),
          createdBy: 'user',
        ),
      ];

      await offlineService.saveNotificationsOffline(notifications);
      expect(await offlineService.hasOfflineData(), true);

      await offlineService.clearOfflineNotifications();
      expect(await offlineService.hasOfflineData(), false);
    });

    test('should save and retrieve last sync date', () async {
      final notifications = [
        NotificationModel(
          id: 'test',
          title: 'Test',
          content: 'Content',
          type: NotificationType.general,
          createdAt: DateTime.now(),
          createdBy: 'user',
        ),
      ];

      final beforeSync = DateTime.now();
      await offlineService.saveNotificationsOffline(notifications);
      final afterSync = DateTime.now();

      final lastSync = await offlineService.getLastSyncDate();
      expect(lastSync, isNotNull);
      expect(lastSync!.isAfter(beforeSync.subtract(Duration(seconds: 1))), true);
      expect(lastSync.isBefore(afterSync.add(Duration(seconds: 1))), true);
    });

    test('should save and retrieve user preferences', () async {
      final preferences = {
        'theme': 'dark',
        'notifications': true,
        'language': 'sr',
      };

      await offlineService.saveUserPreferences(preferences);
      final retrievedPreferences = await offlineService.getUserPreferences();

      expect(retrievedPreferences, isNotNull);
      expect(retrievedPreferences!['theme'], 'dark');
      expect(retrievedPreferences['notifications'], true);
      expect(retrievedPreferences['language'], 'sr');
    });

    test('should track first launch', () async {
      expect(await offlineService.isFirstLaunch(), true);
      expect(await offlineService.isFirstLaunch(), false);
    });

    test('should mark notifications as read', () async {
      const notificationId = 'test-notification';

      expect(await offlineService.isNotificationRead(notificationId), false);

      await offlineService.markNotificationAsRead(notificationId);
      expect(await offlineService.isNotificationRead(notificationId), true);
    });

    test('should save and retrieve draft notification', () async {
      final draft = {
        'title': 'Draft Title',
        'content': 'Draft Content',
        'type': 'general',
        'createdBy': 'admin',
      };

      await offlineService.saveDraftNotification(draft);
      final retrievedDraft = await offlineService.getDraftNotification();

      expect(retrievedDraft, isNotNull);
      expect(retrievedDraft!['title'], 'Draft Title');
      expect(retrievedDraft['content'], 'Draft Content');
      expect(retrievedDraft['type'], 'general');
    });

    test('should clear draft notification', () async {
      final draft = {
        'title': 'Draft Title',
        'content': 'Draft Content',
      };

      await offlineService.saveDraftNotification(draft);
      expect(await offlineService.getDraftNotification(), isNotNull);

      await offlineService.clearDraftNotification();
      expect(await offlineService.getDraftNotification(), isNull);
    });

    test('should track last online time', () async {
      final beforeOnline = DateTime.now();
      await offlineService.setLastOnlineTime();
      final afterOnline = DateTime.now();

      final lastOnlineTime = await offlineService.getLastOnlineTime();
      expect(lastOnlineTime, isNotNull);
      expect(lastOnlineTime!.isAfter(beforeOnline.subtract(Duration(seconds: 1))), true);
      expect(lastOnlineTime.isBefore(afterOnline.add(Duration(seconds: 1))), true);
    });

    test('should provide storage info', () async {
      final notifications = [
        NotificationModel(
          id: 'test',
          title: 'Test',
          content: 'Content',
          type: NotificationType.general,
          createdAt: DateTime.now(),
          createdBy: 'user',
        ),
      ];

      await offlineService.saveNotificationsOffline(notifications);
      await offlineService.saveUserPreferences({'test': 'value'});

      final storageInfo = await offlineService.getStorageInfo();

      expect(storageInfo['notificationsCount'], 1);
      expect(storageInfo['hasPreferences'], true);
      expect(storageInfo['lastSync'], isNotNull);
      expect(storageInfo['totalKeys'], greaterThan(0));
    });

    test('should clear all offline data', () async {
      final notifications = [
        NotificationModel(
          id: 'test',
          title: 'Test',
          content: 'Content',
          type: NotificationType.general,
          createdAt: DateTime.now(),
          createdBy: 'user',
        ),
      ];

      await offlineService.saveNotificationsOffline(notifications);
      await offlineService.saveUserPreferences({'test': 'value'});

      expect(await offlineService.hasOfflineData(), true);
      expect(await offlineService.getUserPreferences(), isNotNull);

      await offlineService.clearAllOfflineData();

      expect(await offlineService.hasOfflineData(), false);
      expect(await offlineService.getUserPreferences(), isNull);
    });
  });
}