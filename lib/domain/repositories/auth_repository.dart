import '../../data/models/user.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String email, String password, Map<String, dynamic> additionalData);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}
