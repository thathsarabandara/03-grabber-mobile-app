import '../../../core/network/api_client.dart';

class MediaService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getMedia() async {
    try {
      final response = await _apiClient.dio.get('/telemetry/media');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load media: $e');
    }
  }

  Future<void> deleteMedia(String id) async {
    try {
      await _apiClient.dio.delete('/telemetry/media/$id');
    } catch (e) {
      throw Exception('Failed to delete media: $e');
    }
  }
}
