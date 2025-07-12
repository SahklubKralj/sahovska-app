import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../constants/app_constants.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Offline notifikacije
  Future<void> saveNotificationsOffline(List<NotificationModel> notifications) async {
    await initialize();
    
    try {
      // Konvertuj notifikacije u JSON
      List<Map<String, dynamic>> notificationsJson = notifications
          .map((notification) => {
                ...notification.toFirestore(),
                'id': notification.id,
              })
          .toList();

      String jsonString = jsonEncode(notificationsJson);
      await _prefs!.setString(AppConstants.offlineNotificationsKey, jsonString);
      
      // Sačuvaj timestamp kada su podaci poslednji put ažurirani
      await _prefs!.setString(AppConstants.lastSyncKey, DateTime.now().toIso8601String());
      
      print('Saved ${notifications.length} notifications offline');
    } catch (e) {
      print('Error saving notifications offline: $e');
    }
  }

  Future<List<NotificationModel>> getOfflineNotifications() async {
    await initialize();
    
    try {
      String? jsonString = _prefs!.getString(AppConstants.offlineNotificationsKey);
      if (jsonString == null) return [];

      List<dynamic> jsonList = jsonDecode(jsonString);
      List<NotificationModel> notifications = jsonList
          .map((json) => NotificationModel.fromFirestore(
              Map<String, dynamic>.from(json), 
              json['id'] ?? ''))
          .toList();

      // Proveri da li su podaci zastari
      String? lastSyncString = _prefs!.getString(AppConstants.lastSyncKey);
      if (lastSyncString != null) {
        DateTime lastSync = DateTime.parse(lastSyncString);
        DateTime now = DateTime.now();
        
        if (now.difference(lastSync) > AppConstants.offlineExpiry) {
          // Podaci su zastareli, obriši ih
          await clearOfflineNotifications();
          return [];
        }
      }

      print('Loaded ${notifications.length} notifications from offline storage');
      return notifications;
    } catch (e) {
      print('Error loading offline notifications: $e');
      return [];
    }
  }

  Future<void> clearOfflineNotifications() async {
    await initialize();
    await _prefs!.remove(AppConstants.offlineNotificationsKey);
    await _prefs!.remove(AppConstants.lastSyncKey);
  }

  // Proveri da li su offline podaci dostupni
  Future<bool> hasOfflineData() async {
    await initialize();
    return _prefs!.containsKey(AppConstants.offlineNotificationsKey);
  }

  // Dobij datum poslednje sinhronizacije
  Future<DateTime?> getLastSyncDate() async {
    await initialize();
    String? lastSyncString = _prefs!.getString(AppConstants.lastSyncKey);
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  // User preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await initialize();
    String jsonString = jsonEncode(preferences);
    await _prefs!.setString(AppConstants.userPreferencesKey, jsonString);
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    await initialize();
    String? jsonString = _prefs!.getString(AppConstants.userPreferencesKey);
    if (jsonString != null) {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    }
    return null;
  }

  // First launch flag
  Future<bool> isFirstLaunch() async {
    await initialize();
    bool isFirst = _prefs!.getBool(AppConstants.isFirstLaunchKey) ?? true;
    if (isFirst) {
      await _prefs!.setBool(AppConstants.isFirstLaunchKey, false);
    }
    return isFirst;
  }

  // Cache notification read status
  Future<void> markNotificationAsRead(String notificationId) async {
    await initialize();
    await _prefs!.setBool('notification_read_$notificationId', true);
  }

  Future<bool> isNotificationRead(String notificationId) async {
    await initialize();
    return _prefs!.getBool('notification_read_$notificationId') ?? false;
  }

  // Save draft notifications for admin
  Future<void> saveDraftNotification(Map<String, dynamic> draft) async {
    await initialize();
    String jsonString = jsonEncode(draft);
    await _prefs!.setString('draft_notification', jsonString);
  }

  Future<Map<String, dynamic>?> getDraftNotification() async {
    await initialize();
    String? jsonString = _prefs!.getString('draft_notification');
    if (jsonString != null) {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    }
    return null;
  }

  Future<void> clearDraftNotification() async {
    await initialize();
    await _prefs!.remove('draft_notification');
  }

  // Network status tracking
  Future<void> setLastOnlineTime() async {
    await initialize();
    await _prefs!.setString('last_online_time', DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastOnlineTime() async {
    await initialize();
    String? timeString = _prefs!.getString('last_online_time');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  // Clear all offline data
  Future<void> clearAllOfflineData() async {
    await initialize();
    await _prefs!.clear();
  }

  // Get storage usage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    await initialize();
    
    int notificationsCount = 0;
    DateTime? lastSync;
    bool hasPreferences = false;
    
    try {
      String? notificationsJson = _prefs!.getString(AppConstants.offlineNotificationsKey);
      if (notificationsJson != null) {
        List<dynamic> notifications = jsonDecode(notificationsJson);
        notificationsCount = notifications.length;
      }
      
      lastSync = await getLastSyncDate();
      hasPreferences = _prefs!.containsKey(AppConstants.userPreferencesKey);
      
    } catch (e) {
      print('Error getting storage info: $e');
    }

    return {
      'notificationsCount': notificationsCount,
      'lastSync': lastSync,
      'hasPreferences': hasPreferences,
      'totalKeys': _prefs!.getKeys().length,
    };
  }
}