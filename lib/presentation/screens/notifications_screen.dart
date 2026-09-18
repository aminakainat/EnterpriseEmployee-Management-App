import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../data/models/notification.dart';
import '../../logic/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationStateProvider);
    final notifier = ref.read(notificationStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                for (final n in state.notifications) {
                  if (!n.isRead) notifier.markAsRead(n.id);
                }
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => ref.read(notificationStateProvider.notifier).loadNotifications(),
                  child: ListView.builder(
                    itemCount: state.notifications.length,
                    itemBuilder: (context, index) {
                      final notif = state.notifications[index];
                      return _buildNotificationTile(notif, notifier);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notif, NotificationNotifier notifier) {
    IconData icon = Icons.info_outline;
    Color color = AppColors.info;

    switch (notif.type) {
      case NotificationType.leave:
        icon = Icons.beach_access_outlined;
        color = AppColors.accent;
        break;
      case NotificationType.attendance:
        icon = Icons.access_time_outlined;
        color = AppColors.primaryLight;
        break;
      case NotificationType.security:
        icon = Icons.security;
        color = AppColors.error;
        break;
      case NotificationType.info:
      default:
        icon = Icons.info_outline;
        color = AppColors.info;
        break;
    }

    final dateText = DateFormat('MMM d, h:mm a').format(DateTime.parse(notif.createdAt));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: notif.isRead ? null : color.withOpacity(0.04),
      child: ListTile(
        onTap: () {
          if (!notif.isRead) notifier.markAsRead(notif.id);
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notif.message, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(dateText, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
          ],
        ),
        trailing: !notif.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppColors.lightTextSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('You have no new notifications.', style: TextStyle(color: AppColors.lightTextSecondary)),
        ],
      ),
    );
  }
}
