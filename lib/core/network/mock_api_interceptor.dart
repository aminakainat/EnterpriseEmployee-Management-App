import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/constants.dart';

class MockApiInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  MockApiInterceptor(this._prefs) {
    _initializeMockDatabase();
  }
  void _initializeMockDatabase() {
    final isInitialized =
        _prefs.getBool(AppConstants.mockDbInitializedKey) ?? false;
    if (!isInitialized) {
      final defaultEmployees = [
        {
          'id': 'emp-admin-1',
          'name': 'Sarah Jenkins',
          'email': 'admin@enterprise.com',
          'phone': '+1 (555) 019-2834',
          'role': 'admin',
          'department': 'HR',
          'status': 'active',
          'joiningDate': '2023-01-15',
          'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Sarah',
        },
        {
          'id': 'emp-manager-1',
          'name': 'Michael Chen',
          'email': 'manager@enterprise.com',
          'phone': '+1 (555) 014-9876',
          'role': 'manager',
          'department': 'Engineering',
          'status': 'active',
          'joiningDate': '2023-06-10',
          'avatarUrl':
              'https://api.dicebear.com/7.x/adventurer/png?seed=Michael',
        },
        {
          'id': 'emp-employee-1',
          'name': 'Alex Rivera',
          'email': 'employee@enterprise.com',
          'phone': '+1 (555) 012-3456',
          'role': 'employee',
          'department': 'Design',
          'status': 'active',
          'joiningDate': '2024-02-01',
          'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Alex',
        },
        {
          'id': 'emp-4',
          'name': 'Emily Watson',
          'email': 'emily@enterprise.com',
          'phone': '+1 (555) 018-7654',
          'role': 'employee',
          'department': 'Finance',
          'status': 'active',
          'joiningDate': '2023-11-20',
          'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Emily',
        },
        {
          'id': 'emp-5',
          'name': 'David Kim',
          'email': 'david@enterprise.com',
          'phone': '+1 (555) 013-4567',
          'role': 'employee',
          'department': 'Engineering',
          'status': 'onLeave',
          'joiningDate': '2023-08-15',
          'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=David',
        },
        {
          'id': 'emp-6',
          'name': 'Jessica Taylor',
          'email': 'jessica@enterprise.com',
          'phone': '+1 (555) 017-8901',
          'role': 'manager',
          'department': 'HR',
          'status': 'active',
          'joiningDate': '2022-04-12',
          'avatarUrl':
              'https://api.dicebear.com/7.x/adventurer/png?seed=Jessica',
        },
        {
          'id': 'emp-7',
          'name': 'Daniel Martinez',
          'email': 'daniel@enterprise.com',
          'phone': '+1 (555) 016-7890',
          'role': 'employee',
          'department': 'Sales',
          'status': 'active',
          'joiningDate': '2024-01-10',
          'avatarUrl':
              'https://api.dicebear.com/7.x/adventurer/png?seed=Daniel',
        },
        {
          'id': 'emp-8',
          'name': 'Rachel Green',
          'email': 'rachel@enterprise.com',
          'phone': '+1 (555) 015-6789',
          'role': 'employee',
          'department': 'Operations',
          'status': 'inactive',
          'joiningDate': '2023-03-22',
          'avatarUrl':
              'https://api.dicebear.com/7.x/adventurer/png?seed=Rachel',
        },
        {
          'id': 'emp-9',
          'name': 'Chris Evans',
          'email': 'chris@enterprise.com',
          'phone': '+1 (555) 011-2345',
          'role': 'employee',
          'department': 'Design',
          'status': 'active',
          'joiningDate': '2023-09-01',
          'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Chris',
        },
        {
          'id': 'emp-10',
          'name': 'Sophia Patel',
          'email': 'sophia@enterprise.com',
          'phone': '+1 (555) 019-8765',
          'role': 'manager',
          'department': 'Finance',
          'status': 'active',
          'joiningDate': '2022-10-05',
          'avatarUrl':
              'https://api.dicebear.com/7.x/adventurer/png?seed=Sophia',
        },
        {
          'id': 'emp-11',
          'name': 'Thomas Shelby',
          'email': 'thomas@enterprise.com',
          'phone': '+1 (555) 012-8888',
          'role': 'employee',
          'department': 'Operations',
          'status': 'active',
          'joiningDate': '2022-01-01',
          'avatarUrl':
              'https://api.dicebear.com/7.x/adventurer/png?seed=Thomas',
        },
      ];

      final defaultLeaves = [
        {
          'id': 'leave-1',
          'employeeId': 'emp-employee-1',
          'employeeName': 'Alex Rivera',
          'leaveType': 'annual',
          'startDate': '2026-07-15',
          'endDate': '2026-07-20',
          'reason': 'Summer family trip',
          'status': 'pending',
          'appliedOn': '2026-07-09T14:30:00.000Z',
          'reviewerName': null,
          'reviewerComment': null,
          'attachmentName': 'flight_tickets.pdf',
        },
        {
          'id': 'leave-2',
          'employeeId': 'emp-5',
          'employeeName': 'David Kim',
          'leaveType': 'sick',
          'startDate': '2026-07-10',
          'endDate': '2026-07-12',
          'reason': 'Dental surgery recovery',
          'status': 'approved',
          'appliedOn': '2026-07-08T09:15:00.000Z',
          'reviewerName': 'Sarah Jenkins',
          'reviewerComment': 'Approved. Take rest.',
          'attachmentName': 'medical_certificate.pdf',
        },
      ];

      final defaultAttendance = [
        {
          'id': 'att-1',
          'employeeId': 'emp-employee-1',
          'employeeName': 'Alex Rivera',
          'date': '2026-07-09',
          'checkIn': '2026-07-09T08:58:30.000Z',
          'checkOut': '2026-07-09T17:05:00.000Z',
          'workingHours': 8.1,
          'status': 'present',
          'latitude': 37.7749,
          'longitude': -122.4194,
        },
        {
          'id': 'att-2',
          'employeeId': 'emp-employee-1',
          'employeeName': 'Alex Rivera',
          'date': '2026-07-08',
          'checkIn': '2026-07-08T09:15:00.000Z',
          'checkOut': '2026-07-08T17:00:00.000Z',
          'workingHours': 7.75,
          'status': 'late',
          'latitude': 37.7750,
          'longitude': -122.4190,
        },
      ];

      final defaultNotifications = [
        {
          'id': 'notif-1',
          'employeeId': 'emp-employee-1',
          'title': 'Leave Approved',
          'message':
              'Your sick leave request for 2026-07-10 has been approved.',
          'type': 'leave',
          'isRead': false,
          'createdAt': '2026-07-09T10:00:00.000Z',
        },
        {
          'id': 'notif-2',
          'employeeId': 'emp-employee-1',
          'title': 'Welcome to Enterprise Nexus',
          'message':
              'Welcome to the team! View the employee directory to connect.',
          'type': 'info',
          'isRead': true,
          'createdAt': '2026-07-01T08:00:00.000Z',
        },
      ];

      _prefs.setString(
        AppConstants.mockEmployeesKey,
        jsonEncode(defaultEmployees),
      );
      _prefs.setString(AppConstants.mockLeavesKey, jsonEncode(defaultLeaves));
      _prefs.setString(
        AppConstants.mockAttendanceKey,
        jsonEncode(defaultAttendance),
      );
      _prefs.setString(
        AppConstants.mockNotificationsKey,
        jsonEncode(defaultNotifications),
      );
      _prefs.setBool(AppConstants.mockDbInitializedKey, true);
    }
  }

  Map<String, dynamic>? _validateAuthToken(RequestOptions options) {
    final authHeader = options.headers['Authorization'] as String?;
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    final token = authHeader.substring(7);
    if (token == 'mock_expired_token') return null;

    if (token.startsWith('jwt_access_token_')) {
      final empId = token.replaceFirst('jwt_access_token_', '');
      final employeesRaw = _prefs.getString(AppConstants.mockEmployeesKey);
      if (employeesRaw != null) {
        final List employees = jsonDecode(employeesRaw);
        final user = employees.firstWhere(
          (e) => e['id'] == empId,
          orElse: () => null,
        );
        return user;
      }
    }
    return null;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final fullUri = options.uri.toString();
    if (!fullUri.startsWith(AppConstants.apiBaseUrl)) {
      return super.onRequest(options, handler);
    }

    await Future.delayed(const Duration(milliseconds: 600));

    final path = options.path;
    final method = options.method.toUpperCase();

    try {
      if (path == '/auth/login' && method == 'POST') {
        final body = options.data as Map<String, dynamic>;
        final email = body['email'] as String?;
        final password = body['password'] as String?;

        if (email == null || password == null || password.length < 6) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 422,
              data: {
                'message':
                    'Invalid credentials. Password must be at least 6 characters.',
              },
            ),
          );
          return;
        }

        final employeesRaw = _prefs.getString(AppConstants.mockEmployeesKey)!;
        final List employees = jsonDecode(employeesRaw);
        final user = employees.firstWhere(
          (e) => e['email'] == email,
          orElse: () => null,
        );

        if (user == null) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 401,
              data: {
                'message': 'User not found. Please try admin@enterprise.com.',
              },
            ),
          );
          return;
        }

        final empId = user['id'];
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'accessToken': 'jwt_access_token_$empId',
              'refreshToken': 'jwt_refresh_token_$empId',
              'user': user,
            },
          ),
        );
        return;
      }

      if (path == '/auth/refresh' && method == 'POST') {
        final body = options.data as Map<String, dynamic>;
        final refreshToken = body['refreshToken'] as String?;

        if (refreshToken != null &&
            refreshToken.startsWith('jwt_refresh_token_')) {
          final empId = refreshToken.replaceFirst('jwt_refresh_token_', '');
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'accessToken': 'jwt_access_token_$empId',
                'refreshToken': 'jwt_refresh_token_$empId',
              },
            ),
          );
        } else {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 401,
              data: {'message': 'Invalid or expired refresh token.'},
            ),
          );
        }
        return;
      }

      if (path == '/auth/register' && method == 'POST') {
        final body = options.data as Map<String, dynamic>;
        final email = body['email'] as String?;
        final password = body['password'] as String?;
        final name = body['name'] as String?;
        final phone = body['phone'] as String? ?? '';
        final department = body['department'] as String? ?? 'Engineering';

        if (email == null ||
            password == null ||
            password.length < 6 ||
            name == null) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 422,
              data: {
                'message':
                    'Invalid details. Password must be at least 6 characters, and name is required.',
              },
            ),
          );
          return;
        }

        final employeesRaw = _prefs.getString(AppConstants.mockEmployeesKey)!;
        final List employees = jsonDecode(employeesRaw);

        final existing = employees.firstWhere(
          (e) => e['email'] == email,
          orElse: () => null,
        );
        if (existing != null) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 409,
              data: {'message': 'Email address is already in use.'},
            ),
          );
          return;
        }

        final newEmpId = 'emp-${_uuid.v4().substring(0, 8)}';
        final newEmployee = {
          'id': newEmpId,
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'employee',
          'department': department,
          'status': 'active',
          'joiningDate': DateTime.now().toIso8601String().substring(0, 10),
          'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=$name',
        };

        employees.add(newEmployee);
        await _prefs.setString(
          AppConstants.mockEmployeesKey,
          jsonEncode(employees),
        );

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 201,
            data: {
              'accessToken': 'jwt_access_token_$newEmpId',
              'refreshToken': 'jwt_refresh_token_$newEmpId',
              'user': newEmployee,
            },
          ),
        );
        return;
      }

      final currentUser = _validateAuthToken(options);
      if (currentUser == null) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 401,
            data: {'message': 'Unauthorized. Invalid or expired token.'},
          ),
        );
        return;
      }

      final currentRole = currentUser['role'] as String;
      final currentUserId = currentUser['id'] as String;

      if (path == '/employees' && method == 'GET') {
        final queryParams = options.queryParameters;
        final search = queryParams['search'] as String?;
        final department = queryParams['department'] as String?;
        final role = queryParams['role'] as String?;
        final status = queryParams['status'] as String?;
        final page = int.tryParse(queryParams['page']?.toString() ?? '1') ?? 1;
        final limit =
            int.tryParse(queryParams['limit']?.toString() ?? '10') ?? 10;

        final employeesRaw = _prefs.getString(AppConstants.mockEmployeesKey)!;
        List employees = jsonDecode(employeesRaw);

        if (search != null && search.isNotEmpty) {
          final query = search.toLowerCase();
          employees = employees.where((e) {
            final name = (e['name'] as String).toLowerCase();
            final email = (e['email'] as String).toLowerCase();
            return name.contains(query) || email.contains(query);
          }).toList();
        }

        if (department != null &&
            department.isNotEmpty &&
            department != 'All') {
          employees = employees
              .where((e) => e['department'] == department)
              .toList();
        }

        if (role != null && role.isNotEmpty && role != 'All') {
          employees = employees
              .where((e) => e['role'] == role.toLowerCase())
              .toList();
        }

        if (status != null && status.isNotEmpty && status != 'All') {
          employees = employees.where((e) => e['status'] == status).toList();
        }

        final total = employees.length;
        final totalPages = (total / limit).ceil();
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;

        List paginatedList = [];
        if (startIndex < total) {
          paginatedList = employees.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );
        }

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'data': paginatedList,
              'meta': {
                'total': total,
                'page': page,
                'limit': limit,
                'totalPages': totalPages,
              },
            },
          ),
        );
        return;
      }

      if (path == '/employees' && method == 'POST') {
        if (currentRole != 'admin') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 403,
              data: {
                'message':
                    'Forbidden. Only administrators can perform this action.',
              },
            ),
          );
          return;
        }

        final body = options.data as Map<String, dynamic>;
        final newId = 'emp-${_uuid.v4().substring(0, 8)}';
        final newEmployee = {
          'id': newId,
          'name': body['name'],
          'email': body['email'],
          'phone': body['phone'] ?? '',
          'role': body['role'] ?? 'employee',
          'department': body['department'] ?? 'IT',
          'status': body['status'] ?? 'active',
          'joiningDate':
              body['joiningDate'] ??
              DateTime.now().toIso8601String().substring(0, 10),
          'avatarUrl':
              body['avatarUrl'] ??
              'https://api.dicebear.com/7.x/adventurer/png?seed=${body['name']}',
        };

        final employeesRaw = _prefs.getString(AppConstants.mockEmployeesKey)!;
        final List employees = jsonDecode(employeesRaw);
        employees.add(newEmployee);
        await _prefs.setString(
          AppConstants.mockEmployeesKey,
          jsonEncode(employees),
        );

        handler.resolve(
          Response(requestOptions: options, statusCode: 201, data: newEmployee),
        );
        return;
      }

      if (path.startsWith('/employees/') && method == 'PUT') {
        final segments = path.split('/');
        final targetId = segments.last;

        if (currentRole != 'admin' && currentUserId != targetId) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 403,
              data: {
                'message':
                    'Forbidden. You do not have permissions to modify this profile.',
              },
            ),
          );
          return;
        }

        final body = options.data as Map<String, dynamic>;
        final employeesRaw = _prefs.getString(AppConstants.mockEmployeesKey)!;
        final List employees = jsonDecode(employeesRaw);

        final index = employees.indexWhere((e) => e['id'] == targetId);
        if (index == -1) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 404,
              data: {'message': 'Employee not found.'},
            ),
          );
          return;
        }

        final existing = employees[index] as Map<String, dynamic>;
        final updatedEmployee = {
          ...existing,
          if (body.containsKey('name')) 'name': body['name'],
          if (body.containsKey('phone')) 'phone': body['phone'],
          if (body.containsKey('department') && currentRole == 'admin')
            'department': body['department'],
          if (body.containsKey('role') && currentRole == 'admin')
            'role': body['role'],
          if (body.containsKey('status') && currentRole == 'admin')
            'status': body['status'],
          if (body.containsKey('avatarUrl')) 'avatarUrl': body['avatarUrl'],
        };

        employees[index] = updatedEmployee;
        await _prefs.setString(
          AppConstants.mockEmployeesKey,
          jsonEncode(employees),
        );

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: updatedEmployee,
          ),
        );
        return;
      }

      if (path.startsWith('/employees/') && method == 'DELETE') {
        if (currentRole != 'admin') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 403,
              data: {
                'message': 'Forbidden. Only administrators can delete records.',
              },
            ),
          );
          return;
        }

        final segments = path.split('/');
        final targetId = segments.last;

        if (targetId == currentUserId) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 422,
              data: {
                'message': 'Cannot delete your own administrator account.',
              },
            ),
          );
          return;
        }

        final employeesRaw = _prefs.getString(AppConstants.mockEmployeesKey)!;
        List employees = jsonDecode(employeesRaw);

        final index = employees.indexWhere((e) => e['id'] == targetId);
        if (index == -1) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 404,
              data: {'message': 'Employee record not found.'},
            ),
          );
          return;
        }

        employees.removeAt(index);
        await _prefs.setString(
          AppConstants.mockEmployeesKey,
          jsonEncode(employees),
        );

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'message': 'Employee record deleted.'},
          ),
        );
        return;
      }
      if (path == '/attendance' && method == 'GET') {
        final queryParams = options.queryParameters;
        final employeeIdFilter = queryParams['employeeId'] as String?;
        final page = int.tryParse(queryParams['page']?.toString() ?? '1') ?? 1;
        final limit =
            int.tryParse(queryParams['limit']?.toString() ?? '10') ?? 10;

        final attendanceRaw = _prefs.getString(AppConstants.mockAttendanceKey)!;
        List attendance = jsonDecode(attendanceRaw);

        if (currentRole == 'employee') {
          attendance = attendance
              .where((a) => a['employeeId'] == currentUserId)
              .toList();
        } else if (employeeIdFilter != null && employeeIdFilter.isNotEmpty) {
          attendance = attendance
              .where((a) => a['employeeId'] == employeeIdFilter)
              .toList();
        }

        attendance.sort(
          (a, b) => (b['checkIn'] as String).compareTo(a['checkIn'] as String),
        );

        final total = attendance.length;
        final totalPages = (total / limit).ceil();
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;

        List paginatedList = [];
        if (startIndex < total) {
          paginatedList = attendance.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );
        }

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'data': paginatedList,
              'meta': {
                'total': total,
                'page': page,
                'limit': limit,
                'totalPages': totalPages,
              },
            },
          ),
        );
        return;
      }

      if (path == '/attendance/today' && method == 'GET') {
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final attendanceRaw = _prefs.getString(AppConstants.mockAttendanceKey)!;
        final List attendance = jsonDecode(attendanceRaw);

        final todayRecord = attendance.firstWhere(
          (a) => a['employeeId'] == currentUserId && a['date'] == today,
          orElse: () => null,
        );

        handler.resolve(
          Response(requestOptions: options, statusCode: 200, data: todayRecord),
        );
        return;
      }

      if (path == '/attendance/check-in' && method == 'POST') {
        final body = options.data as Map<String, dynamic>;
        final latitude = body['latitude'] as double?;
        final longitude = body['longitude'] as double?;

        final today = DateTime.now().toIso8601String().substring(0, 10);
        final attendanceRaw = _prefs.getString(AppConstants.mockAttendanceKey)!;
        final List attendance = jsonDecode(attendanceRaw);

        final alreadyCheckedIn = attendance.any(
          (a) => a['employeeId'] == currentUserId && a['date'] == today,
        );
        if (alreadyCheckedIn) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 422,
              data: {'message': 'You have already checked in today.'},
            ),
          );
          return;
        }
        bool inRange = true;
        if (latitude != null && longitude != null) {
          final latDelta = (latitude - 37.7749).abs();
          final lngDelta = (longitude + 122.4194).abs();
          if (latDelta > 0.01 || lngDelta > 0.01) {
            inRange = false;
          }
        }

        if (!inRange) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 422,
              data: {
                'message':
                    'Check-in failed. GPS shows you are too far from the office Headquarters.',
              },
            ),
          );
          return;
        }

        final now = DateTime.now();
        final threshold = DateTime(now.year, now.month, now.day, 9, 0);
        final status = now.isAfter(threshold) ? 'late' : 'present';

        final newRecord = {
          'id': 'att-${_uuid.v4().substring(0, 8)}',
          'employeeId': currentUserId,
          'employeeName': currentUser['name'],
          'date': today,
          'checkIn': now.toIso8601String(),
          'checkOut': null,
          'workingHours': null,
          'status': status,
          'latitude': latitude,
          'longitude': longitude,
        };

        attendance.add(newRecord);
        await _prefs.setString(
          AppConstants.mockAttendanceKey,
          jsonEncode(attendance),
        );

        handler.resolve(
          Response(requestOptions: options, statusCode: 201, data: newRecord),
        );
        return;
      }

      if (path == '/attendance/check-out' && method == 'POST') {
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final attendanceRaw = _prefs.getString(AppConstants.mockAttendanceKey)!;
        final List attendance = jsonDecode(attendanceRaw);

        final recordIndex = attendance.indexWhere(
          (a) => a['employeeId'] == currentUserId && a['date'] == today,
        );
        if (recordIndex == -1) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 422,
              data: {'message': 'You must check in first before checking out.'},
            ),
          );
          return;
        }

        final record = attendance[recordIndex] as Map<String, dynamic>;
        if (record['checkOut'] != null) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 422,
              data: {'message': 'You have already checked out today.'},
            ),
          );
          return;
        }

        final now = DateTime.now();
        final checkInTime = DateTime.parse(record['checkIn'] as String);
        final difference = now.difference(checkInTime);
        final workingHours = double.parse(
          (difference.inMinutes / 60.0).toStringAsFixed(2),
        );

        final updatedRecord = {
          ...record,
          'checkOut': now.toIso8601String(),
          'workingHours': workingHours,
        };

        attendance[recordIndex] = updatedRecord;
        await _prefs.setString(
          AppConstants.mockAttendanceKey,
          jsonEncode(attendance),
        );

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: updatedRecord,
          ),
        );
        return;
      }
      if (path == '/leaves' && method == 'GET') {
        final queryParams = options.queryParameters;
        final page = int.tryParse(queryParams['page']?.toString() ?? '1') ?? 1;
        final limit =
            int.tryParse(queryParams['limit']?.toString() ?? '10') ?? 10;

        final leavesRaw = _prefs.getString(AppConstants.mockLeavesKey)!;
        List leaves = jsonDecode(leavesRaw);

        if (currentRole == 'employee') {
          leaves = leaves
              .where((l) => l['employeeId'] == currentUserId)
              .toList();
        }

        leaves.sort(
          (a, b) =>
              (b['appliedOn'] as String).compareTo(a['appliedOn'] as String),
        );

        final total = leaves.length;
        final totalPages = (total / limit).ceil();
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;

        List paginatedList = [];
        if (startIndex < total) {
          paginatedList = leaves.sublist(
            startIndex,
            endIndex > total ? total : endIndex,
          );
        }

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'data': paginatedList,
              'meta': {
                'total': total,
                'page': page,
                'limit': limit,
                'totalPages': totalPages,
              },
            },
          ),
        );
        return;
      }

      if (path == '/leaves' && method == 'POST') {
        final body = options.data as Map<String, dynamic>;
        final newLeave = {
          'id': 'leave-${_uuid.v4().substring(0, 8)}',
          'employeeId': currentUserId,
          'employeeName': currentUser['name'],
          'leaveType': body['leaveType'],
          'startDate': body['startDate'],
          'endDate': body['endDate'],
          'reason': body['reason'],
          'status': 'pending',
          'appliedOn': DateTime.now().toIso8601String(),
          'reviewerName': null,
          'reviewerComment': null,
          'attachmentName': body['attachmentName'],
        };

        final leavesRaw = _prefs.getString(AppConstants.mockLeavesKey)!;
        final List leaves = jsonDecode(leavesRaw);
        leaves.add(newLeave);
        await _prefs.setString(AppConstants.mockLeavesKey, jsonEncode(leaves));

        handler.resolve(
          Response(requestOptions: options, statusCode: 201, data: newLeave),
        );
        return;
      }

      if (path.endsWith('/approve') && method == 'PATCH') {
        if (currentRole != 'admin' && currentRole != 'manager') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 403,
              data: {
                'message':
                    'Forbidden. Only managers or administrators can approve leaves.',
              },
            ),
          );
          return;
        }

        final segments = path.split('/');

        final targetId = segments[segments.length - 2];

        final body = options.data as Map<String, dynamic>? ?? {};
        final comment = body['comment'] as String?;

        final leavesRaw = _prefs.getString(AppConstants.mockLeavesKey)!;
        final List leaves = jsonDecode(leavesRaw);

        final index = leaves.indexWhere((l) => l['id'] == targetId);
        if (index == -1) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 404,
              data: {'message': 'Leave request not found.'},
            ),
          );
          return;
        }

        final leave = leaves[index] as Map<String, dynamic>;
        final updatedLeave = {
          ...leave,
          'status': 'approved',
          'reviewerName': currentUser['name'],
          'reviewerComment': comment ?? 'Approved.',
        };

        leaves[index] = updatedLeave;
        await _prefs.setString(AppConstants.mockLeavesKey, jsonEncode(leaves));

        final notifsRaw = _prefs.getString(AppConstants.mockNotificationsKey)!;
        final List notifications = jsonDecode(notifsRaw);
        notifications.add({
          'id': 'notif-${_uuid.v4().substring(0, 8)}',
          'employeeId': leave['employeeId'],
          'title': 'Leave Approved',
          'message':
              'Your leave request for ${leave['startDate']} has been approved by ${currentUser['name']}.',
          'type': 'leave',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
        await _prefs.setString(
          AppConstants.mockNotificationsKey,
          jsonEncode(notifications),
        );

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: updatedLeave,
          ),
        );
        return;
      }

      if (path.endsWith('/reject') && method == 'PATCH') {
        if (currentRole != 'admin' && currentRole != 'manager') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 403,
              data: {
                'message':
                    'Forbidden. Only managers or administrators can reject leaves.',
              },
            ),
          );
          return;
        }

        final segments = path.split('/');
        final targetId = segments[segments.length - 2];

        final body = options.data as Map<String, dynamic>? ?? {};
        final comment = body['comment'] as String?;

        final leavesRaw = _prefs.getString(AppConstants.mockLeavesKey)!;
        final List leaves = jsonDecode(leavesRaw);

        final index = leaves.indexWhere((l) => l['id'] == targetId);
        if (index == -1) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 404,
              data: {'message': 'Leave request not found.'},
            ),
          );
          return;
        }

        final leave = leaves[index] as Map<String, dynamic>;
        final updatedLeave = {
          ...leave,
          'status': 'rejected',
          'reviewerName': currentUser['name'],
          'reviewerComment': comment ?? 'Rejected.',
        };

        leaves[index] = updatedLeave;
        await _prefs.setString(AppConstants.mockLeavesKey, jsonEncode(leaves));

        final notifsRaw = _prefs.getString(AppConstants.mockNotificationsKey)!;
        final List notifications = jsonDecode(notifsRaw);
        notifications.add({
          'id': 'notif-${_uuid.v4().substring(0, 8)}',
          'employeeId': leave['employeeId'],
          'title': 'Leave Rejected',
          'message':
              'Your leave request for ${leave['startDate']} was rejected: ${comment ?? 'No comment provided.'}',
          'type': 'leave',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
        await _prefs.setString(
          AppConstants.mockNotificationsKey,
          jsonEncode(notifications),
        );

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: updatedLeave,
          ),
        );
        return;
      }
      if (path == '/notifications' && method == 'GET') {
        final notifsRaw = _prefs.getString(AppConstants.mockNotificationsKey)!;
        List notifications = jsonDecode(notifsRaw);

        notifications = notifications
            .where((n) => n['employeeId'] == currentUserId)
            .toList();
        notifications.sort(
          (a, b) =>
              (b['createdAt'] as String).compareTo(a['createdAt'] as String),
        );

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: notifications,
          ),
        );
        return;
      }

      if (path == '/notifications' && method == 'POST') {
        final body = options.data as Map<String, dynamic>;
        final title = body['title'] as String;
        final message = body['message'] as String;
        final receiverId = body['employeeId'] as String;
        final type = body['type'] as String;

        final notifsRaw = _prefs.getString(AppConstants.mockNotificationsKey)!;
        final List notifications = jsonDecode(notifsRaw);

        final employeesRaw = _prefs.getString(AppConstants.mockEmployeesKey)!;
        final List employeesList = jsonDecode(employeesRaw);

        List receivers = [];
        if (receiverId == 'All') {
          receivers = employeesList.map((e) => e['id'] as String).toList();
        } else {
          receivers = [receiverId];
        }

        final nowStr = DateTime.now().toIso8601String();
        for (var recId in receivers) {
          notifications.add({
            'id': 'notif-${_uuid.v4().substring(0, 8)}',
            'employeeId': recId,
            'title': title,
            'message': message,
            'type': type,
            'isRead': false,
            'createdAt': nowStr,
          });
        }

        await _prefs.setString(
          AppConstants.mockNotificationsKey,
          jsonEncode(notifications),
        );

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 201,
            data: {'success': true},
          ),
        );
        return;
      }

      if (path.startsWith('/notifications/') &&
          path.endsWith('/read') &&
          method == 'PATCH') {
        final segments = path.split('/');
        final targetId = segments[segments.length - 2];

        final notifsRaw = _prefs.getString(AppConstants.mockNotificationsKey)!;
        final List notifications = jsonDecode(notifsRaw);

        final index = notifications.indexWhere((n) => n['id'] == targetId);
        if (index != -1) {
          final notif = notifications[index] as Map<String, dynamic>;
          notifications[index] = {...notif, 'isRead': true};
          await _prefs.setString(
            AppConstants.mockNotificationsKey,
            jsonEncode(notifications),
          );

          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: notifications[index],
            ),
          );
        } else {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 404,
              data: {'message': 'Notification not found.'},
            ),
          );
        }
        return;
      }

      if (path == '/profile/upload' && method == 'POST') {
        final fileName = options.data is FormData
            ? (options.data as FormData).files.first.value.filename ??
                  'uploaded_file.jpg'
            : 'avatar_${currentUserId}.jpg';

        final fileUrl =
            'https://api.dicebear.com/7.x/adventurer/png?seed=${_uuid.v4().substring(0, 5)}';

        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'fileName': fileName, 'fileUrl': fileUrl, 'success': true},
          ),
        );
        return;
      }
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 404,
          data: {'message': 'Endpoint not found: $method $path'},
        ),
      );
    } catch (e) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 500,
          data: {'message': 'Mock server internal error: ${e.toString()}'},
        ),
      );
    }
  }
}
