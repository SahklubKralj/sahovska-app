import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';

class NotificationServiceProvider with ChangeNotifier {
  final NotificationService _notificationService;
  final FirestoreService _firestoreService;

  bool _isInitialized = false;
  String? _fcmToken;
  String? _error;

  NotificationServiceProvider({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService,
       _notificationService = NotificationService() {
    _initialize();
  }

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;
  String? get error => _error;

  Future<void> _initialize() async {
    try {
      await _notificationService.initialize();
      _fcmToken = await _notificationService.getFCMToken();
      _isInitialized = true;
      _error = null;
      
      if (kDebugMode) {
        print('NotificationService initialized with token: $_fcmToken');
      }
    } catch (e) {
      _error = e.toString();
      _isInitialized = false;
      
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateFCMToken(String userId) async {
    if (_fcmToken != null) {
      try {
        await _firestoreService.updateUserFCMToken(userId, _fcmToken!);
        if (kDebugMode) {
          print('FCM token updated for user: $userId');
        }
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}