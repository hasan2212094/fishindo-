import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../data/models/mainbox_model.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class MainBoxApi {
  final Dio _dio = Dio();
  final _logger = Logger();

  Future<List<MainBoxModel>> getAll() async {
    final token = await StorageService.getToken();
    _logger.i('📥 GET: ${AppConfig.baseUrl}/mainbox');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/mainbox',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final raw = response.data;
    List<dynamic> list = [];

    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw['data'] is List) {
      list = raw['data'];
    }

    return list.map((item) => MainBoxModel.fromJson(item)).toList();
  }

  Future<MainBoxModel> create(String name) async {
    final token = await StorageService.getToken();
    _logger.i('📤 POST: ${AppConfig.baseUrl}/mainbox');

    final response = await _dio.post(
      '${AppConfig.baseUrl}/mainbox',
      data: {'name': name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return MainBoxModel.fromJson(response.data);
  }

  Future<MainBoxModel> update(int id, String name) async {
    final token = await StorageService.getToken();
    _logger.i('✏️ PUT: ${AppConfig.baseUrl}/mainbox/$id');

    final response = await _dio.put(
      '${AppConfig.baseUrl}/mainbox/$id',
      data: {'name': name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return MainBoxModel.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    final token = await StorageService.getToken();
    _logger.w('🗑️ DELETE: ${AppConfig.baseUrl}/mainbox/$id');

    await _dio.delete(
      '${AppConfig.baseUrl}/mainbox/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<MainBoxModel> getById(int id) async {
    final token = await StorageService.getToken();
    _logger.i('🔍 GET BY ID: ${AppConfig.baseUrl}/mainbox/$id');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/mainbox/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return MainBoxModel.fromJson(response.data);
  }
}
