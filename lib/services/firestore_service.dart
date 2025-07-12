import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw Exception('Greška pri kreiranju korisnika: ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Greška pri dohvatanju korisnika: ${e.toString()}');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toFirestore());
    } catch (e) {
      throw Exception('Greška pri ažuriranju korisnika: ${e.toString()}');
    }
  }

  Future<void> updateUserFCMToken(String uid, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': fcmToken,
      });
    } catch (e) {
      throw Exception('Greška pri ažuriranju FCM tokena: ${e.toString()}');
    }
  }

  // Notification operations
  Future<String> createNotification(NotificationModel notification) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('notifications')
          .add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Greška pri kreiranju obaveštenja: ${e.toString()}');
    }
  }

  Stream<List<NotificationModel>> getNotifications() {
    return _firestore
        .collection('notifications')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> updateNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .update(notification.toFirestore());
    } catch (e) {
      throw Exception('Greška pri ažuriranju obaveštenja: ${e.toString()}');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isActive': false});
    } catch (e) {
      throw Exception('Greška pri brisanju obaveštenja: ${e.toString()}');
    }
  }

  // Get all users for sending push notifications
  Future<List<String>> getAllUserFCMTokens() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('fcmToken', isNotEqualTo: null)
          .get();
      
      return snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['fcmToken'] as String)
          .where((token) => token.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('Greška pri dohvatanju FCM tokena: ${e.toString()}');
    }
  }
}