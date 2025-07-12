import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Šahovska Aplikacija';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplikacija za komunikaciju sa članovima šahovskih klubova';

  // Package Info
  static const String androidPackageName = 'com.sahovskiklub.mobilnaapp';
  static const String iosPackageName = 'com.sahovskiklub.mobilnaapp';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';
  static const String adminStatsCollection = 'admin_stats';
  static const String userTokensCollection = 'user_tokens';

  // Notification Types
  static const String generalType = 'general';
  static const String tournamentType = 'tournament';
  static const String campType = 'camp';
  static const String trainingType = 'training';

  // FCM
  static const String fcmTopic = 'chess_club_notifications';
  static const String fcmChannelId = 'chess_club_channel';
  static const String fcmChannelName = 'Chess Club Notifications';
  static const String fcmChannelDescription = 'Notifications for chess club activities';

  // Shared Preferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String lastSyncKey = 'last_sync';
  static const String offlineNotificationsKey = 'offline_notifications';
  static const String userPreferencesKey = 'user_preferences';

  // Error Messages
  static const String networkErrorMessage = 'Proverite internet konekciju i pokušajte ponovo';
  static const String authErrorMessage = 'Greška pri autentifikaciji';
  static const String generalErrorMessage = 'Došlo je do greške. Pokušajte ponovo.';
  static const String noDataMessage = 'Nema podataka za prikaz';
  static const String loadingMessage = 'Učitavanje...';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNotificationTitleLength = 100;
  static const int maxNotificationContentLength = 1000;
  static const int maxDisplayNameLength = 50;

  // Pagination
  static const int notificationsPerPage = 20;
  static const int usersPerPage = 50;

  // Cache Duration
  static const Duration cacheExpiry = Duration(hours: 1);
  static const Duration offlineExpiry = Duration(days: 7);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Network Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration responseTimeout = Duration(seconds: 30);
}