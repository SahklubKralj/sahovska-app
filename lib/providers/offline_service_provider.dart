import 'package:flutter/foundation.dart';
import '../services/offline_service.dart';
import '../models/notification_model.dart';

class OfflineServiceProvider with ChangeNotifier {
  final OfflineService _offlineService = OfflineService();

  bool _isInitialized = false;
  bool _hasOfflineData = false;
  DateTime? _lastSyncDate;
  Map<String, dynamic>? _storageInfo;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get hasOfflineData => _hasOfflineData;
  DateTime? get lastSyncDate => _lastSyncDate;
  Map<String, dynamic>? get storageInfo => _storageInfo;
  String? get error => _error;

  OfflineServiceProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _offlineService.initialize();
      await _updateOfflineStatus();
      _isInitialized = true;
      _error = null;
      
      if (kDebugMode) {
        print('OfflineService initialized');
      }
    } catch (e) {
      _error = e.toString();
      _isInitialized = false;
      
      if (kDebugMode) {
        print('Error initializing OfflineService: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> _updateOfflineStatus() async {
    _hasOfflineData = await _offlineService.hasOfflineData();
    _lastSyncDate = await _offlineService.getLastSyncDate();
    _storageInfo = await _offlineService.getStorageInfo();
  }

  Future<void> saveNotificationsOffline(List<NotificationModel> notifications) async {
    try {
      await _offlineService.saveNotificationsOffline(notifications);
      await _updateOfflineStatus();
      notifyListeners();
      
      if (kDebugMode) {
        print('Saved ${notifications.length} notifications offline');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<NotificationModel>> getOfflineNotifications() async {
    try {
      final notifications = await _offlineService.getOfflineNotifications();
      
      if (kDebugMode) {
        print('Retrieved ${notifications.length} notifications from offline storage');
      }
      
      return notifications;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> clearOfflineData() async {
    try {
      await _offlineService.clearOfflineNotifications();
      await _updateOfflineStatus();
      notifyListeners();
      
      if (kDebugMode) {
        print('Cleared offline data');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _offlineService.saveUserPreferences(preferences);
      
      if (kDebugMode) {
        print('Saved user preferences');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      return await _offlineService.getUserPreferences();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> saveDraftNotification(Map<String, dynamic> draft) async {
    try {
      await _offlineService.saveDraftNotification(draft);
      
      if (kDebugMode) {
        print('Saved draft notification');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getDraftNotification() async {
    try {
      return await _offlineService.getDraftNotification();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> clearDraftNotification() async {
    try {
      await _offlineService.clearDraftNotification();
      
      if (kDebugMode) {
        print('Cleared draft notification');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _offlineService.markNotificationAsRead(notificationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> isNotificationRead(String notificationId) async {
    try {
      return await _offlineService.isNotificationRead(notificationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> isFirstLaunch() async {
    try {
      return await _offlineService.isFirstLaunch();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> setLastOnlineTime() async {
    try {
      await _offlineService.setLastOnlineTime();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<DateTime?> getLastOnlineTime() async {
    try {
      return await _offlineService.getLastOnlineTime();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshStorageInfo() async {
    await _updateOfflineStatus();
    notifyListeners();
  }
}