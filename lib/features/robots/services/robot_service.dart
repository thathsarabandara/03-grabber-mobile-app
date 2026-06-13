import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class RobotService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getRobots() async {
    try {
      final response = await _apiClient.dio.get('/robots');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> pairRobot(String robotId, String serialKey) async {
    try {
      final response = await _apiClient.dio.post('/robots/pair', data: {
        'robotId': robotId,
        'serialKey': serialKey,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> unpairRobot(String id) async {
    try {
      await _apiClient.dio.delete('/robots/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> updateRobot(String id, String newName) async {
    try {
      final response = await _apiClient.dio.patch('/robots/$id', data: {
        'name': newName,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response!.data['detail'] != null) {
        return error.response!.data['detail'];
      }
      return error.message ?? 'An unknown error occurred';
    }
    return error.toString();
  }
}
