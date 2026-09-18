import '../../core/network/api_client.dart';
import '../models/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepositoryImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> getAttendanceHistory({
    int page = 1,
    int limit = 10,
    String? employeeId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/attendance',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (employeeId != null && employeeId.isNotEmpty) 'employeeId': employeeId,
        },
      );

      final List rawData = response.data['data'] as List;
      final logs = rawData.map((a) => AttendanceModel.fromJson(a as Map<String, dynamic>)).toList();
      final meta = response.data['meta'] as Map<String, dynamic>;

      return {
        'history': logs,
        'totalPages': meta['totalPages'] as int,
        'total': meta['total'] as int,
        'page': meta['page'] as int,
        'limit': meta['limit'] as int,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AttendanceModel?> getTodayStatus() async {
    try {
      final response = await _apiClient.get('/attendance/today');
      if (response.data == null) return null;
      return AttendanceModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AttendanceModel> checkIn({double? latitude, double? longitude}) async {
    try {
      final response = await _apiClient.post(
        '/attendance/check-in',
        data: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
      return AttendanceModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AttendanceModel> checkOut() async {
    try {
      final response = await _apiClient.post('/attendance/check-out');
      return AttendanceModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
