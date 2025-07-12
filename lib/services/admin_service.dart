import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Proveri da li je trenutni korisnik admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      // Proverava custom claims
      IdTokenResult tokenResult = await user.getIdTokenResult();
      return tokenResult.claims?['admin'] == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Postavi korisnika kao admina (samo drugi admin može ovo da uradi)
  Future<bool> setUserAsAdmin(String userId) async {
    try {
      bool isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Samo administratori mogu dodelu admin prava');
      }

      // Ova funkcija bi trebalo da pozove Cloud Function
      // jer Flutter ne može direktno da menja custom claims
      // 
      // Umesto toga, možemo dodati flag u Firestore dokument
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': true,
        'adminSetBy': _auth.currentUser?.uid,
        'adminSetAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Greška pri postavljanju admin prava: ${e.toString()}');
    }
  }

  // Ukloni admin prava
  Future<bool> removeAdminRights(String userId) async {
    try {
      bool isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Samo administratori mogu uklanjati admin prava');
      }

      await _firestore.collection('users').doc(userId).update({
        'isAdmin': false,
        'adminRemovedBy': _auth.currentUser?.uid,
        'adminRemovedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Greška pri uklanjanju admin prava: ${e.toString()}');
    }
  }

  // Dobij sve admin korisnike
  Future<List<UserModel>> getAllAdmins() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri dobijanju admin korisnika: ${e.toString()}');
    }
  }

  // Dobij sve obične korisnike
  Future<List<UserModel>> getAllUsers() async {
    try {
      bool isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Samo administratori mogu videti sve korisnike');
      }

      QuerySnapshot snapshot = await _firestore.collection('users').get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri dobijanju korisnika: ${e.toString()}');
    }
  }

  // Dobij statistike za admin panel
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      bool isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Samo administratori mogu videti statistike');
      }

      // Broj ukupnih korisnika
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      int totalUsers = usersSnapshot.size;

      // Broj ukupnih obaveštenja
      QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('isActive', isEqualTo: true)
          .get();
      int totalNotifications = notificationsSnapshot.size;

      // Broj obaveštenja po tipovima
      Map<String, int> notificationsByType = {};
      for (var doc in notificationsSnapshot.docs) {
        String type = doc.data() as Map<String, dynamic>['type'] ?? 'general';
        notificationsByType[type] = (notificationsByType[type] ?? 0) + 1;
      }

      // Broj korisnika registrovanih ove nedelje
      DateTime weekAgo = DateTime.now().subtract(Duration(days: 7));
      QuerySnapshot recentUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThan: weekAgo.toIso8601String())
          .get();
      int recentUsers = recentUsersSnapshot.size;

      return {
        'totalUsers': totalUsers,
        'totalNotifications': totalNotifications,
        'notificationsByType': notificationsByType,
        'recentUsers': recentUsers,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Greška pri dobijanju statistika: ${e.toString()}');
    }
  }

  // Pošalji test notifikaciju
  Future<bool> sendTestNotification() async {
    try {
      bool isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Samo administratori mogu slati test notifikacije');
      }

      // Ova funkcija bi trebalo da pozove Cloud Function za slanje FCM notifikacije
      // Za sada, kreiramo test obaveštenje
      await _firestore.collection('notifications').add({
        'title': 'Test obaveštenje',
        'content': 'Ovo je test obaveštenje poslato od strane administratora.',
        'type': 'general',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
        'isActive': true,
        'isTest': true,
      });

      return true;
    } catch (e) {
      throw Exception('Greška pri slanju test notifikacije: ${e.toString()}');
    }
  }
}