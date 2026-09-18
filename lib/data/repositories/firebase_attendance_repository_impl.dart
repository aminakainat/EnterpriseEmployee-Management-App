import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';

class FirebaseAttendanceRepositoryImpl implements AttendanceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseAttendanceRepositoryImpl(this._firestore, this._firebaseAuth);

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? 'unknown_uid';

  @override
  Future<Map<String, dynamic>> getAttendanceHistory({
    int page = 1,
    int limit = 10,
    String? employeeId,
  }) async {
    try {
      final targetEmpId = employeeId ?? _currentUserId;
      
      final snapshot = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: targetEmpId)
          .get();

      List<AttendanceModel> history = snapshot.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();

      
      history.sort((a, b) => b.checkIn.compareTo(a.checkIn));

      final total = history.length;
      final totalPages = (total / limit).ceil();
      final startIndex = (page - 1) * limit;

      List<AttendanceModel> paginatedList = [];
      if (startIndex < total) {
        final endIndex = startIndex + limit;
        paginatedList = history.sublist(
          startIndex,
          endIndex > total ? total : endIndex,
        );
      }

      return {
        'history': paginatedList,
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
  Future<AttendanceModel?> getTodayStatus() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final snapshot = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: _currentUserId)
          .where('date', isEqualTo: today)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isNotEmpty) {
        return AttendanceModel.fromJson(snapshot.docs.first.data());
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<AttendanceModel> checkIn({double? latitude, double? longitude}) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
    
      final now = DateTime.now();
      final threshold = DateTime(now.year, now.month, now.day, 9, 0);
      final status = now.isAfter(threshold) ? AttendanceStatus.late : AttendanceStatus.present;

      String name = 'Employee';
      final empDoc = await _firestore.collection('employees').doc(_currentUserId).get();
      if (empDoc.exists && empDoc.data() != null) {
        name = empDoc.data()!['name'] as String? ?? 'Employee';
      }

      final docRef = _firestore.collection('attendance').doc();
      final record = AttendanceModel(
        id: docRef.id,
        employeeId: _currentUserId,
        employeeName: name,
        date: today,
        checkIn: now.toIso8601String(),
        checkOut: null,
        workingHours: null,
        status: status,
        latitude: latitude,
        longitude: longitude,
      );

      await docRef.set(record.toJson());
      return record;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AttendanceModel> checkOut() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final snapshot = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: _currentUserId)
          .where('date', isEqualTo: today)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Check-in record not found for today.');
      }

      final doc = snapshot.docs.first;
      final existingData = AttendanceModel.fromJson(doc.data());
      
      if (existingData.checkOut != null) {
        throw Exception('You have already checked out today.');
      }

      final now = DateTime.now();
      final checkInTime = DateTime.parse(existingData.checkIn);
      final diff = now.difference(checkInTime);
      final workingHours = double.parse((diff.inMinutes / 60.0).toStringAsFixed(2));

      final updatedRecord = existingData.copyWith(
        checkOut: now.toIso8601String(),
        workingHours: workingHours,
      );

      await doc.reference.update(updatedRecord.toJson());
      return updatedRecord;
    } catch (e) {
      rethrow;
    }
  }
}
