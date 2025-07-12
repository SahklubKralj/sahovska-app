import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/social_login_buttons.dart';
import '../../widgets/image_picker_widget.dart';
import '../../utils/performance_utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    await _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Šahovska Aplikacija'),
            actions: [
              if (authProvider.isAdmin)
                IconButton(
                  icon: Icon(Icons.admin_panel_settings),
                  onPressed: () => context.go('/admin'),
                ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.signOut();
                    context.go('/login');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Odjavi se'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Email verification banner
              EmailVerificationBanner(),
              
              // User info header
              Container(
                padding: EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dobrodošli, ${authProvider.user?.displayName ?? 'Korisnik'}!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (authProvider.isAdmin)
                            Text(
                              'Administrator',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NotificationsList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, child) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Obaveštenja',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  PopupMenuButton<NotificationType?>(
                    icon: Icon(Icons.filter_list),
                    onSelected: (filter) {
                      notificationsProvider.setFilter(filter);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: null,
                        child: Text('Sve kategorije'),
                      ),
                      PopupMenuItem(
                        value: NotificationType.general,
                        child: Text('Opšte'),
                      ),
                      PopupMenuItem(
                        value: NotificationType.tournament,
                        child: Text('Turniri'),
                      ),
                      PopupMenuItem(
                        value: NotificationType.camp,
                        child: Text('Kampovi'),
                      ),
                      PopupMenuItem(
                        value: NotificationType.training,
                        child: Text('Treninzi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (notificationsProvider.selectedFilter != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Chip(
                      label: Text(_getFilterDisplayName(notificationsProvider.selectedFilter!)),
                      onDeleted: () => notificationsProvider.setFilter(null),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PullToRefreshIndicator(
                onRefresh: () async {
                  await PerformanceUtils.measureAsync(
                    'refresh_notifications',
                    () async {
                      await Future.delayed(Duration(seconds: 1));
                    },
                  );
                },
                child: Builder(
                  builder: (context) {
                    if (notificationsProvider.isLoadingFromOffline) {
                      return SkeletonList(
                        itemBuilder: () => SkeletonNotificationCard(),
                      );
                    }

                    if (notificationsProvider.notifications.isEmpty) {
                      return EmptyStateWidget(
                        title: 'Nema obaveštenja',
                        subtitle: 'Kada se objave nova obaveštenja, pojaviti će se ovde',
                        icon: Icons.notifications_none,
                      );
                    }

                    return PerformanceTracker(
                      name: 'notifications_list',
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notificationsProvider.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notificationsProvider.notifications[index];
                          return PerformanceTracker(
                            name: 'notification_card_$index',
                            child: NotificationCard(notification: notification),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getFilterDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'Opšte';
      case NotificationType.tournament:
        return 'Turniri';
      case NotificationType.camp:
        return 'Kampovi';
      case NotificationType.training:
        return 'Treninzi';
    }
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NotificationDetailsScreen(notification: notification),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      notification.typeDisplayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    _formatDate(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                notification.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 4),
              Text(
                notification.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              
              // Display images if available
              if (notification.imageUrls != null && notification.imageUrls!.isNotEmpty)
                Column(
                  children: [
                    UploadedImagesWidget(
                      imageUrls: notification.imageUrls!,
                      showDeleteButton: false,
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Colors.blue;
      case NotificationType.tournament:
        return Colors.orange;
      case NotificationType.camp:
        return Colors.green;
      case NotificationType.training:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailsScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalji obaveštenja'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(notification.type),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                notification.typeDisplayName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              notification.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 4),
                Text(
                  _formatDateTime(notification.createdAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              notification.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
            
            // Display images if available
            if (notification.imageUrls != null && notification.imageUrls!.isNotEmpty) ...[
              SizedBox(height: 24),
              UploadedImagesWidget(
                imageUrls: notification.imageUrls!,
                showDeleteButton: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Colors.blue;
      case NotificationType.tournament:
        return Colors.orange;
      case NotificationType.camp:
        return Colors.green;
      case NotificationType.training:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}