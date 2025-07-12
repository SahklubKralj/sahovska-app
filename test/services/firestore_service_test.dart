import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:shahovska_app/services/firestore_service.dart';
import 'package:shahovska_app/models/user_model.dart';
import 'package:shahovska_app/models/notification_model.dart';
import 'firestore_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  Query,
])
void main() {
  group('FirestoreService Tests', () {
    late FirestoreService firestoreService;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
    late MockCollectionReference<Map<String, dynamic>> mockNotificationsCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
      mockNotificationsCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
      mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      firestoreService = FirestoreService(firestore: mockFirestore);

      // Setup collection mocks
      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockFirestore.collection('notifications')).thenReturn(mockNotificationsCollection);
    });

    group('User Operations', () {
      test('should create user successfully', () async {
        // Arrange
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isAdmin: false,
          createdAt: DateTime.now(),
          fcmToken: 'test-token',
        );

        when(mockUsersCollection.doc(user.uid)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.set(any)).thenAnswer((_) async {});

        // Act
        await firestoreService.createUser(user);

        // Assert
        verify(mockUsersCollection.doc(user.uid)).called(1);
        verify(mockDocumentReference.set(user.toFirestore())).called(1);
      });

      test('should get user successfully', () async {
        // Arrange
        const uid = 'test-uid';
        final userData = {
          'email': 'test@example.com',
          'displayName': 'Test User',
          'isAdmin': false,
          'createdAt': DateTime.now().toIso8601String(),
          'fcmToken': 'test-token',
        };

        when(mockUsersCollection.doc(uid)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn(userData);
        when(mockDocumentSnapshot.id).thenReturn(uid);

        // Act
        final result = await firestoreService.getUser(uid);

        // Assert
        expect(result, isNotNull);
        expect(result!.uid, equals(uid));
        expect(result.email, equals('test@example.com'));
        verify(mockUsersCollection.doc(uid)).called(1);
        verify(mockDocumentReference.get()).called(1);
      });

      test('should return null when user does not exist', () async {
        // Arrange
        const uid = 'non-existent-uid';

        when(mockUsersCollection.doc(uid)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await firestoreService.getUser(uid);

        // Assert
        expect(result, isNull);
      });

      test('should update user successfully', () async {
        // Arrange
        final user = UserModel(
          uid: 'test-uid',
          email: 'updated@example.com',
          displayName: 'Updated User',
          isAdmin: true,
          createdAt: DateTime.now(),
          fcmToken: 'updated-token',
        );

        when(mockUsersCollection.doc(user.uid)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any)).thenAnswer((_) async {});

        // Act
        await firestoreService.updateUser(user);

        // Assert
        verify(mockUsersCollection.doc(user.uid)).called(1);
        verify(mockDocumentReference.update(user.toFirestore())).called(1);
      });

      test('should update FCM token successfully', () async {
        // Arrange
        const uid = 'test-uid';
        const fcmToken = 'new-fcm-token';

        when(mockUsersCollection.doc(uid)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any)).thenAnswer((_) async {});

        // Act
        await firestoreService.updateUserFCMToken(uid, fcmToken);

        // Assert
        verify(mockUsersCollection.doc(uid)).called(1);
        verify(mockDocumentReference.update({'fcmToken': fcmToken})).called(1);
      });
    });

    group('Notification Operations', () {
      test('should create notification successfully', () async {
        // Arrange
        final notification = NotificationModel(
          id: '',
          title: 'Test Notification',
          content: 'Test content',
          type: NotificationType.general,
          createdAt: DateTime.now(),
          createdBy: 'test-uid',
          imageUrls: ['https://example.com/image.jpg'],
        );

        when(mockNotificationsCollection.add(any)).thenAnswer((_) async => mockDocumentReference);

        // Act
        await firestoreService.createNotification(notification);

        // Assert
        verify(mockNotificationsCollection.add(notification.toFirestore())).called(1);
      });

      test('should get notifications stream successfully', () async {
        // Arrange
        final mockQuery = MockQuery<Map<String, dynamic>>();
        final stream = Stream<QuerySnapshot<Map<String, dynamic>>>.value(mockQuerySnapshot);

        when(mockNotificationsCollection.where('isActive', isEqualTo: true))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.snapshots()).thenReturn(stream);

        // Mock query snapshot
        final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.id).thenReturn('notification-id');
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'title': 'Test Notification',
          'content': 'Test content',
          'type': 'general',
          'createdAt': DateTime.now().toIso8601String(),
          'createdBy': 'test-uid',
          'isActive': true,
        });

        // Act
        final result = firestoreService.getNotificationsStream();

        // Assert
        expect(result, isA<Stream<List<NotificationModel>>>());
        verify(mockNotificationsCollection.where('isActive', isEqualTo: true)).called(1);
      });

      test('should delete notification successfully', () async {
        // Arrange
        const notificationId = 'test-notification-id';

        when(mockNotificationsCollection.doc(notificationId)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any)).thenAnswer((_) async {});

        // Act
        await firestoreService.deleteNotification(notificationId);

        // Assert
        verify(mockNotificationsCollection.doc(notificationId)).called(1);
        verify(mockDocumentReference.update({'isActive': false})).called(1);
      });
    });

    group('Error Handling', () {
      test('should throw exception when createUser fails', () async {
        // Arrange
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isAdmin: false,
          createdAt: DateTime.now(),
        );

        when(mockUsersCollection.doc(user.uid)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.set(any)).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ));

        // Act & Assert
        expect(
          () => firestoreService.createUser(user),
          throwsA(isA<FirebaseException>()),
        );
      });

      test('should throw exception when getUser fails', () async {
        // Arrange
        const uid = 'test-uid';

        when(mockUsersCollection.doc(uid)).thenReturn(mockDocumentReference);
        when(mockDocumentReference.get()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        ));

        // Act & Assert
        expect(
          () => firestoreService.getUser(uid),
          throwsA(isA<FirebaseException>()),
        );
      });
    });
  });
}