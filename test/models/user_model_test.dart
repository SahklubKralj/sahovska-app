import 'package:flutter_test/flutter_test.dart';
import 'package:sahovska_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from constructor', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isAdmin: true,
        createdAt: DateTime(2023, 1, 1),
        fcmToken: 'fcm-token',
      );

      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.isAdmin, true);
      expect(user.createdAt, DateTime(2023, 1, 1));
      expect(user.fcmToken, 'fcm-token');
    });

    test('should create UserModel with default values', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime(2023, 1, 1),
      );

      expect(user.isAdmin, false);
      expect(user.fcmToken, null);
    });

    test('should create UserModel from Firestore data', () {
      final data = {
        'email': 'firestore@example.com',
        'displayName': 'Firestore User',
        'isAdmin': true,
        'createdAt': '2023-01-01T00:00:00.000Z',
        'fcmToken': 'firestore-token',
      };

      final user = UserModel.fromFirestore(data, 'firestore-uid');

      expect(user.uid, 'firestore-uid');
      expect(user.email, 'firestore@example.com');
      expect(user.displayName, 'Firestore User');
      expect(user.isAdmin, true);
      expect(user.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(user.fcmToken, 'firestore-token');
    });

    test('should convert UserModel to Firestore data', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isAdmin: true,
        createdAt: DateTime(2023, 1, 1),
        fcmToken: 'test-token',
      );

      final firestoreData = user.toFirestore();

      expect(firestoreData['email'], 'test@example.com');
      expect(firestoreData['displayName'], 'Test User');
      expect(firestoreData['isAdmin'], true);
      expect(firestoreData['createdAt'], '2023-01-01T00:00:00.000');
      expect(firestoreData['fcmToken'], 'test-token');
      expect(firestoreData.containsKey('uid'), false);
    });

    test('should create copy with updated values', () {
      final original = UserModel(
        uid: 'original-uid',
        email: 'original@example.com',
        displayName: 'Original User',
        isAdmin: false,
        createdAt: DateTime(2023, 1, 1),
      );

      final copy = original.copyWith(
        email: 'updated@example.com',
        isAdmin: true,
        fcmToken: 'new-token',
      );

      expect(copy.uid, 'original-uid');
      expect(copy.email, 'updated@example.com');
      expect(copy.displayName, 'Original User');
      expect(copy.isAdmin, true);
      expect(copy.createdAt, DateTime(2023, 1, 1));
      expect(copy.fcmToken, 'new-token');
    });

    test('should handle missing data gracefully in fromFirestore', () {
      final data = <String, dynamic>{};

      final user = UserModel.fromFirestore(data, 'test-uid');

      expect(user.uid, 'test-uid');
      expect(user.email, '');
      expect(user.displayName, '');
      expect(user.isAdmin, false);
      expect(user.fcmToken, null);
    });

    test('should handle missing createdAt in fromFirestore', () {
      final data = {
        'email': 'test@example.com',
        'displayName': 'Test User',
      };

      final user = UserModel.fromFirestore(data, 'test-uid');

      expect(user.createdAt, isA<DateTime>());
      expect(user.createdAt.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
    });
  });
}