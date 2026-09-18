import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/leave_request.dart';
import '../../domain/repositories/leave_repository.dart';

class FirebaseLeaveRepositoryImpl implements LeaveRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseLeaveRepositoryImpl(this._firestore, this._firebaseAuth);

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Map<String, dynamic>> getLeaveRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(_currentUserId).get().timeout(const Duration(seconds: 5));
      final role = userDoc.data()?['role'] as String? ?? 'employee';

      Query query = _firestore.collection('leave_requests');
      if (role == 'employee') {
        query = query.where('employeeId', isEqualTo: _currentUserId);
      }

      final snapshot = await query.get().timeout(const Duration(seconds: 5));
      List<LeaveRequestModel> leaves = snapshot.docs
          .map((doc) => LeaveRequestModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      leaves.sort((a, b) => b.appliedOn.compareTo(a.appliedOn));

      final total = leaves.length;
      final totalPages = (total / limit).ceil();
      final startIndex = (page - 1) * limit;

      List<LeaveRequestModel> paginatedList = [];
      if (startIndex < total) {
        final endIndex = startIndex + limit;
        paginatedList = leaves.sublist(
          startIndex,
          endIndex > total ? total : endIndex,
        );
      }

      return {
        'leaves': paginatedList,
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
  Future<LeaveRequestModel> applyForLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentName,
    String? attachmentPath,
  }) async {
    try {

      String name = 'Employee';
      final empDoc = await _firestore.collection('employees').doc(_currentUserId).get();
      if (empDoc.exists && empDoc.data() != null) {
        name = empDoc.data()!['name'] as String? ?? 'Employee';
      }
      if (attachmentPath != null && attachmentPath.isNotEmpty && attachmentPath != 'mock_file_path') {
        final file = File(attachmentPath);
        if (await file.exists()) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('documents/$_currentUserId/$attachmentName');
          await ref.putFile(file);
        }
      }

      final docRef = _firestore.collection('leave_requests').doc();
      final record = LeaveRequestModel(
        id: docRef.id,
        employeeId: _currentUserId,
        employeeName: name,
        leaveType: LeaveType.fromString(leaveType),
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        status: LeaveStatus.pending,
        appliedOn: DateTime.now().toIso8601String(),
        attachmentName: attachmentName,
      );

      await docRef.set(record.toJson());
      return record;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LeaveRequestModel> approveLeave(String id, String? comment) async {
    try {
      final docRef = _firestore.collection('leave_requests').doc(id);
    
      String reviewerName = 'Admin';
      final userDoc = await _firestore.collection('users').doc(_currentUserId).get();
      if (userDoc.exists && userDoc.data() != null) {
        reviewerName = userDoc.data()?['name'] as String? ?? 'Admin';
      }

      await docRef.update({
        'status': LeaveStatus.approved.name,
        'reviewerName': reviewerName,
        'reviewerComment': comment ?? 'Approved.',
      });

      final doc = await docRef.get();
      return LeaveRequestModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LeaveRequestModel> rejectLeave(String id, String? comment) async {
    try {
      final docRef = _firestore.collection('leave_requests').doc(id);
      
      String reviewerName = 'Admin';
      final userDoc = await _firestore.collection('users').doc(_currentUserId).get();
      if (userDoc.exists && userDoc.data() != null) {
        reviewerName = userDoc.data()?['name'] as String? ?? 'Admin';
      }

      await docRef.update({
        'status': LeaveStatus.rejected.name,
        'reviewerName': reviewerName,
        'reviewerComment': comment ?? 'Rejected.',
      });

      final doc = await docRef.get();
      return LeaveRequestModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getLeaveBalances() async {
    try {
      final userDoc = await _firestore.collection('users').doc(_currentUserId).get().timeout(const Duration(seconds: 5));
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('leave_balances')) {
          final Map<String, dynamic> dbBalances = data['leave_balances'] as Map<String, dynamic>;
          return dbBalances.map((key, value) => MapEntry(key, (value as num).toInt()));
        }
      }
    } catch (_) {}

    return {'annual': 14, 'sick': 10, 'casual': 7};
  }
}
