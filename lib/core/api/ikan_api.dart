import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../data/models/ikan_model.dart';
import '../../data/models/success_model.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class IkanApi {
  final Dio _dio = Dio();
  final _logger = Logger();

  Future<List<IkanModel>> getAll() async {
    final token = await StorageService.getToken();
    _logger.i('📥 GET: ${AppConfig.baseUrl}/ikan');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/ikan',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final raw = response.data;

    List<dynamic> list = [];

    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw['data'] is List) {
      list = raw['data'];
    }

    return list.map((item) => IkanModel.fromJson(item)).toList();
  }

  Future<IkanModel> create(String name) async {
    final token = await StorageService.getToken();
    _logger.i('📤 POST: ${AppConfig.baseUrl}/ikan');

    final response = await _dio.post(
      '${AppConfig.baseUrl}/ikan',
      data: {'name': name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return IkanModel.fromJson(response.data);
  }

  Future<IkanModel> update(int id, String name) async {
    final token = await StorageService.getToken();
    _logger.i('✏️ PUT: ${AppConfig.baseUrl}/ikan/$id');

    final response = await _dio.put(
      '${AppConfig.baseUrl}/ikan/$id',
      data: {'name': name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return IkanModel.fromJson(response.data);
  }

  Future<SuccessModel> delete(int id) async {
    final token = await StorageService.getToken();
    _logger.w('🗑️ DELETE: ${AppConfig.baseUrl}/ikan/$id');

    final response = await _dio.delete(
      '${AppConfig.baseUrl}/ikan/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return SuccessModel.fromJson(response.data);
  }

  Future<IkanModel> getById(int id) async {
    final token = await StorageService.getToken();
    _logger.i('🔍 GET BY ID: ${AppConfig.baseUrl}/ikan/$id');

    final response = await _dio.get(
      '${AppConfig.baseUrl}/ikan/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return IkanModel.fromJson(response.data);
  }
}
