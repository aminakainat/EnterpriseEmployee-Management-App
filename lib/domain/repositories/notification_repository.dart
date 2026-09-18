import '../../data/models/notification.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> sendNotification({
    required String title,
    required String message,
    required String receiverId,
    required String type,
  });
}
