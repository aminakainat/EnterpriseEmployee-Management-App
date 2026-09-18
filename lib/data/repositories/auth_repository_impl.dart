import 'dart:async';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final _authStateController = StreamController<UserModel?>.broadcast();

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService {
 
    _initSession();
  }

  void _initSession() {
    try {
      final cachedUser = _storageService.getUserData();
      if (cachedUser != null) {
        _authStateController.add(UserModel.fromJson(cachedUser));
      } else {
        _authStateController.add(null);
      }
    } catch (_) {
    
      _storageService.clearAll();
      _authStateController.add(null);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final userData = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);

      await _storageService.saveAccessToken(accessToken);
      await _storageService.saveRefreshToken(refreshToken);
      await _storageService.saveUserData(userData.toJson());

      _authStateController.add(userData);
      return userData;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, Map<String, dynamic> additionalData) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          ...additionalData,
        },
      );

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final userData = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);

      await _storageService.saveAccessToken(accessToken);
      await _storageService.saveRefreshToken(refreshToken);
      await _storageService.saveUserData(userData.toJson());

      _authStateController.add(userData);
      return userData;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAll();
    _authStateController.add(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final cached = _storageService.getUserData();
      if (cached == null) return null;
      return UserModel.fromJson(cached);
    } catch (_) {
      await _storageService.clearAll();
      return null;
    }
  }
}
