import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Callback for FCM token updates
  Function(String)? onTokenRefresh;
  
  // Navigation callback
  Function(BuildContext, Map<String, dynamic>)? onNotificationTap;

  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.notification('User granted permission');
    } else {
      AppLogger.warning('User declined or has not accepted permission', 'NOTIFICATION');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Listen for FCM token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      AppLogger.notification('FCM Token refreshed');
      onTokenRefresh?.call(token);
    });
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      AppLogger.notification('FCM Token retrieved');
      return token;
    } catch (e) {
      AppLogger.error('Error getting FCM token', 'NOTIFICATION', e);
      return null;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.notification('Foreground message received', message.messageId);
    
    _showLocalNotification(
      title: message.notification?.title ?? 'Novo obaveštenje',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.notification('Background message clicked', message.messageId);
    _handleNotificationNavigation(message.data);
  }

  void _onNotificationTap(NotificationResponse notificationResponse) {
    AppLogger.notification('Local notification tapped', notificationResponse.id.toString());
    
    if (notificationResponse.payload != null) {
      try {
        final data = jsonDecode(notificationResponse.payload!);
        _handleNotificationNavigation(data);
      } catch (e) {
        AppLogger.error('Error parsing notification payload', 'NOTIFICATION', e);
        _handleNotificationNavigation({});
      }
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // This will be called by the main app with proper context
    if (onNotificationTap != null) {
      // Delay to ensure app is ready
      Future.delayed(Duration(milliseconds: 500), () {
        // Context will be provided by the app
        // onNotificationTap?.call(context, data);
      });
    }
  }

  /// Set up navigation callback
  void setNotificationTapCallback(Function(BuildContext, Map<String, dynamic>) callback) {
    onNotificationTap = callback;
  }

  /// Set up FCM token refresh callback
  void setTokenRefreshCallback(Function(String) callback) {
    onTokenRefresh = callback;
  }

  /// Handle notification navigation with context
  static void handleNotificationNavigation(BuildContext context, Map<String, dynamic> data) {
    final notificationId = data['notificationId'] as String?;
    final type = data['type'] as String?;
    final action = data['action'] as String?;

    if (context.mounted) {
      if (action == 'open_admin' && notificationId != null) {
        context.go('/admin');
      } else if (notificationId != null) {
        // Navigate to notification details
        context.go('/notifications');
      } else {
        // Default navigation to home
        context.go('/home');
      }
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'chess_club_channel',
      'Chess Club Notifications',
      channelDescription: 'Notifications for chess club activities',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}