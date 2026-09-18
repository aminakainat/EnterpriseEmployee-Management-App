import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart';
import '../../domain/repositories/employee_repository.dart';

class FirebaseEmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseFirestore _firestore;

  FirebaseEmployeeRepositoryImpl(this._firestore);

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
      Query query = _firestore.collection('employees');

      if (department != null && department.isNotEmpty && department != 'All') {
        query = query.where('department', isEqualTo: department);
      }
      if (role != null && role.isNotEmpty && role != 'All') {
        query = query.where('role', isEqualTo: role.toLowerCase());
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.where('status', isEqualTo: status);
      }
      final snapshot = await query.get();
      List<EmployeeModel> employees = snapshot.docs
          .map((doc) => EmployeeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

   
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        employees = employees.where((e) {
          return e.name.toLowerCase().contains(q) || e.email.toLowerCase().contains(q);
        }).toList();
      }

      final total = employees.length;
      final totalPages = (total / limit).ceil();
      final startIndex = (page - 1) * limit;
      
      List<EmployeeModel> paginatedList = [];
      if (startIndex < total) {
        final endIndex = startIndex + limit;
        paginatedList = employees.sublist(
          startIndex,
          endIndex > total ? total : endIndex,
        );
      }

      return {
        'employees': paginatedList,
        'totalPages': totalPages,
        'total': total,
        'page': page,
        'limit': limit,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    try {
      
      final docRef = _firestore.collection('employees').doc();
      final employeeWithId = employee.copyWith(id: docRef.id);
      
      await docRef.set(employeeWithId.toJson());
      
      await _firestore.collection('users').doc(docRef.id).set({
        'id': docRef.id,
        'email': employee.email,
        'name': employee.name,
        'role': employee.role.name,
        'department': employee.department,
        'avatarUrl': employee.avatarUrl,
      });

      return employeeWithId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmployeeModel> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('employees').doc(id).update(data);
     
      final Map<String, dynamic> userUpdates = {};
      if (data.containsKey('role')) userUpdates['role'] = data['role'];
      if (data.containsKey('name')) userUpdates['name'] = data['name'];
      if (data.containsKey('status')) userUpdates['isActive'] = data['status'] == 'active';
      
      if (userUpdates.isNotEmpty) {
        await _firestore.collection('users').doc(id).update(userUpdates);
      }

      final doc = await _firestore.collection('employees').doc(id).get();
      return EmployeeModel.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      await _firestore.collection('employees').doc(id).delete();
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
