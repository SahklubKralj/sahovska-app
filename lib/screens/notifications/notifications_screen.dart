import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification_model.dart';
import '../home/home_screen.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sve obaveštenja'),
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notificationsProvider, child) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ukupno: ${notificationsProvider.notifications.length} obaveštenja',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
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
                child: notificationsProvider.notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nema obaveštenja',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notificationsProvider.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notificationsProvider.notifications[index];
                          return NotificationCard(notification: notification);
                        },
                      ),
              ),
            ],
          );
        },
      ),
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