import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class FirebaseNotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseNotificationRepositoryImpl(this._firestore, this._firebaseAuth);

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('employeeId', isEqualTo: _currentUserId)
          .get();

      List<NotificationModel> notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).update({'isRead': true});
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
      final ref = _firestore.collection('notifications').doc();
      
      final employeesList = await _firestore.collection('employees').get();
      List<String> receivers = [];
      
      if (receiverId == 'All') {
        receivers = employeesList.docs.map((doc) => doc.id).toList();
      } else {
        receivers = [receiverId];
      }

      final batch = _firestore.batch();
      final nowStr = DateTime.now().toIso8601String();

      for (var recId in receivers) {
        final notifRef = _firestore.collection('notifications').doc();
        final data = NotificationModel(
          id: notifRef.id,
          employeeId: recId,
          title: title,
          message: message,
          type: NotificationType.fromString(type),
          isRead: false,
          createdAt: nowStr,
        );
        batch.set(notifRef, data.toJson());
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
