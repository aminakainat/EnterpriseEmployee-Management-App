import '../../core/network/api_client.dart';
import '../models/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');
      final List rawList = response.data as List;
      return rawList.map((n) => NotificationModel.fromJson(n as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.patch('/notifications/$id/read');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String message,
    required String receiverId,
    required String type,
  }) async {
    try {
      await _apiClient.post(
        '/notifications',
        data: {
          'title': title,
          'message': message,
          'employeeId': receiverId,
          'type': type,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
