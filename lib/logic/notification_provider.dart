import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/notification.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../data/repositories/firebase_notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import 'auth_provider.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  NotificationState({
    required this.notifications,
    required this.isLoading,
    this.errorMessage,
  });

  factory NotificationState.initial() {
    return NotificationState(notifications: [], isLoading: false);
  }

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final useFirebase = ref.watch(firebaseBackendProvider);
  if (useFirebase && Firebase.apps.isNotEmpty) {
    return FirebaseNotificationRepositoryImpl(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  } else {
    final apiClient = ref.watch(apiClientProvider);
    return NotificationRepositoryImpl(apiClient);
  }
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  Timer? _pollingTimer;

  NotificationNotifier(this._repository) : super(NotificationState.initial()) {
    loadNotifications();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadNotifications(silent: true);
    });
  }

  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final notifications = await _repository.getNotifications();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      if (!silent) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);

      final updated = state.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      state = state.copyWith(notifications: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> sendBroadcastNotification({
    required String title,
    required String message,
    required String receiverId,
    required NotificationType type,
  }) async {
    try {
      await _repository.sendNotification(
        title: title,
        message: message,
        receiverId: receiverId,
        type: type.name,
      );
      await loadNotifications(silent: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  int get unreadCount {
    return state.notifications.where((n) => !n.isRead).length;
  }
}

final notificationStateProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationNotifier(repository);
    });
