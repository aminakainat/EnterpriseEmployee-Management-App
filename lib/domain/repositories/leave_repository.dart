import '../../data/models/leave_request.dart';

abstract class LeaveRepository {
  Future<Map<String, dynamic>> getLeaveRequests({
    int page = 1,
    int limit = 10,
  });
  Future<LeaveRequestModel> applyForLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentName,
    String? attachmentPath,
  });
  Future<LeaveRequestModel> approveLeave(String id, String? comment);
  Future<LeaveRequestModel> rejectLeave(String id, String? comment);
  Future<Map<String, int>> getLeaveBalances();
}
