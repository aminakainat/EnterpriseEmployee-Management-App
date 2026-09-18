import '../../core/network/api_client.dart';
import '../models/employee.dart';
import '../../domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final ApiClient _apiClient;

  EmployeeRepositoryImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> getEmployees({
    int page = 1,
    int limit = 10,
    String? search,
    String? department,
    String? role,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        '/employees',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (department != null && department.isNotEmpty) 'department': department,
          if (role != null && role.isNotEmpty) 'role': role,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      final List rawData = response.data['data'] as List;
      final employees = rawData.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
      final meta = response.data['meta'] as Map<String, dynamic>;

      return {
        'employees': employees,
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
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    try {
      final response = await _apiClient.post(
        '/employees',
        data: employee.toJson(),
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmployeeModel> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '/employees/$id',
        data: data,
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      await _apiClient.delete('/employees/$id');
    } catch (e) {
      rethrow;
    }
  }
}
