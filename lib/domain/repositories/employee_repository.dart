import '../../data/models/employee.dart';

abstract class EmployeeRepository {
  Future<Map<String, dynamic>> getEmployees({
    int page = 1,
    int limit = 10,
    String? search,
    String? department,
    String? role,
    String? status,
  });
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel> updateEmployee(String id, Map<String, dynamic> data);
  Future<void> deleteEmployee(String id);
}
