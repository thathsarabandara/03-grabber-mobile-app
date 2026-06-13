import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Dio get _dio => _apiClient.dio;

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone': phone,
      });
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Registration failed';
    }
  }

  Future<String> login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['access_token'];
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Login failed';
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      return true;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'OTP Verification failed';
    }
  }

  Future<bool> resendOtp({required String email}) async {
    try {
      await _dio.post('/auth/resend-otp', data: {
        'email': email,
      });
      return true;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to resend OTP';
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return true;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to request password reset';
    }
  }

  Future<bool> resetPassword({required String token, required String newPassword}) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'token': token,
        'new_password': newPassword,
      });
      return true;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? e.message ?? 'Failed to reset password';
    }
  }


}
