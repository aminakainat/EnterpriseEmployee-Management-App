enum LeaveType {
  annual,
  sick,
  casual;

  String get label {
    switch (this) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.casual:
        return 'Casual Leave';
    }
  }

  static LeaveType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'annual':
        return LeaveType.annual;
      case 'sick':
        return LeaveType.sick;
      case 'casual':
      default:
        return LeaveType.casual;
    }
  }
}

enum LeaveStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }

  static LeaveStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return LeaveStatus.pending;
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
      default:
        return LeaveStatus.rejected;
    }
  }
}

class LeaveRequestModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final LeaveType leaveType;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final String reason;
  final LeaveStatus status;
  final String appliedOn; // ISO String
  final String? reviewerName;
  final String? reviewerComment;
  final String? attachmentName;

  LeaveRequestModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.appliedOn,
    this.reviewerName,
    this.reviewerComment,
    this.attachmentName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'leaveType': leaveType.name,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'status': status.name,
      'appliedOn': appliedOn,
      'reviewerName': reviewerName,
      'reviewerComment': reviewerComment,
      'attachmentName': attachmentName,
    };
  }

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      leaveType: LeaveType.fromString(json['leaveType'] as String),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      reason: json['reason'] as String,
      status: LeaveStatus.fromString(json['status'] as String),
      appliedOn: json['appliedOn'] as String,
      reviewerName: json['reviewerName'] as String?,
      reviewerComment: json['reviewerComment'] as String?,
      attachmentName: json['attachmentName'] as String?,
    );
  }

  LeaveRequestModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    LeaveType? leaveType,
    String? startDate,
    String? endDate,
    String? reason,
    LeaveStatus? status,
    String? appliedOn,
    String? reviewerName,
    String? reviewerComment,
    String? attachmentName,
  }) {
    return LeaveRequestModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedOn: appliedOn ?? this.appliedOn,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerComment: reviewerComment ?? this.reviewerComment,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}
