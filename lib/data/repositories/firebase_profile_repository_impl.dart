import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../../domain/repositories/profile_repository.dart';

class FirebaseProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseProfileRepositoryImpl(this._firestore, this._storage);

  @override
  Future<String> uploadProfilePicture(String filePath, String fileName) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final ref = _storage.ref().child('avatars/$uid/$fileName');
      final uploadTask = ref.putFile(File(filePath));
      
      final snapshot = await uploadTask;
      final fileUrl = await snapshot.ref.getDownloadURL();
      return fileUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(id).update(data);
      
      
      final Map<String, dynamic> empUpdates = {};
      if (data.containsKey('fullName')) empUpdates['name'] = data['fullName'];
      if (data.containsKey('phone')) empUpdates['phone'] = data['phone'];
      if (data.containsKey('avatarUrl')) empUpdates['avatarUrl'] = data['avatarUrl'];

      if (empUpdates.isNotEmpty) {
        await _firestore.collection('employees').doc(id).update(empUpdates);
      }

      final doc = await _firestore.collection('users').doc(id).get();
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }
}
