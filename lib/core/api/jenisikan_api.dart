import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../data/models/jenisikan_model.dart';
import '../../data/models/success_model.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class JenisikanApi {
  final Dio _dio = Dio();
  final _logger = Logger();

  /// 🔹 GET /jenisikan
  Future<List<dynamic>> listJenisikanAll({int? ikanId}) async {
    final token = await StorageService.getToken();

    _logger.i('📥 GET: ${AppConfig.baseUrl}/jenisikan');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/jenisikan',
      queryParameters: ikanId != null ? {'ikan_id': ikanId} : null,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'] as List<dynamic>;
  }

  /// GET jenis ikan berdasarkan ikanId
  Future<List<dynamic>> listJenisikanByIkan(int ikanId) async {
    final token = await StorageService.getToken();
    final response = await _dio.get(
      '${AppConfig.baseUrl}/jenisikan/by-ikan/$ikanId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'] ?? [];
  }

  /// 🔹 GET /jenisikan/{id}
  Future<Map<String, dynamic>> getById(int id) async {
    final token = await StorageService.getToken();

    _logger.i('🔍 GET: ${AppConfig.baseUrl}/jenisikan/$id');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/jenisikan/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'];
  }

  /// 🔹 POST /jenisikan
  Future<Map<String, dynamic>> create(String name, int ikanId) async {
    final token = await StorageService.getToken();

    _logger.i('📤 POST: ${AppConfig.baseUrl}/jenisikan');

    final response = await _dio.post(
      '${AppConfig.baseUrl}/jenisikan',
      data: {'name': name, 'ikan_id': ikanId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  /// 🔹 PUT /jenisikan/{id}
  Future<Map<String, dynamic>> update(int id, String name, int ikanId) async {
    final token = await StorageService.getToken();

    _logger.i('✏️ PUT: ${AppConfig.baseUrl}/jenisikan/$id');

    final response = await _dio.put(
      '${AppConfig.baseUrl}/jenisikan/$id',
      data: {'name': name, 'ikan_id': ikanId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  /// 🔹 DELETE /jenisikan/{id} (PERMANEN)
  Future<Map<String, dynamic>> delete(int id) async {
    final token = await StorageService.getToken();

    _logger.w('🗑️ DELETE: ${AppConfig.baseUrl}/jenisikan/$id');

    final response = await _dio.delete(
      '${AppConfig.baseUrl}/jenisikan/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  /// 🔹 GET /ikan (dropdown)
  Future<List<dynamic>> fetchIkan() async {
    final token = await StorageService.getToken();

    _logger.i('📥 GET: ${AppConfig.baseUrl}/ikan');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/ikan',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'] as List<dynamic>;
  }
}
