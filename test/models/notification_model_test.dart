import 'package:flutter_test/flutter_test.dart';
import 'package:sahovska_app/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('should create NotificationModel from constructor', () {
      final notification = NotificationModel(
        id: 'test-id',
        title: 'Test Title',
        content: 'Test Content',
        type: NotificationType.tournament,
        createdAt: DateTime(2023, 1, 1),
        createdBy: 'user-id',
      );

      expect(notification.id, 'test-id');
      expect(notification.title, 'Test Title');
      expect(notification.content, 'Test Content');
      expect(notification.type, NotificationType.tournament);
      expect(notification.createdAt, DateTime(2023, 1, 1));
      expect(notification.createdBy, 'user-id');
      expect(notification.isActive, true);
      expect(notification.imageUrls, null);
    });

    test('should create NotificationModel from Firestore data', () {
      final data = {
        'title': 'Firestore Title',
        'content': 'Firestore Content',
        'type': 'camp',
        'createdAt': '2023-01-01T00:00:00.000Z',
        'createdBy': 'admin-id',
        'isActive': false,
        'imageUrls': ['image1.jpg', 'image2.jpg'],
      };

      final notification = NotificationModel.fromFirestore(data, 'firestore-id');

      expect(notification.id, 'firestore-id');
      expect(notification.title, 'Firestore Title');
      expect(notification.content, 'Firestore Content');
      expect(notification.type, NotificationType.camp);
      expect(notification.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(notification.createdBy, 'admin-id');
      expect(notification.isActive, false);
      expect(notification.imageUrls, ['image1.jpg', 'image2.jpg']);
    });

    test('should convert NotificationModel to Firestore data', () {
      final notification = NotificationModel(
        id: 'test-id',
        title: 'Test Title',
        content: 'Test Content',
        type: NotificationType.general,
        createdAt: DateTime(2023, 1, 1),
        createdBy: 'user-id',
        imageUrls: ['test.jpg'],
        isActive: false,
      );

      final firestoreData = notification.toFirestore();

      expect(firestoreData['title'], 'Test Title');
      expect(firestoreData['content'], 'Test Content');
      expect(firestoreData['type'], 'general');
      expect(firestoreData['createdAt'], '2023-01-01T00:00:00.000');
      expect(firestoreData['createdBy'], 'user-id');
      expect(firestoreData['imageUrls'], ['test.jpg']);
      expect(firestoreData['isActive'], false);
    });

    test('should return correct type display name', () {
      expect(NotificationModel(
        id: '',
        title: '',
        content: '',
        type: NotificationType.general,
        createdAt: DateTime.now(),
        createdBy: '',
      ).typeDisplayName, 'Opšte');

      expect(NotificationModel(
        id: '',
        title: '',
        content: '',
        type: NotificationType.tournament,
        createdAt: DateTime.now(),
        createdBy: '',
      ).typeDisplayName, 'Turnir');

      expect(NotificationModel(
        id: '',
        title: '',
        content: '',
        type: NotificationType.camp,
        createdAt: DateTime.now(),
        createdBy: '',
      ).typeDisplayName, 'Kamp');

      expect(NotificationModel(
        id: '',
        title: '',
        content: '',
        type: NotificationType.training,
        createdAt: DateTime.now(),
        createdBy: '',
      ).typeDisplayName, 'Trening');
    });

    test('should create copy with updated values', () {
      final original = NotificationModel(
        id: 'original-id',
        title: 'Original Title',
        content: 'Original Content',
        type: NotificationType.general,
        createdAt: DateTime(2023, 1, 1),
        createdBy: 'user-id',
      );

      final copy = original.copyWith(
        title: 'Updated Title',
        type: NotificationType.tournament,
      );

      expect(copy.id, 'original-id');
      expect(copy.title, 'Updated Title');
      expect(copy.content, 'Original Content');
      expect(copy.type, NotificationType.tournament);
      expect(copy.createdAt, DateTime(2023, 1, 1));
      expect(copy.createdBy, 'user-id');
    });

    test('should handle missing data gracefully in fromFirestore', () {
      final data = <String, dynamic>{};

      final notification = NotificationModel.fromFirestore(data, 'test-id');

      expect(notification.id, 'test-id');
      expect(notification.title, '');
      expect(notification.content, '');
      expect(notification.type, NotificationType.general);
      expect(notification.createdBy, '');
      expect(notification.isActive, true);
      expect(notification.imageUrls, null);
    });

    test('should handle invalid type in fromFirestore', () {
      final data = {
        'type': 'invalid_type',
      };

      final notification = NotificationModel.fromFirestore(data, 'test-id');

      expect(notification.type, NotificationType.general);
    });
  });
}