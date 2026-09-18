import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final StorageService _storageService;
  final _authStateController = StreamController<UserModel?>.broadcast();

  FirebaseAuthRepositoryImpl({
    required fb.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required StorageService storageService,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _storageService = storageService {
    _firebaseAuth.authStateChanges().listen((fbUser) async {
      if (fbUser != null) {
        final userModel = await _fetchUserModel(fbUser.uid);
        _authStateController.add(userModel);
      } else {
        _authStateController.add(null);
      }
    });
  }

  Future<UserModel?> _fetchUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 5));
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _fetchUserModel(credentials.user!.uid);
      if (user == null) {
        throw Exception('User database record not found in Firestore.');
      }
      
     
      await _storageService.saveUserData(user.toJson());
      await _storageService.saveAccessToken('firebase_token_${user.id}');
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _storageService.clearAll();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return await _fetchUserModel(fbUser.uid);
  }

  @override
  Future<UserModel> signUp(String email, String password, Map<String, dynamic> additionalData) async {
    try {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credentials.user!.uid;

  
      final user = UserModel(
        id: uid,
        email: email,
        name: additionalData['name'] as String? ?? 'Employee',
        role: UserRole.employee, // Default role for registering users
        department: additionalData['department'] as String? ?? 'Engineering',
        avatarUrl: additionalData['avatarUrl'] as String?,
      );

      await _firestore.collection('users').doc(uid).set(user.toJson());

 
      await _firestore.collection('employees').doc(uid).set({
        'id': uid,
        'name': user.name,
        'email': email,
        'phone': additionalData['phone'] as String? ?? '',
        'role': user.role.name,
        'department': user.department,
        'status': 'active',
        'joiningDate': DateTime.now().toIso8601String().substring(0, 10),
        'avatarUrl': user.avatarUrl,
      });

      
      await _storageService.saveUserData(user.toJson());
      await _storageService.saveAccessToken('firebase_token_$uid');

      return user;
    } catch (e) {
      rethrow;
    }
  }
}
