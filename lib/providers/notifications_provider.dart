import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';
import '../services/offline_service.dart';
import '../services/connectivity_service.dart';

class NotificationsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final OfflineService _offlineService = OfflineService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  NotificationType? _selectedFilter;
  bool _isLoadingFromOffline = false;

  NotificationsProvider({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService {
    _initializeNotifications();
  }

  List<NotificationModel> get notifications {
    if (_selectedFilter == null) {
      return _notifications;
    }
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  NotificationType? get selectedFilter => _selectedFilter;

  void _initializeNotifications() async {
    await _connectivityService.initialize();
    
    // Prvo učitaj offline podatke ako postoje
    await _loadOfflineNotifications();
    
    // Zatim pokušaj da učitaš online podatke
    if (_connectivityService.isOnline) {
      _loadOnlineNotifications();
    }
    
    // Slušaj promene konekcije
    _connectivityService.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (_connectivityService.isOnline) {
      _loadOnlineNotifications();
    }
  }

  Future<void> _loadOfflineNotifications() async {
    try {
      _isLoadingFromOffline = true;
      notifyListeners();
      
      List<NotificationModel> offlineNotifications = await _offlineService.getOfflineNotifications();
      
      if (offlineNotifications.isNotEmpty) {
        _notifications = offlineNotifications;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading offline notifications: $e');
    } finally {
      _isLoadingFromOffline = false;
      notifyListeners();
    }
  }

  void _loadOnlineNotifications() {
    _firestoreService.getNotifications().listen(
      (notifications) async {
        _notifications = notifications;
        _error = null;
        
        // Sačuvaj notifikacije offline
        await _offlineService.saveNotificationsOffline(notifications);
        
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createNotification({
    required String title,
    required String content,
    required NotificationType type,
    required String createdBy,
    List<String>? imageUrls,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      NotificationModel notification = NotificationModel(
        id: '', // Will be set by Firestore
        title: title,
        content: content,
        type: type,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        imageUrls: imageUrls,
      );

      if (_connectivityService.isOnline) {
        await _firestoreService.createNotification(notification);
      } else {
        // Sačuvaj kao draft ako si offline
        await _offlineService.saveDraftNotification({
          'title': title,
          'content': content,
          'type': type.toString().split('.').last,
          'createdBy': createdBy,
          'imageUrls': imageUrls,
          'createdAt': DateTime.now().toIso8601String(),
        });
        _error = 'Obaveštenje je sačuvano kao draft. Biće objavljeno kada se povežete na internet.';
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateNotification(NotificationModel notification) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateNotification(notification);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alias za createNotification sa jasnijem nazivom
  Future<bool> createNotificationWithImages({
    required String title,
    required String content,
    required NotificationType type,
    required String createdBy,
    List<String>? imageUrls,
  }) async {
    return await createNotification(
      title: title,
      content: content,
      type: type,
      createdBy: createdBy,
      imageUrls: imageUrls,
    );
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteNotification(notificationId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(NotificationType? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Offline specific methods
  bool get isLoadingFromOffline => _isLoadingFromOffline;
  
  bool get hasOfflineData => _notifications.isNotEmpty && !_connectivityService.isOnline;

  Future<DateTime?> getLastSyncDate() async {
    return await _offlineService.getLastSyncDate();
  }

  Future<Map<String, dynamic>?> getDraftNotification() async {
    return await _offlineService.getDraftNotification();
  }

  Future<void> clearDraftNotification() async {
    await _offlineService.clearDraftNotification();
  }

  Future<bool> publishDraftNotification() async {
    if (!_connectivityService.isOnline) {
      _error = 'Potrebna je internet konekcija za objavljivanje';
      notifyListeners();
      return false;
    }

    try {
      Map<String, dynamic>? draft = await getDraftNotification();
      if (draft == null) return false;

      NotificationType type = NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == draft['type'],
        orElse: () => NotificationType.general,
      );

      bool success = await createNotification(
        title: draft['title'],
        content: draft['content'],
        type: type,
        createdBy: draft['createdBy'],
        imageUrls: draft['imageUrls'] != null 
            ? List<String>.from(draft['imageUrls']) 
            : null,
      );

      if (success) {
        await clearDraftNotification();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}