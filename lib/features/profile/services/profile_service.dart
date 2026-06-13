import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Dio get _dio => _apiClient.dio;

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to fetch profile';
    }
  }

  Future<Map<String, dynamic>> uploadProfileImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/auth/me/image', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to upload profile image';
    }
  }

  Future<bool> revokeAllSessions() async {
    try {
      await _dio.post('/auth/sessions/revoke-all');
      return true;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to revoke all sessions';
    }
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final response = await _dio.get('/auth/sessions');
      if (response.data is List) {
        return (response.data as List).map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to fetch sessions';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    try {
      await _dio.delete('/auth/sessions/$sessionId');
      return true;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to revoke session';
    }
  }

  Future<Map<String, dynamic>> updateProfile({required String firstName, required String lastName, String? phone}) async {
    try {
      final response = await _dio.patch('/auth/me', data: {
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null) 'phone': phone,
      });
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to update profile';
    }
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      await _dio.post('/auth/me/change-password', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      return true;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to change password';
    }
  }
}
