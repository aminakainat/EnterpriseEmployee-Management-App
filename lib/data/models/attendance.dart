enum AttendanceStatus {
  present,
  late,
  absent;

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }

  static AttendanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      case 'absent':
      default:
        return AttendanceStatus.absent;
    }
  }
}

class AttendanceModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String date; // YYYY-MM-DD
  final String checkIn; // ISO String
  final String? checkOut; // ISO String
  final double? workingHours;
  final AttendanceStatus status;
  final double? latitude;
  final double? longitude;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    this.checkOut,
    this.workingHours,
    required this.status,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'workingHours': workingHours,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      date: json['date'] as String,
      checkIn: json['checkIn'] as String,
      checkOut: json['checkOut'] as String?,
      workingHours: json['workingHours'] != null ? (json['workingHours'] as num).toDouble() : null,
      status: AttendanceStatus.fromString(json['status'] as String),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? date,
    String? checkIn,
    String? checkOut,
    double? workingHours,
    AttendanceStatus? status,
    double? latitude,
    double? longitude,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      workingHours: workingHours ?? this.workingHours,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
