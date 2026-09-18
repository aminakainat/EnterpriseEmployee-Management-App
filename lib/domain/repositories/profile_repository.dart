import '../../data/models/user.dart';

abstract class ProfileRepository {
  Future<String> uploadProfilePicture(String filePath, String fileName);
  Future<UserModel> updateProfile(String id, Map<String, dynamic> data);
}
