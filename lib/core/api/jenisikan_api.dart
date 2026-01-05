import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../data/models/jenisikan_model.dart';
import '../../data/models/success_model.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class JenisikanApi {
  final Dio _dio = Dio();
  final _logger = Logger();

  Future<List<JenisIkanModel>> getAll() async {
    final token = await StorageService.getToken();
    _logger.i('📥 GET: ${AppConfig.baseUrl}/jenisikan');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/jenisikan',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final raw = response.data;

    List<dynamic> list = [];

    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw['data'] is List) {
      list = raw['data'];
    }

    return list.map((item) => JenisIkanModel.fromJson(item)).toList();
  }

  Future<JenisIkanModel> create(String name) async {
    final token = await StorageService.getToken();
    _logger.i('📤 POST: ${AppConfig.baseUrl}/jenisikan');

    final response = await _dio.post(
      '${AppConfig.baseUrl}/jenisikan',
      data: {
        'name': name,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return JenisIkanModel.fromJson(response.data);
  }

  Future<JenisIkanModel> update(int id, String nomor, {String? client}) async {
    final token = await StorageService.getToken();
    _logger.i('✏️ PUT: ${AppConfig.baseUrl}/jenisikan/$id');

    final response = await _dio.put(
      '${AppConfig.baseUrl}/jenisikan/$id',
      data: {
        'nomor': nomor,
        if (client != null) 'client': client,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return JenisIkanModel.fromJson(response.data);
  }

  Future<SuccessModel> delete(int id) async {
    final token = await StorageService.getToken();
    _logger.w('🗑️ DELETE: ${AppConfig.baseUrl}/jenisikan/$id');

    final response = await _dio.delete(
      '${AppConfig.baseUrl}/jenisikan/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return SuccessModel.fromJson(response.data);
  }

  Future<JenisIkanModel> getById(int id) async {
    final token = await StorageService.getToken();
    _logger.i('🔍 GET BY ID: ${AppConfig.baseUrl}/jenisikan/$id');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/jenisikan/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return JenisIkanModel.fromJson(response.data);
  }
}
