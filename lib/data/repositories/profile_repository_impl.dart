import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/user.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepositoryImpl(this._apiClient);

  @override
  Future<String> uploadProfilePicture(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromString('mock_bytes', filename: fileName),
      });

      final response = await _apiClient.post(
        '/profile/upload',
        data: formData,
      );

      return response.data['fileUrl'] as String;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '/employees/$id',
        data: data,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
