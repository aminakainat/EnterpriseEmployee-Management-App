enum NotificationType {
  leave,
  attendance,
  info,
  security;

  String get label {
    switch (this) {
      case NotificationType.leave:
        return 'Leave';
      case NotificationType.attendance:
        return 'Attendance';
      case NotificationType.info:
        return 'Info';
      case NotificationType.security:
        return 'Security';
    }
  }

  static NotificationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'leave':
        return NotificationType.leave;
      case 'attendance':
        return NotificationType.attendance;
      case 'security':
        return NotificationType.security;
      case 'info':
      default:
        return NotificationType.info;
    }
  }
}

class NotificationModel {
  final String id;
  final String employeeId; // Target user
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromString(json['type'] as String),
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? employeeId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
