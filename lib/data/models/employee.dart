import 'user.dart';

enum EmployeeStatus {
  active,
  onLeave,
  inactive;

  String get label {
    switch (this) {
      case EmployeeStatus.active:
        return 'Active';
      case EmployeeStatus.onLeave:
        return 'On Leave';
      case EmployeeStatus.inactive:
        return 'Inactive';
    }
  }

  static EmployeeStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'on_leave':
      case 'onleave':
        return EmployeeStatus.onLeave;
      case 'inactive':
        return EmployeeStatus.inactive;
      default:
        return EmployeeStatus.active;
    }
  }
}

class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String department;
  final EmployeeStatus status;
  final String joiningDate;
  final String? avatarUrl;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.status,
    required this.joiningDate,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'department': department,
      'status': status.name,
      'joiningDate': joiningDate,
      'avatarUrl': avatarUrl,
    };
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.fromString(json['role'] as String),
      department: json['department'] as String,
      status: EmployeeStatus.fromString(json['status'] as String),
      joiningDate: json['joiningDate'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? department,
    EmployeeStatus? status,
    String? joiningDate,
    String? avatarUrl,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      status: status ?? this.status,
      joiningDate: joiningDate ?? this.joiningDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
