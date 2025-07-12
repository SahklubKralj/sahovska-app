import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

import 'screens/auth/login_screen.dart';
import 'utils/app_logger.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/firestore_service.dart';
import 'services/connectivity_service.dart';
import 'services/offline_service.dart';
import 'providers/auth_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/notification_service_provider.dart';
import 'providers/offline_service_provider.dart';
import 'utils/app_theme.dart';
import 'widgets/offline_banner.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.notification('Background message received', message.messageId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicijalizacija NotificationService
  await NotificationService().initialize();
  
  // Initialize local notifications
  await _initializeLocalNotifications();
  
  // Setup Firebase messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _setupForegroundMessaging();
  
  // Handle initial notification if app was launched from terminated state
  _handleInitialMessage();
  
  runApp(MyApp());
}

void _handleInitialMessage() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    AppLogger.notification('App launched from notification', initialMessage.messageId);
    // Handle navigation after app is fully loaded
    Future.delayed(Duration(seconds: 2), () {
      final context = MyApp.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        NotificationService.handleNotificationNavigation(context, initialMessage.data);
      }
    });
  }
}

Future<void> _initializeLocalNotifications() async {
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

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onNotificationTap,
  );

  // Request permissions for iOS
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

void _setupForegroundMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    AppLogger.notification('Foreground message received', message.messageId);
    
    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'Novo obaveštenje',
        body: message.notification!.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  });
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
    showWhen: true,
    icon: '@mipmap/ic_launcher',
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

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    notificationDetails,
    payload: payload,
  );
}

void _onNotificationTap(NotificationResponse notificationResponse) {
  AppLogger.notification('Notification tapped', notificationResponse.id.toString());
  
  if (notificationResponse.payload != null) {
    try {
      final data = Map<String, dynamic>.from(
        jsonDecode(notificationResponse.payload!) as Map
      );
      
      // Use global navigator key or delayed navigation
      Future.delayed(Duration(milliseconds: 500), () {
        final context = MyApp.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          NotificationService.handleNotificationNavigation(context, data);
        }
      });
    } catch (e) {
      AppLogger.error('Error parsing notification payload', 'NOTIFICATION', e);
    }
  }
}


class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Get auth provider without listening to changes to avoid rebuild loops
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final loggedIn = authProvider.user != null;
      final isAdmin = authProvider.user?.isAdmin ?? false;
      final currentPath = state.uri.path;
      
      // Define route patterns
      final isLoginRoute = currentPath == '/login';
      final isRegisterRoute = currentPath == '/register';
      final isAdminRoute = currentPath == '/admin';
      final isHomeRoute = currentPath == '/home';
      final isRootRoute = currentPath == '/';
      
      AppLogger.debug('Router redirect: loggedIn=$loggedIn, isAdmin=$isAdmin, path=$currentPath', 'ROUTER');
      
      // If not logged in
      if (!loggedIn) {
        // Allow access to login and register pages
        if (isLoginRoute || isRegisterRoute) {
          return null; // No redirect needed
        }
        // Redirect everything else to login
        return '/login';
      }
      
      // If logged in
      if (loggedIn) {
        // Redirect from login/register to home
        if (isLoginRoute || isRegisterRoute) {
          return '/home';
        }
        
        // Redirect root to home
        if (isRootRoute) {
          return '/home';
        }
        
        // Admin route protection
        if (isAdminRoute && !isAdmin) {
          AppLogger.warning('Non-admin user trying to access admin route, redirecting to home', 'ROUTER');
          return '/home';
        }
      }
      
      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => AuthWrapper(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => AdminScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => NotificationsScreen(),
      ),
    ],
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: Text('Greška')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Stranica nije pronađena'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: Text('Nazad na početnu'),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        ChangeNotifierProvider(
          create: (context) => ConnectivityService()..initialize(),
        ),
        
        // Offline service
        ChangeNotifierProvider(
          create: (context) => OfflineServiceProvider(),
        ),
        
        // Notification service
        ChangeNotifierProvider(
          create: (context) {
            final notificationServiceProvider = NotificationServiceProvider(
              firestoreService: FirestoreService(),
            );
            return notificationServiceProvider;
          },
        ),
        
        // Auth provider
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService: AuthService(),
            firestoreService: FirestoreService(),
          ),
        ),
        
        // Notifications provider
        ChangeNotifierProvider(
          create: (context) => NotificationsProvider(
            firestoreService: FirestoreService(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Šahovska Aplikacija',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        builder: (context, child) {
          return OfflineBanner(child: child!);
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Učitavanje...'),
                ],
              ),
            ),
          );
        }
        
        // Since we have redirect logic in GoRouter, 
        // AuthWrapper should rarely be reached directly
        // But if it is, handle it gracefully
        if (authProvider.user == null) {
          // Redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // User is logged in, redirect to home
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
        
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}