import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'package:image_picker/image_picker.dart';

class AiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getTasks() async {
    try {
      final response = await _apiClient.dio.get('/ai/tasks');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load AI tasks: $e');
    }
  }

  Future<void> startTask(String taskId) async {
    try {
      await _apiClient.dio.post('/ai/tasks/start', data: {'task_id': taskId});
    } catch (e) {
      throw Exception('Failed to start AI task: $e');
    }
  }

  Future<void> stopTask(String taskId) async {
    try {
      await _apiClient.dio.post('/ai/tasks/stop', data: {'task_id': taskId});
    } catch (e) {
      throw Exception('Failed to stop AI task: $e');
    }
  }

  Future<void> startAllTasks() async {
    try {
      await _apiClient.dio.post('/ai/tasks/start-all');
    } catch (e) {
      throw Exception('Failed to start all AI tasks: $e');
    }
  }

  Future<void> stopAllTasks() async {
    try {
      await _apiClient.dio.post('/ai/tasks/stop-all');
    } catch (e) {
      throw Exception('Failed to stop all AI tasks: $e');
    }
  }

  Future<void> registerFace(String name, XFile imageFile) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'file': await MultipartFile.fromFile(imageFile.path, filename: imageFile.name),
      });
      await _apiClient.dio.post('/ai/face/register', data: formData);
    } catch (e) {
      throw Exception('Failed to register face: $e');
    }
  }
}
