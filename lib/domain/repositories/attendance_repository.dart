import '../../data/models/attendance.dart';

abstract class AttendanceRepository {
  Future<Map<String, dynamic>> getAttendanceHistory({
    int page = 1,
    int limit = 10,
    String? employeeId,
  });
  Future<AttendanceModel?> getTodayStatus();
  Future<AttendanceModel> checkIn({double? latitude, double? longitude});
  Future<AttendanceModel> checkOut();
}
