import '../../core/network/api_client.dart';
import '../models/leave_request.dart';
import '../../domain/repositories/leave_repository.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final ApiClient _apiClient;

  LeaveRepositoryImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> getLeaveRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/leaves',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List rawData = response.data['data'] as List;
      final leaves = rawData.map((l) => LeaveRequestModel.fromJson(l as Map<String, dynamic>)).toList();
      final meta = response.data['meta'] as Map<String, dynamic>;

      return {
        'leaves': leaves,
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
  Future<LeaveRequestModel> applyForLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentName,
    String? attachmentPath,
  }) async {
    try {
      final response = await _apiClient.post(
        '/leaves',
        data: {
          'leaveType': leaveType,
          'startDate': startDate,
          'endDate': endDate,
          'reason': reason,
          if (attachmentName != null) 'attachmentName': attachmentName,
        },
      );
      return LeaveRequestModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LeaveRequestModel> approveLeave(String id, String? comment) async {
    try {
      final response = await _apiClient.patch(
        '/leaves/$id/approve',
        data: {if (comment != null) 'comment': comment},
      );
      return LeaveRequestModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LeaveRequestModel> rejectLeave(String id, String? comment) async {
    try {
      final response = await _apiClient.patch(
        '/leaves/$id/reject',
        data: {if (comment != null) 'comment': comment},
      );
      return LeaveRequestModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getLeaveBalances() async {
    
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'annual': 14,
      'sick': 6,
      'casual': 8,
    };
  }
}
