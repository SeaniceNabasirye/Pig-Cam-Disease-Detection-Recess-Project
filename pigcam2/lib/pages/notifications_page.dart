import 'package:flutter/material.dart';
import 'package:pigcam2/components/common_app_bar.dart';
import 'package:pigcam2/models/notification_provider.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Notifications'),
      body: LiquidPullToRefresh(
        onRefresh: () => _handleRefresh(context),
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            if (notificationProvider.notifications.isEmpty) {
              return const Center(
                child: Text('No new notifications.'),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Clear All'),
                      onPressed: () {
                        notificationProvider.clearAllNotifications();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All notifications cleared.')),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: notificationProvider.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notificationProvider.notifications[index];
                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          notificationProvider.deleteNotification(notification.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Notification deleted.')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(notification.iconData ?? Icons.info, color: notification.isRead ? Colors.grey : Colors.blue),
                            title: Text(notification.title),
                            subtitle: Text(
                              '${notification.message} - ${notification.timestamp.toLocal().toString().split('.')[0]}',
                            ),
                            trailing: notification.imageBytes != null
                                ? const Icon(Icons.image)
                                : null,
                            onTap: () {
                              notificationProvider.toggleReadStatus(notification.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(notification.isRead ? 'Marked as unread.' : 'Marked as read.')),
                              );
                              if (notification.imageBytes != null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(notification.title),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(notification.message),
                                        const SizedBox(height: 10),
                                        Image.memory(notification.imageBytes!),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleRefresh(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
    // For demo, just rebuild
    (context as Element).markNeedsBuild();
  }
}

 